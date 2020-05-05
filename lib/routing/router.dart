import 'package:OurlandQuiz/models/textRes.dart';

import '../main.dart';
import 'package:OurlandQuiz/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import './routeNames.dart';
import '../models/question.dart';
import '../models/examResult.dart';
import '../screens/quizMainScreen.dart';
import '../screens/submitMainScreen.dart';
import '../screens/userMainScreen.dart';
import '../screens/resultMainScreen.dart';
import '../screens/viewQuestionScreen.dart';
import '../screens/listQuestionsScreen.dart';
import '../screens/listResultScreen.dart';
import '../screens/ViewResultScreen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  String route = Routes[0].route;
  List<String> path = [route];
  if(settings != null) {
    //print("${settings.name} ${settings.arguments}");
    if(settings.name != null) {
      path = Uri.decodeFull(Uri.parse(settings.name).toString()).split("/");
      //print(path);
      if(path.length > 1) {
        route = path[1];
      }
    }
  }
  //print('$path');
  if(route == Routes[1].route) {
    if(path.length == 2 || (path[2] != textRes.LABEL_QUICK_GAME && !categories.containsKey(path[2]))) {
      return _getPageRoute(SubmitMainScreen(), '/'+route);
    }
    return _getPageRoute(ListQuestionsScreen(category: path[2], userId: null,), settings.name);
  }
  if(route == QuestionRoute) {
    if(path.length == 2) {
      return _getPageRoute(SubmitMainScreen(), '/'+Routes[1].route);
    }
    Question question;
    print('Testing1 ${settings.name}');
    if(settings.arguments != null) {
      question = settings.arguments;
    }
    print('Testing2 ${settings.name}');
    return _getPageRoute(new ViewQuestionScreen(question: question, questionId: path[2]), settings.name);
  }
  if(route == Routes[2].route) {
    if(path.length == 2 || (path[2] != textRes.LABEL_QUICK_GAME && !categories.containsKey(path[2]))) {
      return _getPageRoute(resultMain, '/'+Routes[2].route);
    }
    if(path.length == 3) {
      return _getPageRoute(ListResultScreen(category: path[2]), settings.name);
    }
    int rank = 1;
    rank = int.parse(path[3]);
    ExamResult examResult;
    if(settings.arguments != null) {
      examResult = settings.arguments;
    }
    return _getPageRoute(ViewResultScreen(category: path[2], rank: rank, examResult: examResult), settings.name);
  }
  if(route == Routes[3].route) {
    if(path.length == 2) {
      return _getPageRoute(UserMainScreen(), '/'+route);
    }
    return _getPageRoute(ListQuestionsScreen(category: null, userId: user.id), settings.name);
  }
  return _getPageRoute(quizMain, '/'+Routes[0].route);
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