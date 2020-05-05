import 'package:OurlandQuiz/models/textRes.dart';
import 'package:flutter/material.dart';
import '../routing/routeNames.dart';
import '../locator.dart';
import '../services/navigationService.dart';


class ResultMainScreen extends StatelessWidget {
  @override
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<String> quizCategories = [];

  ResultMainScreen(List<String> categories) {
     quizCategories = [textRes.LABEL_QUICK_GAME];
     quizCategories.addAll(categories);
  }

  void _onTap(BuildContext context, String category) async {
    locator<NavigationService>().navigateTo('/${Routes[2].route}/${category}');
    /*
    Navigator.of(context).push(
      new MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return ListResultScreen(category: category);
        },
      ),
    );
    */
  }

  Widget catButton(BuildContext context, String category) {
    String title = category;
    if(category.length == 0) {
      title = textRes.LABEL_QUICK_GAME;
    }
    Widget rv = GestureDetector(
          onTap: () {_onTap(context, category);},
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
              padding: EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                //color: MEMO_COLORS[this.question.color],
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
                children: [Text(title)],
              ),
            ),
          ),
        );
    return rv;
  }

  Widget catSet(BuildContext context) {
    List<Widget> buttonWidgets = List<Widget>();
    print('quizCategories $quizCategories');
    quizCategories.forEach((category) {
      buttonWidgets.add(const SizedBox(height: 5.0));
      buttonWidgets.add(catButton(context, category));
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
    /*
    return Scaffold(
          appBar: PreferredSize(
                preferredSize: Size.fromHeight(MediaQuery.of(context).size.height/15), child:Container()
          ),
          body: //Home
              Container(
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
              )
    );
    */
  }
}