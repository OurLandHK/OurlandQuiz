import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:OurlandQuiz/models/examResult.dart';
import 'package:OurlandQuiz/models/textRes.dart';
//import 'package:image/image.dart' as Img;


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

  static String _getDocumentId(String mode, String category) {
    String gameModeSuffix = "";
    if(mode != GameModes[TIME_ATTACK_GAME_INDEX].label) {
      for(int i = 1; i < GameModes.length; i++) {
        if(mode == GameModes[i].label) {
          gameModeSuffix = "_" + i.toString();
        }
      }
    }
    String documentId = category+gameModeSuffix;
    return documentId;
  }

  Future<void> validateExamResult(String validateKey, ExamResult examResult) async {
    await mobFirestore.collection('check').document(validateKey).setData(examResult.toMap());
  }

  Future<void> submitExamResult(String mode, String category, User user,ExamResult examResult) async{
    try {
      // update for top 20
       // update for global top 10 record
        String documentId = _getDocumentId(mode, category);
        MobFirestore.DocumentReference examResultRef = 
            mobFirestore
            .collection('ExamResult').document(documentId);           
        await _updateTopXExamResult(examResultRef, examResult, 20);
        // update for user's top 10 record
        MobFirestore.DocumentReference userExamResultRef = 
            mobFirestore.collection('User').document(user.id).collection('ExamResult').document(documentId );    
        await _updateTopXExamResult(userExamResultRef, examResult, 10);

        // update question play record
        var questionCollectionRef = 
            mobFirestore.collection('question');
        examResult.results.forEach((result) {
          var firstResultCollectionRef = 
            questionCollectionRef.document(result.questionId).collection('userFirstResult');
          firstResultCollectionRef.document(user.id).get().then((value) {
            if(!value.exists) {
              firstResultCollectionRef.document(user.id).setData(result.toMap());
              firstResultCollectionRef.document('summary').get().then((summary) {
                Map<String, dynamic> summaryData;
                if(summary.exists) {
                  summaryData = summary.data;              
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
                firstResultCollectionRef.document('summary').setData(summaryData);
              });
            }
            if(user.updateQuestionIDs(result.questionId)) {
              authService.updateUser(user);
            }
          });
        });

    } catch (exception) {
      print(exception);
    }
  }

  static Future _updateTopXExamResult(MobFirestore.DocumentReference examResultRef, ExamResult examResult, int topX) async {
    // find the smallest record;
    examResultRef.get().then((examResultSnap) async {
      Map<String, dynamic> examResultMap;
      if(examResultSnap.exists) {
        examResultMap = examResultSnap.data;
        if(examResultMap['record'].length >= topX) {
          int removeIndex = -1;
          int completeTime = examResult.totalTimeIn100ms();
          for(int i = 0; i < examResultMap['record'].length; i++) {
            ExamResult tempResult = ExamResult.fromMap(examResultMap['record'][i]);
            if(tempResult.totalTimeIn100ms() > completeTime && examResult.results.length > tempResult.results.length ) {
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
        await examResultRef.setData(examResultMap);
      }
    }); 
  }

  Future getResultList(String mode, String category, String userid, Function returnResultList) async {
    List<ExamResult> examResults = [];
    try {
      //if (!kIsWeb) {
        //For mobile
        String documentId = _getDocumentId(mode, category);
        MobFirestore.DocumentReference mobQuery;
        if(userid == null) {
          mobQuery = mobFirestore.collection('ExamResult').document(documentId);
        } else {
          mobQuery = mobFirestore.collection('User').document(userid).collection('ExamResult').document(documentId);
        }
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
    } catch (exception) {
      print(exception);
      returnResultList(examResults);
    }
  }
}