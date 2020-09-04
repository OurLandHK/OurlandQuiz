import 'dart:async';
import 'dart:async';
import 'dart:html';
import 'dart:io';
import 'dart:math';

import 'package:OurlandQuiz/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/services.dart';


import 'package:image_picker/image_picker.dart' as MobImagePicker;
import 'package:image_picker_web/image_picker_web.dart' as WebImagePicker;

import 'package:shared_preferences/shared_preferences.dart';

import '../helper/stringHelper.dart';
import '../helper/uiHelper.dart';
import '../models/textRes.dart';
import '../services/questionService.dart';
import '../services/auth.dart';
import '../services/examService.dart';
import '../models/question.dart';
import '../models/examResult.dart';
import '../widgets/questionWidget.dart';
import '../widgets/reportWidget.dart';

//final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class ViewResultScreen extends StatefulWidget {
  final String category;
  final String mode;
  final ExamResult examResult;
  final int rank;
  ViewResultScreen({Key key, @required this.mode, @required this.category, @required this.rank, @required this.examResult});
  //final int totalQuestion = 3;

  @override
  State createState() => new ViewResultState();
}

class ViewResultState extends State<ViewResultScreen> {
  //SharedPreferences prefs;
  //Question _currentQuestion;
  ExamResult _examResult;
  String _newTitleLabel;
  String _username;
  int rank;
  List<Question> _questions = [];
  List<String> _questionIDs = [];

  @override
  void initState() {
    super.initState();
    if(widget.examResult != null) {
      rank = widget.rank;
      _examResult = widget.examResult;
      updateUI();
      updateUser();
    } else {
      initPlatformState();
    }
    //_sendButtonText = new Text(textRes.LABEL_MISSING_NEW_QUESTION);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    examService.getResultList(widget.mode, widget.category, null, this.updateResultList);
  }

  void updateResultList(List<ExamResult> examResults) {
    examResults.sort((a, b) => a.totalTimeIn100ms().compareTo(b.totalTimeIn100ms()));
    int rank = widget.rank;
    if(examResults.length > widget.rank) {
      rank = examResults.length;
    }
    _examResult = examResults[rank-1];
    updateUI();
    updateUser();    
}

  Future<void> updateUser() async {
    List<Question> qList = [];
    _questionIDs.forEach((id) async {
      Question question = await questionService.getQuestion(id);
      qList.add(question);
    });
    authService.getUser(_examResult.userId).then((value) {
      setState(() {
        this._questions = qList;
        this._username = value.name;
      });
    });
  }

  void updateUI() {
    int totalTime = _examResult.totalTimeIn100ms();
    int correct = 0;
    _examResult.results.forEach((element) {
      _questionIDs.add(element.questionId);
      if(element.correct) {
        correct++;
      }
    });
    _newTitleLabel = "第" + widget.rank.toString() + "位     " + " ${textRes.LABEL_TIME} ${totalTime/10}" +
        " ${textRes.LABEL_RESULT} $correct/${_examResult.results.length}";
  }

  Future<bool> onBackPress() {
    Navigator.pop(context);
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    Widget body = Container();
    if(this._questions.length > 0) {
      body = new WillPopScope(
        child: ReportWidget(this._questions, _examResult),
        onWillPop: onBackPress,
      );
    }
    return new Scaffold(
//      key: _scaffoldKey,
      appBar: new AppBar(
        backgroundColor: Colors.yellow,
        title: new Text(
          _newTitleLabel,
          style: TextStyle(/*color: primaryColor,*/ fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0.7,
        actionsIconTheme: Theme.of(context).primaryIconTheme,
      ),
      body: Container(
        color: Colors.yellow,
        //child: new Container(),
        child: SafeArea(
          top: false,
          bottom: false,
          child: body
        ),

      ),
    ); 
  } 
}