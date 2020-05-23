import 'package:firebase/firebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/question.dart';
import '../models/textRes.dart';
import '../models/examResult.dart';
import '../routing/routeNames.dart';
import '../locator.dart';
import '../services/navigationService.dart';
import '../services/auth.dart';
import '../main.dart';
import '../widgets/DateTimeWidget.dart';
class ResultWidget extends StatefulWidget {
  final ExamResult examResult;
  String category;
  int rank;
  bool pending = false;

  ResultWidget(
      {Key key,
      @required this.category,
      @required this.rank,
      @required this.examResult})
      : super(key: key);

  @override
  State createState() => new ResultState();
}

class ResultState extends State<ResultWidget> {
  String examUserName = "";

  void initState() {
    super.initState();
    if(widget.examResult != null && widget.examResult.userId != null) {
      
      initPlatformState();
    }
  }

  initPlatformState() async {
    authService.getUser(this.widget.examResult.userId).then((resultUser) {
      if(resultUser != null && resultUser.name != null) {
        setState(() {
          examUserName = resultUser.name;
        });
      } 
    });
  }  

  Widget build(BuildContext context) {
    if(widget.examResult == null) {
      return Container();
    }

    void _onTapForView() async {
      locator<NavigationService>().navigateTo('/${Routes[2].route}/${widget.category}/${widget.rank}', arguments: widget.examResult);
    }
    
    void _onTap() {
      return _onTapForView();
    }

    Widget rv = new Container();
    if(widget.examResult != null) {
      int totalTime = widget.examResult.totalTimeIn100ms();
      int correct = 0;
      widget.examResult.results.forEach((element) {
        if(element.correct) {
          correct++;
        }
      });
      Widget messageWidget = Row(children: <Widget>[
          Expanded(flex: 1, child: Text("${widget.rank.toString()}.", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
          Expanded(flex: 4, child: Text(this.examUserName)),
          Expanded(flex: 2, child: Text("Time: ${totalTime/10}")),
          Expanded(flex: 2, child: Text("Correct $correct/${widget.examResult.results.length}"))]);
      List<Widget> footers = []; 
        
      footers.add(Expanded(flex: 1, child: Container()));
      footers.add(DateTimeWidget(widget.examResult.createdAt));
      
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
                color: Colors.yellow,
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
}
