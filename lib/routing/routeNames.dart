import 'package:flutter/material.dart';

class RouteEntry{
  final String route;
  final String label;
  final IconData iconData;
  const RouteEntry(this.route, this.label, this.iconData);
}
const List<RouteEntry> Routes = 
  [RouteEntry('quiz', '考試', Icons.layers),
  RouteEntry('topic', '課程', Icons.layers),
  RouteEntry('result', '排行榜', Icons.layers),
  RouteEntry('me', '個人', Icons.layers)];

const String QuestionRoute = 'question';