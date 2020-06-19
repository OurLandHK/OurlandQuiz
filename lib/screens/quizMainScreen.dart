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
    Widget body = gameMode(context);     
    return Container(
        child: SafeArea(
          top: false,
          bottom: false,
          child: body
        ),
      );
  }

  Future<bool> onBackPress() {
    Navigator.pop(context);
    return Future.value(false);
  }

  void _onTapGameMode(String mode) async {
    showDialog<void>(
      context: context,
      //barrierDismissible: true, 
      builder: (BuildContext context) {
        return GameModeDialog(mode, quizCategories);
    }); 
  }

  void _addNews(String dummy) async {
    showDialog<void>(
      context: context,
      //barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AddNewsScreen();
      }); 
  }

  Widget gameMode(BuildContext context) {
    List<Widget> buttonWidgets = [Text(
            textRes.LABEL_WELCOME_BACK + user.name,
            style: TextStyle(/*color: primaryColor,*/ fontWeight: FontWeight.bold),
          ),
      NewsWidget(),
    ];
    GameModes.forEach((gameMode) {
      buttonWidgets.add(const SizedBox(height: 5.0));
      buttonWidgets.add(CategoryMemo(gameMode.label, _onTapGameMode, [gameMode.desc]));
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

class GameModeDialog extends StatelessWidget {
  String mode;
  List<String> quizCategories;
  GameModeDialog(this.mode, this.quizCategories) ;
  BuildContext _context;

  void _onTap(String category) async {
    int totalQuestion = 10;
    if(GameModes[FIX_TIME_GAME_INDEX].label == mode) {
      totalQuestion = 30;
    }
    layoutTemplate.showNaviBar(false);
    Navigator.pop(_context);
    Navigator.push(_context, 
      MaterialPageRoute(
        builder: (context) =>  QuizGameScreen(mode: mode, category: category, totalQuestion: totalQuestion)
      ),
    );
  }

  Future<bool> onBackPress() {
    Navigator.pop(_context);
    return Future.value(false);
  }
  

  Widget gameSet(BuildContext context) {
    List<Widget> buttonWidgets = [];
    int totalQuestion = 0;
    quizCategories.forEach((category) {
      int questionCount = categories[category]['count'];
      totalQuestion += categories[category]['count'];
      buttonWidgets.add(const SizedBox(height: 5.0));
      buttonWidgets.add(CategoryMemo(category, _onTap, ["${textRes.LABEL_TOTAL_QUESTION} : $questionCount"]));
    });
    buttonWidgets.insert(0, CategoryMemo("", _onTap, ["${textRes.LABEL_TOTAL_QUESTION} : $totalQuestion"]));
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: buttonWidgets
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    
    Widget body = new WillPopScope(
      child: Container(
        child: SafeArea(
          top: false,
          bottom: false,
          child: gameSet(context)
        )
      ),
      onWillPop: onBackPress,
    );
    return AlertDialog(
        title: Text(
            mode,
            style: TextStyle(/*color: primaryColor,*/ fontWeight: FontWeight.bold),
          ),
        content: SingleChildScrollView(child: body),
        //actions: [_buildSubmit(context)]
    );
  }
}
