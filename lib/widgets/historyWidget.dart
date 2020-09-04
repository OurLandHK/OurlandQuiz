import 'package:OurlandQuiz/services/questionService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import '../models/question.dart';
import '../models/textRes.dart';
import '../models/examResult.dart';
import '../screens/addQuestionScreen.dart';
import '../screens/viewQuestionScreen.dart';
import '../routing/routeNames.dart';
import '../locator.dart';
import '../services/navigationService.dart';
import '../widgets/DateTimeWidget.dart';

class HistoryWidget extends StatelessWidget {
  final Question question;
  final String id;

  HistoryWidget({Key key, @required this.question, @required this.id})
      : super(key: key);

  Widget build(BuildContext context) {
    if (this.question == null) {
      print("this.question == null");
      return Container();
    }

    void _onTap() async {
      //locator<NavigationService>().navigateTo('/${QuestionRoute}/${question.id}', arguments: this.question);
      questionService
          .getHistoryQuestion(this.question, id)
          .then((historyQuestion) {
        Navigator.of(context).push(
          new MaterialPageRoute<void>(
            builder: (BuildContext context) {
              //getPageRoute(ViewQuestionScreen(question: question, questionId: question.id), '/${Routes[1].route}/${question.id}');
              return ViewQuestionScreen(
                  question: historyQuestion, questionId: question.id, readOnly: true);
            },
          ),
        );
      });
    }

    Widget rv = new Container();
    if (this.question != null) {
      List<Widget> widgets = [_buildTitle(context)];
      /*
      if(pending != null && pending) {
        widgets.add(_buildDescription(context));
      }
      */
      Widget messageWidget = Column(children: widgets);
      /*
      List<Widget> footers = []; 
    
      for(int i = 0; i< this.question.tags.length && i < 3 ; i++) {
        footers.add(Chip(label: Text(this.question.tags[i]), labelStyle: Theme.of(context).textTheme.subtitle1));
        //footers.add(Text("#${this.question.tags[i]}", style: Theme.of(context).textTheme.subtitle));
      }
 
      // Time
      Widget timeWidget = DateTimeWidget(this.question.lastUpdate, null, null);
      footers.add(Expanded(flex: 1, child: Container()));
      footers.add(timeWidget);
      */
      List<Widget> topicColumn = [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: messageWidget,
              ),
            ),
          ],
        )
      ];
      /*
      topicColumn.add(Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: footers));
      */
      rv = GestureDetector(
        onTap: _onTap,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Container(
            padding: EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: MEMO_COLORS[this.question.color],
              border: Border.all(width: 1, color: Colors.grey),
              boxShadow: [
                new BoxShadow(
                    color: Colors.grey,
                    offset: new Offset(0.0, 2.5),
                    blurRadius: 4.0,
                    spreadRadius: 0.0)
              ],
              //borderRadius: BorderRadius.circular(6.0)
            ),
            child: Column(
              children: topicColumn,
            ),
          ),
        ),
      );
    }
    return rv;
  }

  Widget _buildTitle(BuildContext context) {
    int ms = int.parse(this.id);
    DateTime editDate = DateTime.fromMillisecondsSinceEpoch(ms);
    return Padding(
        padding: EdgeInsets.all(1.0),
        child: new Text(
          DateFormat('yyyy MMM dd').format(editDate),
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ));
  }

/*
  Widget _buildDescription(BuildContext context) {
    if (this.question.explanation != null &&this.question.explanation.length > 0) {
      return Padding(
          padding: EdgeInsets.all(2.0),
          child: new Text(this.question.explanation,
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
              style: TextStyle(color: Colors.black),
              textAlign: TextAlign.left,));
    } else {
      return Container();
    }
  }
  */
}
