import 'dart:async';
import 'dart:async';
import 'dart:html';
import 'dart:io';
import 'dart:math';

import 'package:OurlandQuiz/main.dart';
import 'package:OurlandQuiz/models/examResult.dart';
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
import '../services/examService.dart';
import '../services/auth.dart';
import '../models/examResult.dart';
import '../models/userModel.dart';
import '../widgets/resultWidget.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class ListResultScreen extends StatefulWidget {
  final String category;
  final String mode;
  final String userid;
  ListResultScreen({Key key, @required this.mode ,@required this.category, @required this.userid});

  @override
  State createState() => new ListResultState();
}

class ListResultState extends State<ListResultScreen> {
  //SharedPreferences prefs;
  //Question _currentQuestion;
  String _newTitleLabel;
  int _color = 9;
  List<ExamResult> _examResults = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _newTitleLabel = widget.category;
    examService.getResultList(widget.mode, widget.category, widget.userid, this.updateResultList);
    //initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    //if (!mounted) return;
  }

  void updateResultList(List<ExamResult> examResults) {
    examResults.sort((a, b) => a.totalTimeIn100ms().compareTo(b.totalTimeIn100ms()));
    setState(() {
      this._examResults = examResults;
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

    Widget buildItem(int rank, ExamResult examResult, BuildContext context) {
      Widget rv = ResultWidget(category: widget.category, examResult: examResult, rank: rank);
      return rv;
    }    


    List<Widget> buildGrid(BuildContext context) {
      List<Widget> _gridItems = [];
      for(int i = 0; i < _examResults.length; i++) {
        _gridItems.add(buildItem(i+1, _examResults[i],context));
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