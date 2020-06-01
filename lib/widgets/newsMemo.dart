import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../models/textRes.dart';
import '../models/news.dart';
import './DateTimeWidget.dart';

class NewsMemo extends StatelessWidget {
  final News news;
  NewsMemo(this.news);

  @override
  Widget build(BuildContext context) {
    double fontSize = MediaQuery.of(context).size.width * 0.04;
    if(fontSize > 28) {
      fontSize = 28;
    }
    double smallFontSize = MediaQuery.of(context).size.width * 0.03;
    List<Widget> widgets = [
      Row(children:
        [Text(news.title, style: TextStyle(fontSize: fontSize)),
          Expanded(flex: 1,child: Container(),),
          DateTimeWidget(news.createdAt , smallFontSize),
        ])];
    widgets.add(Row(children:[Text(news.detail, style: TextStyle(fontSize: smallFontSize))]));
    Widget rv = GestureDetector(
          //onTap: () {tapWithCategory(category);},
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
              padding: EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: MEMO_COLORS[news.title.hashCode % MEMO_COLORS.length],
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
                children: widgets
              ),
            ),
          ),
        );
    return rv;
  }
}
