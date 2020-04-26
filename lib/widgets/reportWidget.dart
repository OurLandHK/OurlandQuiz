import 'dart:async';
import 'dart:async';
import 'dart:html';
import 'dart:io';
import 'dart:math';

import 'package:OurlandQuiz/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import '../models/question.dart';
import '../models/examResult.dart';
import '../widgets/questionWidget.dart';
import '../services/auth.dart';

class ReportWidget extends StatelessWidget {
  ExamResult examResult;
  List<Question> questions;
  ReportWidget(@required this.questions, @required this.examResult);
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
          top: false,
          bottom: false,
          child: SingleChildScrollView(
              child: report(context)
            ));
  }

  Widget report(BuildContext context) {
    Widget buildItem(Question question, Result result, BuildContext context) {
      Widget rv; 
      bool currentUser = false;
      if(user.id == examResult.userId) {
        currentUser = true;
      }
      rv = QuestionWidget(question: question, pending: false, result: result, isCurrentUser: currentUser);
      return rv;
    }    


    List<Widget> buildGrid(BuildContext context) {
      List<Widget> _gridItems = [Text("ReportTotal Time"),
          Text("Total Time: ${this.examResult.totalTimeIn100ms()/10}"),
          const SizedBox(height: 12.0),];
      for(int i = 0; i < questions.length; i++) {
        _gridItems.add(buildItem(questions[i], this.examResult.results[i], context));
      }
      return _gridItems;
    }  

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: 
          buildGrid(context)
        ,
      )
    );
  }
}