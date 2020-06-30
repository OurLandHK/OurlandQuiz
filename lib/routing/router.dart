import 'package:OurlandQuiz/models/textRes.dart';

import '../main.dart';
import 'package:OurlandQuiz/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import './routeNames.dart';
import '../models/question.dart';
import '../models/examResult.dart';
import '../models/userModel.dart';
import '../screens/submitMainScreen.dart';
import '../screens/userMainScreen.dart';
import '../screens/resultMainScreen.dart';
import '../screens/viewQuestionScreen.dart';
import '../screens/listQuestionsScreen.dart';
import '../screens/listResultScreen.dart';
import '../screens/ViewResultScreen.dart';
import '../screens/QuizGameScreen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  String route = MainRoutes[0].route;
  List<String> path = [route];
  print(settings.arguments);
  print(settings.name);
  if(settings != null) {
    if(settings.name != null) {
      path = Uri.decodeFull(Uri.parse(settings.name).toString()).split("/");
      //print(path);
      if(path.length > 1) {
        route = path[1];
      }
    }
  }
  if(route == MainRoutes[1].route) {
    if(path.length == 2 || !categories.containsKey(path[2])) {
      return _getPageRoute(SubmitMainScreen(), '/'+route);
    }
    return _getPageRoute(ListQuestionsScreen(category: path[2], userId: null,), settings.name);
  }
  if(route == QuestionRoute) {
    if(path.length == 2) {
      return _getPageRoute(SubmitMainScreen(), '/'+MainRoutes[1].route);
    }
    Question question;
    //print('Testing1 ${settings.name}');
    if(settings.arguments != null) {
      question = settings.arguments;
    }
    //print('Testing2 ${settings.name}');
    return _getPageRoute(new ViewQuestionScreen(question: question, questionId: path[2]), settings.name);
  }
  if(route == ValidateRoute) {
    //layoutTemplate.showNaviBar(false);
    return _getPageRoute(new QuizGameScreen(mode: ValidateRoute, category: "", totalQuestion: 2), settings.name);
  }
  if(route == MainRoutes[2].route) {
    
    if(path.length == 2) {
      return _getPageRoute(resultMain, '/'+MainRoutes[2].route);
    }
    List<String> temp = path[2].split("_");
    String cat = temp[0];
    String mode = GameModes[0].label;
    if(temp.length == 2) {
      String tempMode = temp[1];
      int modeIndex = int.parse(tempMode);
      if(modeIndex > 0) {
        mode = GameModes[modeIndex].label;
      }
    }
    if(cat != textRes.LABEL_ALL && !categories.containsKey(cat)) {
      return _getPageRoute(resultMain, '/'+MainRoutes[2].route);
    }
    
    if(path.length == 3) {

      return _getPageRoute(ListResultScreen(mode: mode, category: cat, userid: null), settings.name);
    }
    int rank = 1;
    rank = int.parse(path[3]);
    ExamResult examResult;
    if(settings.arguments != null) {
      examResult = settings.arguments;
    }
    return _getPageRoute(ViewResultScreen(mode: mode, category: cat, rank: rank, examResult: examResult), settings.name);
  }
  if(route == MainRoutes[3].route) {
    String userid;
    if(path.length == 2) {
      path.add(user.id);
      userid = user.id;
    } else {
      userid = path[2];
    }
    if(path.length == 4) {
      print(settings.name);
      switch(path[3]) {
        case 'result':
          return _getPageRoute(ResultMainScreen(categories.keys.toList(), userid), settings.name);
          break;
        case 'question':
          return _getPageRoute(ListQuestionsScreen(category: null, userId: userid), settings.name);
          break;
      }
    }
    if(path.length == 5) {
      print(settings.name);
      if(path[3] == 'result') {
        List<String> temp = path[4].split("_");
        String cat = temp[0];
        String mode = GameModes[0].label;
        if(temp.length == 2) {
          String tempMode = temp[1];
          int modeIndex = int.parse(tempMode);
          if(modeIndex > 0) {
            mode = GameModes[modeIndex].label;
          }
        }
        return _getPageRoute(ListResultScreen(mode: mode, category: cat, userid: userid), settings.name);
      }
    }
    return _getPageRoute(UserMainScreen(userid: userid), '/'+MainRoutes[3].route +'/'+userid);
  }
  return _getPageRoute(quizMain, '/'+MainRoutes[0].route);
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