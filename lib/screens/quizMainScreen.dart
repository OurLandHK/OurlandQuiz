import 'package:OurlandQuiz/screens/addNewsScreen.dart';
import 'package:OurlandQuiz/services/questionService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import '../main.dart';
import 'quizGameScreen.dart';
import '../widgets/categoryMemo.dart';
import '../models/textRes.dart';
import '../models/news.dart';
import '../services/auth.dart';
import './layoutTemplate.dart';
import './addNewsScreen.dart';
import '../widgets/newsWidget.dart';

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
  List<News> _newsList = [];
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
  }

  void _onTap(String category) async {
    layoutTemplate.showNaviBar(false);
    Navigator.push(context, 
      MaterialPageRoute(
        builder: (context) =>  QuizGameScreen(category: category)
      ),
    );

    /*
    Navigator.of(context).push(
      new MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return QuizGameScreen(category: category);
        },
      ),
    );
    */
  }

  void _addNews(String dummy) async {
    showDialog<void>(
      context: context,
      //barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AddNewsScreen();
      }); 
  }

  Widget gameSet(BuildContext context) {
    List<Widget> buttonWidgets = [
      Text(
            textRes.LABEL_WELCOME_BACK + user.name,
            style: TextStyle(/*color: primaryColor,*/ fontWeight: FontWeight.bold),
          ),
      NewsWidget(),
      CategoryMemo("", _onTap, ["${textRes.LABEL_TOTAL_QUESTION} : $_totalQuestion"])
    ];
      
    quizCategories.forEach((category) {
      int totalQuestion = _totalQuestion;
      if(category.length != 0) {
        totalQuestion = categories[category]['count'];
      }
      buttonWidgets.add(const SizedBox(height: 5.0));
      buttonWidgets.add(CategoryMemo(category, _onTap, ["${textRes.LABEL_TOTAL_QUESTION} : $totalQuestion"]));
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
