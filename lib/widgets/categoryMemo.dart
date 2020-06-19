import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../models/textRes.dart';

class CategoryMemo extends StatelessWidget {
  final String category;
  final Function tapWithCategory;
  final List<String> details;
  CategoryMemo(this.category, this.tapWithCategory, this.details);

  @override
  Widget build(BuildContext context) {
    String title = category;
    if(category.length == 0) {
      title = textRes.LABEL_ALL;
    } 
    double fontSize = MediaQuery.of(context).size.width * 0.06;
    if(fontSize > 40) {
      fontSize = 40;
    }
    double smallFontSize = fontSize/2;
    List<Widget> widgets = [Text(title, style: TextStyle(fontSize: fontSize))];
    details.forEach((element) {
      widgets.add(Row(children:[Text(element, style: TextStyle(fontSize: smallFontSize))]));
    });
    Widget rv = GestureDetector(
          onTap: () {tapWithCategory(category);},
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
              padding: EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: MEMO_COLORS[title.hashCode % MEMO_COLORS.length],
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
