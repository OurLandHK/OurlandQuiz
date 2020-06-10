import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:image/image.dart' as Img;


import 'service.dart';
import 'package:firebase_storage/firebase_storage.dart' as MobFirebaseStorage;
import 'package:cloud_firestore/cloud_firestore.dart' as MobFirestore;
import 'package:firebase/firebase.dart' as WebFirebase;
import 'dart:html'as html;
import 'package:flutter/foundation.dart';
import '../main.dart';
import '../models/question.dart';
import '../models/textRes.dart';
import './storageService.dart';

QuestionService questionService = new QuestionService();

class QuestionService {
  QuestionService();


  Future getPendingQuestionList(String status, Function returnQuestionList) async {
    List<Question> questions = [];
    try {
      var mobQuery = mobFirestore.collection('pendingQuestion').where("status", isEqualTo: status);
      mobQuery.snapshots().listen((event) {
        event.documents.forEach((doc) {
          if(doc.exists) {
            Map data = doc.data;
            //print(data);
            data['id'] = doc.documentID;
            Question question = Question.fromMap(data); 
            questions.add(question);
          }
        });
        returnQuestionList(questions);
      });
    } catch (exception) {
      print(exception);
      returnQuestionList(questions);
    }
  }

  Future<bool> sendPendingQuestion(Question question, List<int> imageBlob, List<int> descImageBlob) async {
    bool blReturn = false;
    Map imageUrls;
    Map descImageUrls;
    String downloadUrl;
    String serverUrl;
    if(imageBlob != null && imageBlob.length > 0) {
      imageUrls = await storageService.uploadImage(imageBlob);
    }
    if(descImageBlob != null && descImageBlob.length > 0) {
      descImageUrls = await storageService.uploadImage(descImageBlob);
    }
    var indexData = question.toMap();
    if(imageUrls != null) {
      downloadUrl = imageUrls['downloadUrl'];
      serverUrl = imageUrls['serverUrl'];
      indexData['imageUrl'] = downloadUrl;
      indexData['bitbucketUrl'] = serverUrl;
    }
    if(descImageUrls != null) {
      downloadUrl = descImageUrls['downloadUrl'];
      serverUrl =  descImageUrls['serverUrl'];
      indexData['descImageUrl'] = downloadUrl;
      indexData['descBitbucketUrl'] = serverUrl;
    }
    try {
      await mobFirestore
          .collection('pendingQuestion').add(indexData)
          .then((onValue) async {
        blReturn = true;
      });
    } catch (exception) {
      print(exception);
    }
    return blReturn;
  }

  Future approvePendingQuestion(Question question) async {
    var indexData = question.toMap();
    indexData['lastUpdate'] = DateTime.now();
    indexData['status'] = textRes.QUESTION_STATUS_OPTIONS[2];
    int nextID = await getTotalQuestion();
    indexData['id'] = nextID.toString();
    try {
      mobFirestore
          .collection('question').document(indexData['id'])
          .setData(indexData).then((data) {
            return addCategoriesQuestionList(question.tags[0], indexData['id']).then((dummy) {
              return mobFirestore
                .collection('pendingQuestion').document(question.id).delete();
            });
          });
    } catch (exception) {
      print(exception);
    }    
  }

  Future rejectPendingQuestion(Question question) async {
    var indexData = question.toMap();
    indexData['lastUpdate'] = DateTime.now();
    indexData['status'] = textRes.QUESTION_STATUS_OPTIONS[1];
    try {
      await mobFirestore
          .collection('pendingQuestion').document(question.id)
          .setData(indexData);
    } catch (exception) {
      print(exception);
    }    
  }  

  Future<void> addCategoriesQuestionList(String category, String questionID) async{
    int newValue = 1;
    try {
      //if (!kIsWeb) {
        //For mobile
        MobFirestore.DocumentReference docRef = 
            mobFirestore.collection('QuizHome').document('fIhrNErzeiRP6UR9Y2z4');
        MobFirestore.DocumentReference questionSetRef = 
            docRef.collection('questionSet').document(category);     
        return questionSetRef.get().then((questionSetSnap) {
          Map<String, dynamic> questionSetMap;
          if(questionSetSnap.exists) {
            questionSetMap = questionSetSnap.data;
            questionSetMap['questions'].add(questionID);
            newValue = questionSetMap['questions'].length;
          } else {
            questionSetMap = Map<String, dynamic>();
            questionSetMap['questions'] = <String>[questionID];
          }
          return questionSetRef.setData(questionSetMap).then((dummy) {
            return docRef.get().then((value) {
                var data = value.data;
                data['totalQuestion']++;
                data['categories'][category]['count'] = newValue;
                value.data['categories'][category]['count'] = newValue;
                return docRef.setData(data);
            });
          });
        });
    } catch (exception) {
      print(exception);
    }
  }

  Future<Map<String, dynamic>> getCategories() async{
    Map<String, dynamic> rv ;
    try {
      return mobFirestore
          .collection('QuizHome').document('fIhrNErzeiRP6UR9Y2z4').get().then((value) {
            rv = value.data['categories'];
            return rv;
          });
    } catch (exception) {
      print(exception);
    }
  }

  Future<int> getTotalQuestion() async{
    int rv = -1;
    try {
      return mobFirestore
          .collection('QuizHome').document('fIhrNErzeiRP6UR9Y2z4').get().then((value) {
            rv = value.data['totalQuestion'];
            return rv;
          }); 
    } catch (exception) {
      print(exception);
      return rv;
    }    
  }

  Future<List<String>> getRandomQuestionID(String category, int numOfQuestion) async{
    if(category.length == 0) {
      return getTotalQuestion().then((totalQuestion) {
        if(numOfQuestion > totalQuestion) {
          numOfQuestion = totalQuestion;
        }
        Set<String> randomQuestionIndexes= Set<String>();
        Random rng = new Random();      
        while(randomQuestionIndexes.length != numOfQuestion) {
          String index = rng.nextInt(totalQuestion).toString();
          if(!randomQuestionIndexes.contains(index)) {
            print("question id $index");
            randomQuestionIndexes.add(index);
          }
        }
        // TODO for category include
        return randomQuestionIndexes.toList(); 
      });
    } else {
      return getQuestionIDsByCat(category).then((questions) {
        if(numOfQuestion > questions.length) {
          numOfQuestion = questions.length;
        }
        Set<String> randomQuestionIndexes= Set<String>();
        Random rng = new Random();      
        while(randomQuestionIndexes.length != numOfQuestion) {
          String id = questions[rng.nextInt(numOfQuestion)];
          if(!randomQuestionIndexes.contains(id)) {
            print("question id $id");
            randomQuestionIndexes.add(id);
          }
        }
        // TODO for category include
        return randomQuestionIndexes.toList(); 
      });
    }
  }

  Future<List<String>> getQuestionIDsByCat(String category) async {
    List<String> rv = [];
    if(category.length != 0) {
      try {
        return mobFirestore
            .collection('QuizHome').document('fIhrNErzeiRP6UR9Y2z4')
            .collection('questionSet').document(category).get().then((value) {
              List<dynamic> temp = value.data['questions'];
              rv = temp.cast<String>();
              return rv;
            });
      } catch (exception) {
        print(exception);
        return rv;
      }  
    } else {
      return null;
    }
  }

  Future<Question> getQuestion(String id) {
    try {
      return mobFirestore
          .collection('question').document(id)
          .get().then((data) {
            if(data.exists) {
              Question rv = Question.fromMap(data.data);
              return rv;
            } else {
              return null;
            }
          });
    } catch (exception) {
      print(exception);
    }    
  }

Future getQuestionList(String category, Function returnQuestionList) async {
    List<Question> questions = [];
    try {
      var mobQuery = mobFirestore.collection('question').where("tags", arrayContains: category);
      return mobQuery.snapshots().listen((event) {
        event.documents.forEach((doc) {
          if(doc.exists) {
            Map data = doc.data;
            //print(data);
            data['id'] = doc.documentID;
            Question question = Question.fromMap(data); 
            questions.add(question);
          }
        });
        returnQuestionList(questions);
        return;
      });
    } catch (exception) {
      print(exception);
      returnQuestionList(questions);
    }
  }

  Future getQuestionListByUserId(String userId, Function returnQuestionList) async {
    List<Question> questions = [];
    try {
      var mobQuery = mobFirestore.collection('question').where("createdUserid", isEqualTo: userId);
      mobQuery.snapshots().listen((event) {
        event.documents.forEach((doc) {
          if(doc.exists) {
            Map data = doc.data;
            data['id'] = doc.documentID;
            Question question = Question.fromMap(data); 
            questions.add(question);
          }
        });
        returnQuestionList(questions);
      });
    } catch (exception) {
      print(exception);
      returnQuestionList(questions);
    }
  }
}