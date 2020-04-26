import '../main.dart';
import 'package:OurlandQuiz/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import './routeNames.dart';
import '../screens/quizMainScreen.dart';
import '../screens/submitMainScreen.dart';
import '../screens/userMainScreen.dart';
import '../screens/resultMainScreen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  if(settings.name == Routes[0]) {
    return _getPageRoute(quizMain, settings.name);
  }
  if(settings.name == Routes[1]) {
    return _getPageRoute(SubmitMainScreen(), settings.name);
  }
  if(settings.name == Routes[2]) {
    return _getPageRoute(resultMain, settings.name);  
  }
  if(settings.name == Routes[3]) {
    return _getPageRoute(UserMainScreen(), settings.name);
  }
}

PageRoute _getPageRoute(Widget child, String routeName) {
  return _FadeRoute(child: child, routeName: routeName);
}

class _FadeRoute extends PageRouteBuilder {
  final Widget child;
  final String routeName;
  _FadeRoute({this.child, this.routeName})
      : super(
            pageBuilder: (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) =>
                child,
            settings: RouteSettings(name: routeName),
            transitionsBuilder: (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child,
            ) =>
                FadeTransition(
                  opacity: animation,
                  child: child,
                ));
}