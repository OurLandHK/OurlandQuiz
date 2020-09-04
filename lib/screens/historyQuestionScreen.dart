import 'dart:async';
import 'dart:async';
import 'dart:html';
import 'dart:io';
import 'dart:math';

import 'package:OurlandQuiz/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/services.dart';

import 'package:image_picker/image_picker.dart' as MobImagePicker;
import 'package:image_picker_web/image_picker_web.dart' as WebImagePicker;

import 'package:shared_preferences/shared_preferences.dart';

import '../helper/stringHelper.dart';
import '../helper/uiHelper.dart';
import '../models/textRes.dart';
import '../models/userModel.dart';
import '../services/questionService.dart';
import '../services/auth.dart';
import '../models/question.dart';
import '../widgets/historyWidget.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class HistoryQuestionScreen extends StatelessWidget {
  final List<String> historyIds;
  final Question question;
  HistoryQuestionScreen(
      {Key key, @required this.question, @required this.historyIds});

  @override
  Widget build(BuildContext context) {
    Future<bool> onBackPress() {
      Navigator.pop(context);
      return Future.value(false);
    }
    Widget body = new WillPopScope(
      child: Column(
        children: <Widget>[
          report(context)
        ],
      ),
      onWillPop: onBackPress,
    );
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        backgroundColor: MEMO_COLORS[this.question.color],
        title: new Text(
          this.question.title,
          style:
              TextStyle(/*color: primaryColor,*/ fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0.7,
        actionsIconTheme: Theme.of(context).primaryIconTheme,
      ),
      body: Container(
        color: MEMO_COLORS[this.question.color],
        child: SafeArea(
          top: false,
          bottom: false,
          child: SingleChildScrollView(child: body),
        ),
      ),
    );
  }

  Widget report(BuildContext context) {
    Widget buildItem(String id, BuildContext context) {
      Widget rv = HistoryWidget(
          question: question, id: id);
      return rv;
    }

    List<Widget> buildGrid(BuildContext context) {
      List<Widget> _gridItems = [];
      for (int i = 0; i < historyIds.length; i++) {
        _gridItems.add(
            buildItem(historyIds[i], context));
      }
      return _gridItems;
    }

    return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: buildGrid(context),
        ));
  }
}
