import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/question.dart';
import '../models/textRes.dart';
import '../models/examResult.dart';
import '../screens/viewResultScreen.dart';

class ResultWidget extends StatelessWidget {
  final ExamResult examResult;
  int rank;
  bool pending = false;

  ResultWidget(
      {Key key,
      @required this.rank,
      @required this.examResult})
      : super(key: key);

  Widget build(BuildContext context) {
    if(this.examResult == null) {
      return Container();
    }

    void _onTapForView() async {
      Navigator.of(context).push(
        new MaterialPageRoute<void>(
          builder: (BuildContext context) {
            return ViewResultScreen(rank: rank, examResult: examResult);
          },
        ),
      );
    }
    
    void _onTap() {
      return _onTapForView();
    }

    Widget rv = new Container();
    if(this.examResult != null) {
      int totalTime = this.examResult.totalTimeIn100ms();
      int correct = 0;
      this.examResult.results.forEach((element) {
        if(element.correct) {
          correct++;
        }
      });
      Widget messageWidget = Row(children: <Widget>[
          Expanded(flex: 1, child: Text(rank.toString(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
          Expanded(flex: 4, child: Text("Time: ${totalTime/10}")),
          Expanded(flex: 2, child: Text("Correct $correct/${this.examResult.results.length}"))]);
      List<Widget> footers = []; 
        
      // Time
      Container timeWidget = Container(
        child: Text(
          DateFormat('dd MMM kk:mm').format(
              new DateTime.fromMicrosecondsSinceEpoch(
                this.examResult.createdAt.millisecondsSinceEpoch)),
          style: Theme.of(context).textTheme.subtitle),
      );
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
