import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeWidget extends StatelessWidget {
  final DateTime dateTime;
  double fontSize;
  DateTimeWidget(this.dateTime, this.fontSize);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.subtitle;
    if(fontSize != null) {
      textStyle = TextStyle(fontSize: fontSize);
    }
    return Text(
          DateFormat('yyyy MMM dd').format(
                dateTime),
          style: textStyle);
  }
}


