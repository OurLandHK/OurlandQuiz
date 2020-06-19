import 'package:flutter/material.dart';

class RouteEntry{
  final String route;
  final String label;
  final IconData iconData;
  const RouteEntry(this.route, this.label, this.iconData);
}
const List<RouteEntry> MainRoutes = 
  [RouteEntry('quiz', '考試', Icons.layers),
  RouteEntry('topic', '課程', Icons.dashboard),
  RouteEntry('result', '排行榜', Icons.access_alarm),
  RouteEntry('profile', '個人', Icons.bookmark)];


const String QuestionRoute = 'question';