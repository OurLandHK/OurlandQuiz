import 'dart:async';

import 'package:OurlandQuiz/models/textRes.dart';
import 'package:flutter/material.dart';
import '../routing/routeNames.dart';
import '../locator.dart';
import '../services/navigationService.dart';
import '../widgets/categoryMemo.dart';
import '../models/userModel.dart';
import '../services/auth.dart';

class ResultMainScreen extends StatelessWidget {

  List<String> quizCategories = [];
  final String userid;

  ResultMainScreen(List<String> categories, @required this.userid) {
     quizCategories = [textRes.LABEL_QUICK_GAME];
     quizCategories.addAll(categories);
  }

  void _onTap(String category) async {
    if(userid == null) {
      locator<NavigationService>().navigateTo('/${Routes[2].route}/${category}');
    } else {
      locator<NavigationService>().navigateTo('/${Routes[3].route}/${userid}/result/${category}');
    }
  }

  Widget catSet(BuildContext context) {
    List<Widget> buttonWidgets = List<Widget>();
    quizCategories.forEach((category) {
      buttonWidgets.add(const SizedBox(height: 5.0));
      buttonWidgets.add(CategoryMemo(category, _onTap, []));
    });
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: buttonWidgets
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body = Container(
                color: Colors.white,
                child: SafeArea(
                  top: false,
                  bottom: false,
                  child: SingleChildScrollView(
                    child:Column(
                      children: [
                        catSet(context),
                      ]
                    ), 
                  )
                )
              );
    Widget rv = body;
    if(userid!= null) {
      rv = Scaffold(
        appBar: new AppBar(
          backgroundColor: MEMO_COLORS[9],
          title: new Text(
            textRes.USER_SETTING_MENU[3],
            style: TextStyle(/*color: primaryColor,*/ fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            elevation: 0.7,
            actionsIconTheme: Theme.of(context).primaryIconTheme,
        ),
        body: body
      );
    }
    return rv;
  }
}