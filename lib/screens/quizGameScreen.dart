import 'dart:async';
//import 'dart:html';

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
import '../routing/routeNames.dart';
import '../main.dart';

//final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class QuizGameScreen extends StatefulWidget {
  final String mode;
  final String category;
  QuizGameScreen({Key key, @required this.mode, @required this.category, @required this.totalQuestion});
  final int totalQuestion;
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
  Widget _overlayWidget;
  OverlayState _overlayState;
  OverlayEntry _overlayEntry;
  TextStyle _questionTextStyle;
  TextStyle _optionTextStyle;
  String _imageUrl;
  bool _showBar = true;

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
  static int TotalQuestionTime = textRes.TOTAL_TIME * 10;
  static const int BaseText = 120;
  static const int TextFactor = 12;
  static const int QuestionTimeFactor = 10;
  int _currentQuestionTime = BaseQuestionTime;
  int _maxQuestionTime = BaseQuestionTime;
  int _beginQuestionTime = BaseQuestionTime;
  bool _pauseTimer = false;

  void nextQuestion(BuildContext context) {
    //print("Next question ID ${this._questionIDs[this.questionIndex]}");
    questionService.getQuestion(this._questionIDs[this.questionIndex]).then((question) {
      //print("question ${question}");
      _questions.add(question);
      const oneTenthSec = const Duration(milliseconds: 100);
      if(widget.mode == GameModes[FIX_TIME_GAME_INDEX].label || widget.mode == ValidateRoute) {
        if(_questions.length == 1) {
          _maxQuestionTime = TotalQuestionTime;
          _currentQuestionTime = _maxQuestionTime;
          _beginQuestionTime = _maxQuestionTime;
          _timer = new Timer.periodic(
            oneTenthSec,
            (Timer timer) => setState(
              () {
                if (_currentQuestionTime < 1) {
                  validateAnswer(context);
                } else {
                  if(!_pauseTimer) {
                    _currentQuestionTime -= 1;
                  }
                }
              },
            ),
          );
        }
      } else {  
        if(_timer != null) {
          _timer.cancel();
          _maxQuestionTime = BaseQuestionTime;
          if(question.totalText() > BaseText) {
            _maxQuestionTime += (((question.totalText() - BaseText) / TextFactor).ceil() * QuestionTimeFactor);
          }
          print("Total Text ${question.totalText()} , $_maxQuestionTime");
          _currentQuestionTime = _maxQuestionTime;
          _beginQuestionTime = _maxQuestionTime;
        }
        _timer = new Timer.periodic(
          oneTenthSec,
          (Timer timer) => setState(
            () {
              if (_currentQuestionTime < 1) {
                validateAnswer(context);
              } else {
                _currentQuestionTime -= 1;
              }
            },
          ),
        );
      }
      TextStyle qtextStyle = pickTitleTextStyle(context, question.title, question.imageUrl);
      String maxOption = question.options[0];
      question.options.forEach((element) { if(maxOption.length < element.length) maxOption =element; });
      TextStyle otextStyle = pickOptionTextStyle(context, maxOption);
      setState(() {
        _imageUrl = question.imageUrl;
        _questionTextStyle = qtextStyle;
        _optionTextStyle = otextStyle;
        _newTitleLabel = "${textRes.LABEL_QUESTION}: ${questionIndex + 1}";
        _options = question.options;
        _textController.text = question.title;
        _tags = question.tags;
        _color = question.color;
        _answers = [false, false, false, false, false];
        _submitDisable = false;
        _pauseTimer = false;
      });
    });
  }

  TextStyle pickTitleTextStyle(BuildContext context, String text, String imageUrl) {
    double height = MediaQuery.of(context).size.height;
    double fontSize = 20;
    double textLenghtFactor = 1 - (text.length / 50) * 0.1;
    fontSize *= textLenghtFactor;
    if(imageUrl != null) {
      fontSize *= 0.75;
    }
    //print('FontSzint h ${height} fs ${fontSize} ig ${imageUrl} text.lenght${text.length} textLenghtFactio ${textLenghtFactor}');
    TextStyle rv = TextStyle(
              fontFamily: 'Sans',
              fontWeight: FontWeight.normal,
              color: Colors.black,
              fontSize: fontSize);
    return rv;
  }

  TextStyle pickOptionTextStyle(BuildContext context, String text) {
    //double height = MediaQuery.of(context).size.height;
    double fontSize = 16;
    double textLenghtFactor = 1 - (text.length / 50) * 0.1;
    fontSize *= textLenghtFactor;
    //print('FontSzint h ${height} fs ${fontSize} ig ${imageUrl} text.lenght${text.length} textLenghtFactio ${textLenghtFactor}');
    TextStyle rv = TextStyle(
              fontFamily: 'Sans',
              fontWeight: FontWeight.normal,
              color: Colors.black,
              fontSize: fontSize);
    return rv;
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
            if(_start == 30) {
              startCountdown(context, 3000);
            }
            _start = _start - 1;
          }
        },
      ),
    );

  }

  @override
  /*
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
  */
  @override
  void initState() {
    super.initState();
    _examResult = new ExamResult(user.id);
    _newTitleLabel = widget.category;
    _overlayWidget = Container();
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
    _timer.cancel();
    layoutTemplate.showNaviBar(true);
    Navigator.pop(context);
    return Future.value(false);
  }

  void sendReport() {
    if(widget.mode == ValidateRoute)  {
      // count for pass
      int pass = 0;
      _examResult.results.forEach((element) {
        if(element.correct) {
          pass++;
        }
      });
      if(pass > 6) {
        launchURL("https://t.me/StationGroupKeeperBot?start=VALIDATEIONKEY");
      } else {
        launchURL("https://t.me/StationGroupKeeperBot?start=INVALIDATE");
      }
      onBackPress();
    } else {
      setState(() {
        _gameStage = 3;
      });
      String cat = widget.category;
      if(cat.length == 0) {
        cat = textRes.LABEL_ALL;
      }
      examService.submitExamResult(widget.mode, cat, user, _examResult);
    }
  }

  void validateAnswer(BuildContext context) async {
    if(widget.mode != GameModes[FIX_TIME_GAME_INDEX].label && widget.mode != ValidateRoute) {
      _timer.cancel();
    }
    _pauseTimer = true;
    bool correct = true;
    List<String> userAnswerSet = [];
    for(int i = 0; i < this._answers.length; i++) {
      if(this._answers[i]) {
        userAnswerSet.add(this._options[i]);
      }
    }
    // todo add to user result;
    //print("${userAnswerSet} ${this._questions[questionIndex].answers.toSet()}");
    int questionTime = _beginQuestionTime - _currentQuestionTime;
    if(userAnswerSet.toSet().intersection(this._questions[questionIndex].answers.toSet()).length !=
    userAnswerSet.toSet().union(this._questions[questionIndex].answers.toSet()).length) {
      correct = false;
      questionTime = _beginQuestionTime;
    }
    Result _result = new Result(this._questions[questionIndex].id, userAnswerSet, questionTime, correct);
    _examResult.results.add(_result);
    await showResult(context, correct);
    questionIndex++;
    if((widget.mode == GameModes[FIX_TIME_GAME_INDEX].label || widget.mode == ValidateRoute) && _currentQuestionTime < 1) {
      sendReport();
    } else {
      if(questionIndex < _questionIDs.length ) {
        nextQuestion(context);
      } else {
        sendReport();
      }
    }
  }

  void showResult(BuildContext context, bool correct) async {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double radius = (width > height) ? height/4 : width/4;
    int wait = 2000;
    Widget child = null;
    if(correct) {
        child = Icon(Icons.check_circle, color: Colors.yellow, size: radius * 2);
    } else {
        child = Icon(Icons.clear, color: Colors.blue, size: radius * 2);
    }
    setState(() {
      _overlayWidget = child;
    });
    await Future.delayed(Duration(milliseconds: wait - 10));
    setState(() {
      _overlayWidget = Container();
    });
    //print('remove result');
    await Future.delayed(Duration(milliseconds: 10));
  }

  void startCountdown(BuildContext context, int wait) async {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double radius = (width > height) ? height/4 : width/4;
    setState(() {
      _overlayWidget = Icon(Icons.traffic, color: Colors.red, size: radius * 2);
    });
    await Future.delayed(Duration(milliseconds: wait~/3 - 10));
    setState(() {
      _overlayWidget = Container();
    });
    await Future.delayed(Duration(milliseconds: 10));
    setState(() {
      _overlayWidget = Icon(Icons.traffic, color: Colors.yellow, size: radius * 2);
    });
    await Future.delayed(Duration(milliseconds: wait~/3- 10));
    setState(() {
      _overlayWidget = Container();
    });
    await Future.delayed(Duration(milliseconds: 10));
    setState(() {
      _overlayWidget = Icon(Icons.traffic, color: Colors.blue, size: radius * 2);
    });
    await Future.delayed(Duration(milliseconds: (wait/3).toInt() - 10));
    setState(() {
      _overlayWidget = Container();
    });
  }

  void _hideBar(BuildContext context) {
    if(_showBar) {
      _showBar = false;
      layoutTemplate.showNaviBar(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance
      .addPostFrameCallback((_) => _hideBar(context));
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
      //key: _scaffoldKey,
      appBar: new AppBar(
        backgroundColor: MEMO_COLORS[_color],
        title: new Text(
          _newTitleLabel,
          style: TextStyle(/*color: primaryColor,*/ fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0.7,
        /*
        //actionsIconTheme: Theme.of(context).primaryIconTheme,
        */
      ),
      body: Container(
        color: MEMO_COLORS[_color],
        //child: new Container(),
        child: Stack(
          children: [
          SafeArea(
            top: false,
            bottom: false,
            child: body
          ),
          Container(
            alignment: Alignment.center,
            child:
              AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  reverseDuration: const Duration(milliseconds: 10),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return ScaleTransition(child: child, scale: animation);
                  },
                  child: _overlayWidget
              )
          ),
        ]),

      ),
    ); 
  } 

  Widget titleUI(BuildContext context) {
    Widget imageWidget = Container();
    Widget titleWidget = TextFormField(
          enabled: false,
          controller: _textController,
          textInputAction: TextInputAction.next,
          style: _questionTextStyle,
          //textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            //border: UnderlineInputBorder(),
            filled: true,
            //icon: Icon(Icons.live_help),
            //hintText: textRes.HINT_QUESTION,
            //labelText: textRes.LABEL_QUESTION,
          ),
          minLines: 2,
          maxLines: 10,);
    if(_imageUrl != null) {
      double height = MediaQuery.of(context).size.height;
      imageWidget = Image.network(_imageUrl, height: (height- 100)*3/8 - 22);
      titleWidget = Text(_textController.text);
    }
    return 
      Column(children:[
          titleWidget,
          imageWidget]);

  }

  Widget tagUI(BuildContext context) {
    List<Chip> chips = [];
    this._tags.forEach((tag) {
      chips.add(Chip(label: Text(tag), labelStyle: Theme.of(context).textTheme.subtitle1));
    });
    return Wrap(runSpacing: 2.0, spacing: 6.0, children: chips);
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
    double height = MediaQuery.of(context).size.height;
    int hash = DateTime.now().day;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          //const SizedBox(height: 12.0),
          SizedBox(height: (height)/2 -10,
            child: Column(children: [
              tagUI(context),
              titleUI(context),
            ]
          )),
          //const SizedBox(height: 2.0),
          //answerHeader(context),
          SizedBox(height: (height- 100)/2 - 10 ,
            child: Column(children: [
              optionWidget(context, hash%5), 
              optionWidget(context, (hash+1)%5),
              optionWidget(context, (hash+2)%5),
              optionWidget(context, (hash+3)%5),
              optionWidget(context, (hash+4)%5), 
                
              const SizedBox(height: 1.0),                                        
              _buildSubmit(context)
            ]
          ))
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
              validateAnswer(context);
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
      height: (MediaQuery.of(context).size.height - 100) / 14,
      child: Container(
        decoration: decoration,
        child: 
          FlatButton(
            child: Text(this._options[index], style: _optionTextStyle), 
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