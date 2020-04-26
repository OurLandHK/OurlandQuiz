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

class QuizGameScreen extends StatefulWidget {
  final String category;
  QuizGameScreen({Key key, @required this.category});
  final int totalQuestion = 10;
  //final int totalQuestion = 3;

  @override
  State createState() => new QuizGameState();
}

class QuizGameState extends State<QuizGameScreen> {
  //SharedPreferences prefs;
  //Question _currentQuestion;
  String _newTitleLabel;

  int questionIndex = 0;
  List<String> _questionIDs;
  ExamResult _examResult;

  final TextEditingController _textController = new TextEditingController();
  //final ScrollController listScrollController = new ScrollController();

  List<String> _tags = [];
  List<String> _options = ["","","","",""];
  List<bool> _answers = [false, false, false, false, false];
  int _color = 9;
  bool _submitDisable = true;
  int _gameStage = -1; // 0 not start, 1 ready, 2 good, 3 report.
  List<FocusNode> _focusNodes = [];
  List<Question> _questions = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Timer _timer;
  int _start = 30;
  
  static const int BaseQuestionTime = 100;
  static const int BaseText = 120;
  static const int TextFactor = 12;
  static const int QuestionTimeFactor = 10;
  int _currentQuestionTime = BaseQuestionTime;
  int _maxQuestionTime = BaseQuestionTime;

  void nextQuestion(BuildContext context) {
    print("Next question ID ${this._questionIDs[this.questionIndex]}");
    questionService.getQuestion(this._questionIDs[this.questionIndex]).then((question) {
      print("question ${question}");
      _questions.add(question);
      const oneTenthSec = const Duration(milliseconds: 100);
      if(_timer != null) {
        _timer.cancel();
        _maxQuestionTime = BaseQuestionTime;
        if(question.totalText() > BaseText) {
          _maxQuestionTime += (((question.totalText() - BaseText) / TextFactor).ceil() * QuestionTimeFactor);
        }
        print("Total Text ${question.totalText()} , $_maxQuestionTime");
        _currentQuestionTime = _maxQuestionTime;
      }
      _timer = new Timer.periodic(
        oneTenthSec,
        (Timer timer) => setState(
          () {
            if (_currentQuestionTime < 1) {
              validAnswer(context);
            } else {
              _currentQuestionTime -= 1;
            }
          },
        ),
      );
      setState(() {
        _options = question.options;
        _textController.text = question.title;
        _tags = question.tags;
        _color = question.color;
        _answers = [false, false, false, false, false];
        _submitDisable = false;
      });
    });
  }

  void startTimer(BuildContext context) {
    const oneSec = const Duration(milliseconds: 100);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_start < 1) {
            setState(() {
              _submitDisable = false;
              _gameStage = 1;
              _timer.cancel();
            });
          } else {
            if(_start == 20) {
              showOverlay(context, "set");
            }
            if(_start == 30) {
              showOverlay(context, "ready");
            }
            if(_start == 10) {
              showOverlay(context, "go");
            }
            _start = _start - 1;
          }
        },
      ),
    );

  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _examResult = new ExamResult(user.id);
    _newTitleLabel = widget.category;
    initPlatformState();
    //_sendButtonText = new Text(textRes.LABEL_MISSING_NEW_QUESTION);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    //if (!mounted) return;
    questionService.getRandomQuestionID(widget.category, widget.totalQuestion).then((ids) {
      //print("questionIDs ${ids}");
      setState(() {
        this._questionIDs = ids;
      });
    });
  }

  void onFocusChange() {
    if (_focusNodes[0].hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
      });
    }
  }

  Future<bool> onBackPress() {
    Navigator.pop(context);
    return Future.value(false);
  }

  void sendReport() {
    setState(() {
      _gameStage = 3;
    });
    String cat = widget.category;
    if(cat.length == 0) {
      cat = textRes.LABEL_QUICK_GAME;
    }
    examService.submitExamResult(cat, user, _examResult);
  }

  void validAnswer(BuildContext context) async {
    _timer.cancel();
    String state = "correct";
    List<String> userAnswerSet = [];
    for(int i = 0; i < this._answers.length; i++) {
      if(this._answers[i]) {
        userAnswerSet.add(this._options[i]);
      }
    }
    // todo add to user result;
    //print("${userAnswerSet} ${this._questions[questionIndex].answers.toSet()}");
    int questionTime = _maxQuestionTime - _currentQuestionTime;
    if(userAnswerSet.toSet().intersection(this._questions[questionIndex].answers.toSet()).length !=
    userAnswerSet.toSet().union(this._questions[questionIndex].answers.toSet()).length) {
      state = "wrong";
      questionTime = _maxQuestionTime;
    }
    Result _result = new Result(this._questions[questionIndex].id, userAnswerSet, questionTime, state == "correct");
    _examResult.results.add(_result);
    await showOverlay(context, state);
    questionIndex++;
    if(questionIndex < _questionIDs.length) {
      nextQuestion(context);
    } else {
      sendReport();
    }
  }

  void showOverlay(BuildContext context, String state) async {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double radius = (width > height) ? height/4 : width/4;
    OverlayState overlayState = Overlay.of(context);
    int wait = 2;
    OverlayEntry overlayEntry;
    switch(state) {
        case "ready":
        overlayEntry = OverlayEntry(
          builder: (context) => Positioned(
                top: height/2 - radius,
                left: width/2 - radius,
                child: Icon(Icons.traffic, color: Colors.red, size: radius * 2)
            ));
        wait = 1;
        break;
      case "set":
        overlayEntry = OverlayEntry(
          builder: (context) => Positioned(
                top: height/2 - radius,
                left: width/2 - radius,
                child: Icon(Icons.traffic, color: Colors.yellow, size: radius * 2)
            ));
        wait = 1;
        break;
      case "go":
        overlayEntry = OverlayEntry(
          builder: (context) => Positioned(
                top: height/2 - radius,
                left: width/2 - radius,
                child: Icon(Icons.traffic, color: Colors.green, size: radius * 2)
            ));
        wait = 1;
        break;
      case "correct":
        overlayEntry = OverlayEntry(
          builder: (context) => Positioned(
                top: height/2 - radius,
                left: width/2 - radius,
                child: Icon(Icons.check_circle, color: Colors.yellow, size: radius * 2)
            ));
            break;
      case "wrong":
        overlayEntry = OverlayEntry(
          builder: (context) => Positioned(
                top: height/2 - radius,
                left: width/2 - radius,
                child: Icon(Icons.clear, color: Colors.blue, size: radius * 2)
            ));
          break;
    }
    overlayState.insert(overlayEntry);

    await Future.delayed(Duration(seconds: wait));

    overlayEntry.remove();
  }

  @override
  Widget build(BuildContext context) {
    Widget body = null;
    switch(_gameStage) {
      case 1 :  nextQuestion(context);
                setState(() {
                  _gameStage = 2;
                });
                break;
                
      case -1 : startTimer(context);
                setState(() {
                  _gameStage = 0;
                });        
                break;
    }
    if(_gameStage < 3) {
      body = new WillPopScope(
        child: Column(
          children: <Widget>[            
            new Form(
              key: _formKey,
              autovalidate: true,
              child: formUI(context)
            )
          ],
        ),
        onWillPop: onBackPress,
      );
    } else {
      body = new WillPopScope(
        child: ReportWidget(this._questions, this._examResult),
        onWillPop: onBackPress,
      );
    }
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
          child: body
        ),

      ),
    ); 
  } 

  Widget titleUI(BuildContext context) {
    return TextFormField(
      enabled: false,
      controller: _textController,
      textInputAction: TextInputAction.next,
      //textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        border: UnderlineInputBorder(),
        filled: true,
        icon: Icon(Icons.live_help),
        hintText: textRes.HINT_QUESTION,
        labelText: textRes.LABEL_QUESTION,
      ),
      minLines: 1,
      maxLines: 10,
    );
  }

  Widget tagUI(BuildContext context) {
    List<Chip> chips = [];
    this._tags.forEach((tag) {
      chips.add(Chip(label: Text(tag)));
    });
    return Wrap(runSpacing: 4.0, spacing: 8.0, children: chips);
  }
  Widget answerHeader(BuildContext context) {
    return Row(children: <Widget> [
      SizedBox(
        child: Text(textRes.LABEL_OPTION, textAlign: TextAlign.center),
        width: MediaQuery.of(context).size.width - 60,
      ),
      //Text(textRes.LABEL_ANSWER, textAlign: TextAlign.center),
    ]);
  }


  Widget formUI(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text("Question : ${questionIndex + 1}"),
          const SizedBox(height: 12.0),
          titleUI(context),
          tagUI(context),
          const SizedBox(height: 5.0),
          answerHeader(context),
          optionWidget(context, 0), 
          optionWidget(context, 1),
          optionWidget(context, 2),
          optionWidget(context, 3),
          optionWidget(context, 4),  
          const SizedBox(height: 5.0),                                        
          _buildSubmit(context)
        ],
      )
    );
  }
  Widget _buildSubmit(BuildContext context) {
    String text = "Wait";
    Widget button;
    if(!_submitDisable && _currentQuestionTime > 0) {
      LinearGradient gradient = LinearGradient(colors: [Colors.yellow , Colors.blue],
      stops: [_currentQuestionTime/_maxQuestionTime, _currentQuestionTime/_maxQuestionTime],
      tileMode: TileMode.clamp);
      bool select = false;
      _answers.forEach((element) {if(element) select = true; });
      text = "Submit ${_currentQuestionTime/10}";
      BoxDecoration decoration = BoxDecoration(
          gradient: gradient,
      );
      button = Container(
        decoration: decoration,
        child: 
          FlatButton(
            onPressed:  select? () {
              setState(() {
                _submitDisable = true;
              });
              validAnswer(context);
            }:null,
            child:  Text(text)
          ));
    } else {
      button = RaisedButton(
            child:  Text(text)
          );
    }
    return button;
  }

  Widget optionWidget(BuildContext context, int index) {
    bool checked = this._answers[index];
    /*
    LinearGradient gradient = LinearGradient(colors: [Colors.yellow , Colors.white],
      stops: checked? [1, 1]: [0, 0],
      tileMode: TileMode.clamp);
    */
    BoxDecoration decoration;
    if(checked) {
      decoration = BoxDecoration(
          //gradient: gradient,
          border: Border.all(width: 1, color: Colors.red),
          color: Colors.white,
        );
    } else {
      decoration = BoxDecoration(
          //gradient: gradient,
          //border: Border.all(width: 0.5, color: Colors.red),
          color: Colors.grey,
        );
    }
    return SizedBox(
      width: MediaQuery.of(context).size.width - 60,
      child: Container(
        decoration: decoration,
        child: 
          FlatButton(
            child: Text(this._options[index]), 
            onPressed:  () => {
              setState(() {
                this._answers[index] = !this._answers[index];
            })
            }
          )
      )
    );
  }
}