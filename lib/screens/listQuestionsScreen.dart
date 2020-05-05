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
import '../models/question.dart';
import '../widgets/questionWidget.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class ListQuestionsScreen extends StatefulWidget {
  final String category;
  final String userId;
  ListQuestionsScreen({Key key, @required this.category, @required this.userId});

  @override
  State createState() => new ListQuestionsState();
}

class ListQuestionsState extends State<ListQuestionsScreen> {
  //SharedPreferences prefs;
  //Question _currentQuestion;
  String _newTitleLabel;

  int questionIndex = 0;
  List<String> _questionIDs;
  int _color = 9;
  List<Question> _questions = [];
  List<List<String>> _userAnswers = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if(widget.category != null) {
      _newTitleLabel = widget.category;
      questionService.getQuestionList(widget.category, this.updateQuestionList);
    } else {
       _newTitleLabel = widget.userId;
      questionService.getQuestionListByUserId(widget.userId, this.updateQuestionList);     
    }
    //initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    //if (!mounted) return;
  }

  void updateQuestionList(List<Question> questions) {
    setState(() {
      this._questions = questions;
    });    
  }

  Future<bool> onBackPress() {
    Navigator.pop(context);
    return Future.value(false);
  }


  @override
  Widget build(BuildContext context) {
    Widget body = new WillPopScope(
      child: Column(
        children: <Widget>[            
          new Form(
            key: _formKey,
            autovalidate: true,
            child: report(context)
          )
        ],
      ),
      onWillPop: onBackPress,
    );
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        backgroundColor: MEMO_COLORS[_color],
        title: new Text(
          _newTitleLabel,
          style: TextStyle(/*color: primaryColor,*/ fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0.7,
        actionsIconTheme: Theme.of(context).primaryIconTheme,
      ),
      body: Container(
        color: MEMO_COLORS[_color],
        //child: new Container(),
        child: SafeArea(
          top: false,
          bottom: false,
          child: SingleChildScrollView(
            child: body
          ),
        ),

      ),
    ); 
  }

  Widget report(BuildContext context) {

    Widget buildItem(Question question, List<String> userAnswer, BuildContext context) {
      Widget rv = QuestionWidget(question: question, pending: false /*, userAnswer: userAnswer*/);
      return rv;
    }    


    List<Widget> buildGrid(BuildContext context) {
      List<Widget> _gridItems = [];
      for(int i = 0; i < _questions.length; i++) {
        _gridItems.add(buildItem(_questions[i], /*this._userAnswers[i]*/ null, context));
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