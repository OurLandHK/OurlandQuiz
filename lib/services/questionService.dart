import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:image/image.dart' as Img;


import 'service.dart';
import 'package:firebase_storage/firebase_storage.dart' as MobFirebaseStorage;
import 'package:cloud_firestore/cloud_firestore.dart' as MobFirestore;
import 'package:firebase/firebase.dart' as WebFirebase;
import 'package:flutter/foundation.dart';
import '../main.dart';
import '../models/question.dart';
import '../models/textRes.dart';

QuestionService questionService = new QuestionService();

class QuestionService {
  QuestionService();


  Future getPendingQuestionList(String status, Function returnQuestionList) async {
    List<Question> questions = [];
    // TODO
    /*
    if(!_user.sendBroadcastRight) {
      sourceQuery = sourceQuery.where("uid", isEqualTo: _user.uuid);
    }
    */
    try {
      if (!kIsWeb) {
        //For mobile
        var mobQuery = mobFirestore.collection('pendingQuestion').where("status", isEqualTo: status);
        List<MobFirestore.QuerySnapshot> snaps = await mobQuery.snapshots().toList();
        snaps.forEach((element1) {
          element1.documents.forEach((doc) {
            if(doc.exists) {
              Map data = doc.data;
              data['id'] = doc.documentID;
              Question question = Question.fromMap(data); 
              questions.add(question);
            }
          });
        });
        returnQuestionList(questions);
      } else {
        //For Web
  //      WebFirestore.SetOptions options;
        var webQuery = webFirestore.collection('pendingQuestion').where("status", "==", status);
        webQuery.onSnapshot.listen((webSnapshot) {
          webSnapshot.docs.forEach((doc) {
            if(doc.exists) {
              Map data = doc.data();
              data['id'] = doc.id;
              Question question = Question.fromMap(data); 
              questions.add(question);
            }
          });
          returnQuestionList(questions);
        });
      }     
    } catch (exception) {
      print(exception);
      returnQuestionList(questions);
    }
  }

  Future<bool> sendPendingQuestion(Question question, File imageFile) async {
    bool blReturn = false;
    Map imageUrls;
    String downloadUrl;
    String serverUrl;
    if(imageFile != null) {
      imageUrls = await this.uploadImage(imageFile);
    }
    var indexData = question.toMap();
    if(imageUrls != null) {
      downloadUrl = imageUrls['downloadUrl'];
      serverUrl = imageUrls['serverUrl'];
      indexData['imageUrl'] = downloadUrl;
      indexData['bitbucketUrl'] = serverUrl;
    }
    try {
      if (!kIsWeb) {
        //For mobile
        await mobFirestore
            .collection('pendingQuestion').add(indexData)
            .then((onValue) async {
          blReturn = true;
        });
      } else {
        //For Web
        await webFirestore
            .collection('pendingQuestion').add(indexData)
            .then((onValue) async {
          blReturn = true;
        });
      }     
    } catch (exception) {
      print(exception);
    }
    return blReturn;
  }

  Future approvePendingQuestion(Question question) async {
    var indexData = question.toMap();
    indexData['status'] = textRes.QUESTION_STATUS_OPTIONS[2];
    int nextID = await getTotalQuestion();
    indexData['id'] = nextID.toString();
    try {
      if (!kIsWeb) {
        //For mobile
        mobFirestore
            .collection('question').document(indexData['id'])
            .setData(indexData).then((data) {
              return addCategoriesQuestionList(question.tags[0], indexData['id']).then((dummy) {
                return mobFirestore
                  .collection('pendingQuestion').document(question.id).delete();
              });
            });
      } else {
        //For Web
        await webFirestore
            .collection('question').doc(indexData['id'])
            .set(indexData).then((value) {
              return addCategoriesQuestionList(question.tags[0], indexData['id']).then((dummy) {
                return webFirestore
                  .collection('pendingQuestion').doc(question.id).delete();
              });
            });
      }     
    } catch (exception) {
      print(exception);
    }    
  }

  Future rejectPendingQuestion(Question question) async {
    var indexData = question.toMap();
    indexData['status'] = textRes.QUESTION_STATUS_OPTIONS[1];
    try {
      if (!kIsWeb) {
        //For mobile
        await mobFirestore
            .collection('pendingQuestion').document(question.id)
            .setData(indexData);
      } else {
        //For Web
        await webFirestore
            .collection('pendingQuestion').doc(question.id)
            .set(indexData);
      }     
    } catch (exception) {
      print(exception);
    }    
  }  

  Future<void> addCategoriesQuestionList(String category, String questionID) async{
    int newValue = 1;
    try {
      if (!kIsWeb) {
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
      } else {
        //For Web
        var docRef = 
            webFirestore
            .collection('QuizHome').doc('fIhrNErzeiRP6UR9Y2z4');
        var questionSetRef = 
            docRef.collection('questionSet').doc(category);
        return questionSetRef.get().then((questionSetSnap) {
          print("${questionSetSnap.exists}");
          Map<String, dynamic> questionSetMap;
          if(questionSetSnap.exists) {
            questionSetMap = questionSetSnap.data();
            questionSetMap['questions'].add(questionID);
            newValue = questionSetMap['questions'].length;
          } else {
            questionSetMap = Map<String, dynamic>();
            questionSetMap['questions'] = <String>[questionID];
          }
          return questionSetRef.set(questionSetMap).then((dummy) {
            return docRef.get().then((value) {
                var data = value.data();
                data['totalQuestion']++;
                data['categories'][category]['count'] = newValue;
                return docRef.set(data);
            });
          });
        });    
      }     
    } catch (exception) {
      print(exception);
    }
  }

  Future<Map<String, dynamic>> getCategories() async{
    Map<String, dynamic> rv ;
    try {
      if (!kIsWeb) {
        //For mobile
        return mobFirestore
            .collection('QuizHome').document('fIhrNErzeiRP6UR9Y2z4').get().then((value) {
              rv = value.data['categories'];
              return rv;
            });
      } else {
        //For Web
        return webFirestore
            .collection('QuizHome').doc('fIhrNErzeiRP6UR9Y2z4').get().then((value) {
              rv = value.data()['categories'];
              return rv;
            });
      }     
    } catch (exception) {
      print(exception);
    }
  }

  Future<int> getTotalQuestion() async{
    int rv = -1;
    try {
      if (!kIsWeb) {
        //For mobile
        return mobFirestore
            .collection('QuizHome').document('fIhrNErzeiRP6UR9Y2z4').get().then((value) {
              rv = value.data['totalQuestion'];
              return rv;
            });
      } else {
        //For Web
        return webFirestore
            .collection('QuizHome').doc('fIhrNErzeiRP6UR9Y2z4').get().then((value) {
              rv = value.data()['totalQuestion'];
              return rv;
            });
      }     
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
        if (!kIsWeb) {
          //For mobile
          return mobFirestore
              .collection('QuizHome').document('fIhrNErzeiRP6UR9Y2z4')
              .collection('questionSet').document(category).get().then((value) {
                List<dynamic> temp = value.data['questions'];
                rv = temp.cast<String>();
                return rv;
              });
        } else {
          //For Web
          return webFirestore
              .collection('QuizHome').doc('fIhrNErzeiRP6UR9Y2z4')
              .collection('questionSet').doc(category).get().then((value) {
                List<dynamic> temp = value.data()['questions'];
                rv = temp.cast<String>();
                return rv;
              });
        }     
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
      if (!kIsWeb) {
        //For mobile
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
      } else {
        //For Web
        return webFirestore
            .collection('question').doc(id)
            .get().then((data) {
              //print("$id ${data.exists}");
              if(data.exists) {
                Question rv = Question.fromMap(data.data());
                return rv;
              } else {
                return null;
              }
            });
      }     
    } catch (exception) {
      print(exception);
    }    
  }

Future getQuestionList(String category, Function returnQuestionList) async {
    List<Question> questions = [];
    try {
      if (!kIsWeb) {
        //For mobile
        var mobQuery = mobFirestore.collection('question').where("tags", arrayContains: category);
        List<MobFirestore.QuerySnapshot> snaps = await mobQuery.snapshots().toList();
        snaps.forEach((element1) {
          element1.documents.forEach((doc) {
            if(doc.exists) {
              Map data = doc.data;
              data['id'] = doc.documentID;
              Question question = Question.fromMap(data); 
              questions.add(question);
            }
          });
        });
        returnQuestionList(questions);
      } else {
        //For Web
  //      WebFirestore.SetOptions options;
        var webQuery = webFirestore.collection('question').where("tags", "array-contains", category);
        webQuery.onSnapshot.listen((webSnapshot) {
          webSnapshot.docs.forEach((doc) {
            if(doc.exists) {
              Map data = doc.data();
              data['id'] = doc.id;
              Question question = Question.fromMap(data); 
              questions.add(question);
            }
          });
          returnQuestionList(questions);
        });
      }     
    } catch (exception) {
      print(exception);
      returnQuestionList(questions);
    }
  }

    Future getQuestionListByUserId(String userId, Function returnQuestionList) async {
    List<Question> questions = [];
    // TODO
    try {
      if (!kIsWeb) {
        //For mobile
        var mobQuery = mobFirestore.collection('question').where("createdUserid", isEqualTo: userId);
        List<MobFirestore.QuerySnapshot> snaps = await mobQuery.snapshots().toList();
        snaps.forEach((element1) {
          element1.documents.forEach((doc) {
            if(doc.exists) {
              Map data = doc.data;
              data['id'] = doc.documentID;
              Question question = Question.fromMap(data); 
              questions.add(question);
            }
          });
        });
        returnQuestionList(questions);
      } else {
        //For Web
  //      WebFirestore.SetOptions options;
        var webQuery = webFirestore.collection('question').where("createdUserid", "==", userId);
        webQuery.onSnapshot.listen((webSnapshot) {
          webSnapshot.docs.forEach((doc) {
            if(doc.exists) {
              Map data = doc.data();
              data['id'] = doc.id;
              Question question = Question.fromMap(data); 
              questions.add(question);
            }
          });
          returnQuestionList(questions);
        });
      }     
    } catch (exception) {
      print(exception);
      returnQuestionList(questions);
    }
  }

  Future<Map> uploadImage(File imageFile) async {
    File uploadImage = imageFile;
    String fileName = 'photo/' + DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';
    List<int> blob = uploadImage.readAsBytesSync();
    
    Img.Image originImage = Img.decodeImage(blob);
    Img.Image image = originImage;

    bool newImage = false;
    if(originImage.width > 1280) {
      image = Img.copyResize(originImage, width: 1280);
      newImage = true;
    } else {
      if(originImage.height > 1280) {
        int width = (originImage.width * 1280 / originImage.height).round();
        image = Img.copyResize(originImage, width: width, height: 1280);  
        newImage = true;     
      }
    }

    if(newImage) {
  //    uploadImage = new File('temp.png').writeAsBytesSync(Img.encodePng(image));
//      blob = new Img.PngEncoder({level: 3}).encodeImage(image);
      blob = new Img.JpegEncoder(quality: 75).encodeImage(image);
    }
    Map rv = Map();
    if (!kIsWeb) {
      //For mobile
      MobFirebaseStorage.StorageReference mobUploadFileRef = mobStorageRef.child(fileName);
      MobFirebaseStorage.StorageUploadTask mobUploadTask = mobUploadFileRef.putData(blob);
      MobFirebaseStorage.StorageTaskSnapshot mobStorageTaskSnapshot = await mobUploadTask.onComplete;
      String downloadUrl = await mobStorageTaskSnapshot.ref.getDownloadURL();
      String serverPath = await mobStorageTaskSnapshot.ref.getPath();
      String bucketPath = await mobStorageTaskSnapshot.ref.getBucket();   
      rv['downloadUrl'] = downloadUrl;
      rv['serverUrl'] = "gs://" + bucketPath + "/" + serverPath;
    } else {
      WebFirebase.UploadMetadata uploadMetadata = WebFirebase.UploadMetadata(contentType: 'image/jpeg');
      WebFirebase.StorageReference webUploadFileRef = webStorageRef.child(fileName);
      WebFirebase.UploadTask uploadTask = webUploadFileRef.put(blob, uploadMetadata);
      WebFirebase.UploadTaskSnapshot webStorageTaskSnapshot = await uploadTask.future;
      Uri downloadUri = await webStorageTaskSnapshot.ref.getDownloadURL();
      String downloadUrl = downloadUri.toString();
      String bucketFullPath = webStorageTaskSnapshot.ref.toString(); 
      rv['downloadUrl'] = downloadUrl;
      rv['serverUrl'] = bucketFullPath;     
    }
    return rv;
  } 
}