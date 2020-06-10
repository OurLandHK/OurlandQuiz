import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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

class QuestionWidget extends StatelessWidget {
  final Question question;
  bool pending = false;
  bool isCurrentUser = false;
  Result result;

  QuestionWidget(
      {Key key,
      @required this.question,
      this.pending,
      this.isCurrentUser,
      this.result})
      : super(key: key);

  Widget build(BuildContext context) {
    if(this.question == null) {
      print("this.question == null");
      return Container();
    }

    void _onTapForApproval() async {
      Navigator.of(context).push(
        new MaterialPageRoute<void>(
          builder: (BuildContext context) {
            return AddQuestionScreen(question: this.question);
          },
        ),
      );
    }

    void _onTapForView() async {
      locator<NavigationService>().navigateTo('/${QuestionRoute}/${question.id}', arguments: this.question);
      /*
      Navigator.of(context).push(
        new MaterialPageRoute<void>(
          builder: (BuildContext context) {
            getPageRoute(ViewQuestionScreen(question: question, questionId: question.id), '/${Routes[1].route}/${question.id}');
            return ViewQuestionScreen(question: question, questionId: question.id);
          },
        ),
      );
      */
    }
    //String title = this.searchingMsg.text;
    void _onTap() {
      if(pending != null && pending) {
        return _onTapForApproval();
      } else {
        return _onTapForView();
        // user to view the answer and history
      }
    }

    Widget rv = new Container();
    if(this.question != null) {
      List<Widget> widgets = [_buildTitle(context)];
      if(pending != null && pending) {
        widgets.add(_buildDescription(context));
      }
      if(result != null) {
        if(isCurrentUser) {
          widgets.add(Text("${textRes.LABEL_CORRECT_ANSWER}: ${this.question.answers}"));
          if(result.correct) {
            widgets.add(Text("${textRes.LABEL_YOU_ARE_CORRECT}"));
          } else {
            widgets.add(Text("${textRes.LABEL_YOUR_ANSWER} ${result.answers}"));
          }
        } else {
          widgets.add(Text("${textRes.LABEL_PLAYER_ANSWER} ${result.answers}"));
        }
      }
      Widget messageWidget = Column(children: widgets);
      List<Widget> footers = []; 
    
      for(int i = 0; i< this.question.tags.length && i < 3 ; i++) {
        footers.add(Chip(label: Text(this.question.tags[i]), labelStyle: Theme.of(context).textTheme.subtitle1));
        //footers.add(Text("#${this.question.tags[i]}", style: Theme.of(context).textTheme.subtitle));
      }
        
      // Time
      Widget timeWidget = DateTimeWidget(this.question.created, null, null);
      footers.add(Expanded(flex: 1, child: Container()));
      footers.add(timeWidget);
      
      List<Widget> topicColumn = [Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: messageWidget,
                          ),
                        ),
                      ],
                    )];
      topicColumn.add(Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: footers));
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
                    spreadRadius: 0.0
                  )
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
    return Padding(
        padding: EdgeInsets.all(1.0),
        child: new Text(
          this.question.title,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ));
  }

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
}
