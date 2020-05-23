import 'package:OurlandQuiz/models/textRes.dart';
import 'package:flutter/material.dart';
import '../routing/routeNames.dart';
import '../locator.dart';
import '../services/navigationService.dart';
import '../widgets/categoryMemo.dart';


class ResultMainScreen extends StatelessWidget {
  @override
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<String> quizCategories = [];

  ResultMainScreen(List<String> categories) {
     quizCategories = [textRes.LABEL_QUICK_GAME];
     quizCategories.addAll(categories);
  }

  void _onTap(String category) async {
    locator<NavigationService>().navigateTo('/${Routes[2].route}/${category}');
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
    return Container(
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
  }
}