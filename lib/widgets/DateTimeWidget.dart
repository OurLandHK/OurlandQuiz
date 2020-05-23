import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeWidget extends StatelessWidget {
  final DateTime dateTime;
  DateTimeWidget(this.dateTime);

  @override
  Widget build(BuildContext context) {
    return Text(
          DateFormat('yyyy MMM dd').format(
                dateTime),
          style: Theme.of(context).textTheme.subtitle);
  }
}


