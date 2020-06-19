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
  BuildContext _context;

  ResultMainScreen(List<String> categories, @required this.userid) {
     quizCategories.addAll(categories);
  }
  @override
  Widget build(BuildContext context) {
    _context = context;
    Widget body = Container(
                color: Colors.white,
                child: SafeArea(
                  top: false,
                  bottom: false,
                  child: gameMode(context)
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

  Future<bool> onBackPress() {
    Navigator.pop(_context);
    return Future.value(false);
  }

  void _onTapGameMode(String mode) async {
    showDialog<void>(
      context: _context,
      //barrierDismissible: true, 
      builder: (BuildContext context) {
        return ResultModeDialog(mode, quizCategories, userid);
    }); 
  }

  Widget gameMode(BuildContext context) {
    List<Widget> buttonWidgets = [
    ];
    GameModes.forEach((gameMode) {
      buttonWidgets.add(const SizedBox(height: 5.0));
      buttonWidgets.add(CategoryMemo(gameMode.label, _onTapGameMode, [gameMode.desc]));
    });
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: buttonWidgets
      )
    );
  }
}

class ResultModeDialog extends StatelessWidget {
  String mode;
  String userid;
  List<String> quizCategories;
  ResultModeDialog(this.mode, this.quizCategories, this.userid) ;
  BuildContext _context;

  static String _getDocumentId(String mode, String category) {
    String gameModeSuffix = "";
    if(mode != GameModes[0].label) {
      for(int i = 1; i < GameModes.length; i++) {
        if(mode == GameModes[i].label) {
          gameModeSuffix = "_" + i.toString();
        }
      }
    }
    String documentId = category;
    if(documentId.length == 0) {
      documentId = textRes.LABEL_ALL;
    }
    documentId +=gameModeSuffix;
    return documentId;
  }

  void _onTap(String category) async {
    Navigator.pop(_context);
    String catString = _getDocumentId(mode, category);
    if(userid == null) {
      locator<NavigationService>().navigateTo('/${MainRoutes[2].route}/${catString}');
    } else {
      locator<NavigationService>().navigateTo('/${MainRoutes[3].route}/${userid}/result/${catString}');
    }
  }

  Future<bool> onBackPress() {
    Navigator.pop(_context);
    return Future.value(false);
  }
  

  Widget gameSet(BuildContext context) {
    List<Widget> buttonWidgets = [];
    quizCategories.forEach((category) {
      buttonWidgets.add(const SizedBox(height: 5.0));
      buttonWidgets.add(CategoryMemo(category, _onTap, []));
    });
    buttonWidgets.insert(0, CategoryMemo("", _onTap, []));
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
    _context = context;
    
    Widget body = new WillPopScope(
      child: Container(
        child: SafeArea(
          top: false,
          bottom: false,
          child: gameSet(context)
        )
      ),
      onWillPop: onBackPress,
    );
    return AlertDialog(
        title: Text(
            mode,
            style: TextStyle(/*color: primaryColor,*/ fontWeight: FontWeight.bold),
          ),
        content: SingleChildScrollView(child: body),
        //actions: [_buildSubmit(context)]
    );
  }
}
