import 'package:OurlandQuiz/services/questionService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import '../main.dart';
import 'quizGameScreen.dart';
import '../models/textRes.dart';
import '../services/auth.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class QuizMainScreen extends StatefulWidget {
  QuizMainScreen({Key key});

  @override
  State createState() => new QuizMainState();
}

class QuizMainState extends State<QuizMainScreen> {
  final ScrollController listScrollController = new ScrollController();

  List<DropdownMenuItem<String>> _tagDropDownMenuItems;
  List<String> quizCategories;
  int _totalQuestion = 0;

  @override
  void initState() {
    super.initState();
    quizCategories = categories.keys.toList();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    //if (!mounted) return;
    questionService.getTotalQuestion().then((value) {
      print(value);
      setState(() {
        _totalQuestion = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body = gameSet(context);     
    return Container(
        child: SafeArea(
          top: false,
          bottom: false,
          child: body
        ),
      );
    /* 
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: Column(children: [
          Text(
            textRes.LABEL_RECENT_RECORD,
            style: TextStyle(/*color: primaryColor,*/ fontWeight: FontWeight.bold),
          ),
          /*
          Text(
            textRes.LABEL_WELCOME_BACK + user.name,
            style: TextStyle(/*color: primaryColor,*/ fontWeight: FontWeight.bold),
          ),
          */
        ]),
        centerTitle: true,
        elevation: 0.7,
        actionsIconTheme: Theme.of(context).primaryIconTheme,
      ),
      body: Container(
        child: SafeArea(
          top: false,
          bottom: false,
          child: body
        ),
      ),
    ); 
    */
  }

  void _onTap(String category) async {
    Navigator.of(context).push(
      new MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return QuizGameScreen(category: category);
        },
      ),
    );
  }

  Widget gameButton(BuildContext context, String category) {
    String title = category;
    int totalQuestion = _totalQuestion;
    if(category.length == 0) {
      title = textRes.LABEL_QUICK_GAME;
    } else {
      totalQuestion = categories[category]['count'];
    }
    Widget rv = GestureDetector(
          onTap: () {_onTap(category);},
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
              padding: EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                //color: MEMO_COLORS[this.question.color],
                border: Border.all(width: 1, color: Colors.grey),
                boxShadow: [
                  new BoxShadow(
                    color: Colors.grey,
                    offset: new Offset(0.0, 2.5),
                    blurRadius: 4.0,
                    spreadRadius: 0.0
                  )
                ],
                //borderRadius: BorderRadius.circular(6.0)
                ),
              child: Column(
                children: [
                  Row(children:[Text(title), Text(" : $totalQuestion")]),
                ]
              ),
            ),
          ),
        );
    return rv;
  }

  Widget gameSet(BuildContext context) {
    List<Widget> buttonWidgets = [
      Text(
            textRes.LABEL_WELCOME_BACK + user.name,
            style: TextStyle(/*color: primaryColor,*/ fontWeight: FontWeight.bold),
          ),
      gameButton(context, "")];
    quizCategories.forEach((category) {
      buttonWidgets.add(const SizedBox(height: 5.0));
      buttonWidgets.add(gameButton(context, category));
    });
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: buttonWidgets
      )
    );
  }
}
