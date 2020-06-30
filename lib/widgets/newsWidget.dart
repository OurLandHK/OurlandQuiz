import 'package:OurlandQuiz/screens/addNewsScreen.dart';
import 'package:OurlandQuiz/services/questionService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import '../main.dart';
import '../widgets/newsMemo.dart';
import '../widgets/linkPreviewWidget.dart';
import '../models/textRes.dart';
import '../models/news.dart';
import '../services/newsService.dart';
import '../services/auth.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class NewsWidget extends StatefulWidget {
  NewsWidget({Key key});

  @override
  State createState() => new NewsWidgetState();
}

class NewsWidgetState extends State<NewsWidget> {
  final ScrollController listScrollController = new ScrollController();

  List<News> _newsList = [];
  bool initExpanded;

  @override
  void initState() {
    initExpanded = true;
    bool isExpanded = sharedPreferences.get('newsExpan');
    if(isExpanded == false) {
      initExpanded = false;
    }
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {

    newsService.getLatestNews(3).then((List<News> newsList) {
      setState(() {
        print(newsList[0].createdAt);
        print(user.updatedAt);
        if(newsList.length > 0 && newsList[0].createdAt.millisecondsSinceEpoch > user.updatedAt.millisecondsSinceEpoch) {
          print('expanded');
          initExpanded = true;
        }
        _newsList = newsList;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double fontSize = MediaQuery.of(context).size.width * 0.04;
    if(fontSize > 28) {
      fontSize = 28;
    }
    if(_newsList.length == 0) {
      return Container();
    } else {
      Widget body = newsSet(context);     
      return ExpansionTile(
        title: Column(
          children: [Text(textRes.LABEL_NEWS, style: TextStyle(fontSize: fontSize),),
            LinkPreview(hideLink: true, launchFromLink: true, link: 'https://ourland.hk/recent',)]),
        children: [body],
        initiallyExpanded: initExpanded,
        onExpansionChanged: (value) => sharedPreferences.setBool('newsExpan', value),
      );
    }
  }

  void _addNews() async {
    showDialog<void>(
      context: context,
      //barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AddNewsScreen();
      }); 
  }

  Widget newsSet(BuildContext context) {
    List<Widget> buttonWidgets = [
      user.role == "admin" ? RaisedButton(child: Text(textRes.LABEL_ADD_NEWS), onPressed: _addNews) : Container(),
    ];
    _newsList.forEach((news) {
      buttonWidgets.add(const SizedBox(height: 1.0));
      buttonWidgets.add(NewsMemo(news));
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
