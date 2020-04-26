import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:OurlandQuiz/models/examResult.dart';
import 'package:image/image.dart' as Img;


import 'service.dart';
import 'auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as MobFirebaseStorage;
import 'package:cloud_firestore/cloud_firestore.dart' as MobFirestore;
import 'package:firebase/firebase.dart' as WebFirebase;
import 'package:flutter/foundation.dart';
import '../main.dart';
import '../models/examResult.dart';
import '../models/userModel.dart';

ExamService examService = new ExamService();

class ExamService {
  ExamService();

  Future<void> submitExamResult(String category, User user,ExamResult examResult) async{
    try {
      if (!kIsWeb) {
        //For mobile
        /*
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
        */
      } else {
        //For Web
        var examResultRef = 
            webFirestore
            .collection('ExamResult').doc(category);    
        var questionCollectionRef = 
            webFirestore.collection('question');
        // find the smallest record;
        examResultRef.get().then((examResultSnap) async {
          Map<String, dynamic> examResultMap;
          if(examResultSnap.exists) {
            examResultMap = examResultSnap.data();
            if(examResultMap['record'].length >= 20) {
              int removeIndex = -1;
              int completeTime = examResult.totalTimeIn100ms();
              for(int i = 0; i < examResultMap['record'].length; i++) {
                ExamResult tempResult = ExamResult.fromMap(examResultMap['record'][i]);
                if(tempResult.totalTimeIn100ms() > completeTime) {
                  removeIndex = i;
                  completeTime = tempResult.totalTimeIn100ms();
                }
              }
              if(removeIndex != -1) {
                examResultMap['record'].removeAt(removeIndex);
              } else {
                examResultMap = null;
              }
            }
          } else {
            examResultMap = Map<String, dynamic>();
            examResultMap['record'] = [];
          }
          if(examResultMap != null) {
            examResultMap['record'].add(examResult.toMap());
            await examResultRef.set(examResultMap);
          }
        });   
        // update all user's play record
        examResult.results.forEach((result) {
          var firstResultCollectionRef = 
            questionCollectionRef.doc(result.questionId).collection('userFirstResult');
          firstResultCollectionRef.doc(user.id).get().then((value) {
            if(!value.exists) {
              firstResultCollectionRef.doc(user.id).set(result.toMap());
              firstResultCollectionRef.doc('summary').get().then((summary) {
                Map<String, dynamic> summaryData;
                if(summary.exists) {
                  summaryData = summary.data();              
                  summaryData['total']++;
                } else {
                  summaryData = new Map<String, dynamic>();
                  summaryData['firstPassCount'] = 0;
                  summaryData['firstPassAverageTime'] = 0;
                  summaryData['total'] = 1;
                }
                if(result.correct) {
                  double firstPassAverageTime = summaryData['firstPassAverageTime'];
                  firstPassAverageTime *= summaryData['firstPassCount'];
                  firstPassAverageTime += result.timeIn100ms;
                  summaryData['firstPassCount']++;
                  summaryData['firstPassAverageTime'] = firstPassAverageTime / summaryData['firstPassCount'];
                }
                firstResultCollectionRef.doc('summary').set(summaryData);
              });
            }
            if(user.updateQuestionIDs(result.questionId)) {
              authService.updateUser(user);
            }
          });
        });
      }     
    } catch (exception) {
      print(exception);
    }
  }

  Future getResultList(String category, Function returnResultList) async {
    List<ExamResult> examResults = [];
    try {
      if (!kIsWeb) {
        //For mobile
        var mobQuery = mobFirestore.collection('ExamResult').document(category);
        return mobQuery.get().then((value) {
          if(value.exists) {
            Map<String, dynamic> examResultMap = value.data;
            examResultMap['record'].forEach((record) {
              ExamResult examResult = ExamResult.fromMap(record);
              examResults.add(examResult);
            });
          }
          returnResultList(examResults);
        });
      } else {
        //For Web
  //      WebFirestore.SetOptions options;
        var webQuery = webFirestore.collection('ExamResult').doc(category);
        webQuery.get().then((value) {
          if(value.exists) {
            Map<String, dynamic> examResultMap = value.data();
            examResultMap['record'].forEach((record) {
              ExamResult examResult = ExamResult.fromMap(record);
              examResults.add(examResult);
            });
          }
          returnResultList(examResults);
        });
      }     
    } catch (exception) {
      print(exception);
      returnResultList(examResults);
    }
  }
}