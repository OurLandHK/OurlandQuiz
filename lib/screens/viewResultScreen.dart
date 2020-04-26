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

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class ViewResultScreen extends StatefulWidget {
  final ExamResult examResult;
  final int rank;
  ViewResultScreen({Key key, @required this.rank, @required this.examResult});
  //final int totalQuestion = 3;

  @override
  State createState() => new ViewResultState();
}

class ViewResultState extends State<ViewResultScreen> {
  //SharedPreferences prefs;
  //Question _currentQuestion;
  String _newTitleLabel;
  String _username;
  List<Question> _questions = [];
  List<String> _questionIDs = [];

  @override
  void initState() {
    super.initState();
    int totalTime = widget.examResult.totalTimeIn100ms();
    int correct = 0;
    widget.examResult.results.forEach((element) {
      _questionIDs.add(element.questionId);
      if(element.correct) {
        correct++;
      }
    });
    _newTitleLabel = widget.rank.toString() + " Time: ${totalTime/10}" +
        "  Correct $correct/${widget.examResult.results.length}";
    initPlatformState();
    //_sendButtonText = new Text(textRes.LABEL_MISSING_NEW_QUESTION);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    //if (!mounted) return;
    List<Question> qList = [];
    _questionIDs.forEach((id) async {
      Question question = await questionService.getQuestion(id);
      qList.add(question);
    });
    authService.getUser(widget.examResult.userId).then((value) {
      setState(() {
        this._questions = qList;
        this._username = value.name;
      });
    });
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
        child: ReportWidget(this._questions, widget.examResult),
        onWillPop: onBackPress,
      );
    }
    return new Scaffold(
      key: _scaffoldKey,
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