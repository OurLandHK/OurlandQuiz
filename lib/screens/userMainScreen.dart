import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'homeScreen.dart';
import 'getUserScreen.dart';
import '../models/textRes.dart';
import '../models/userModel.dart';
import '../services/auth.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class UserMainScreen extends StatefulWidget {
  UserMainScreen({Key key});

  @override
  State createState() => new UserMainState();
}

class UserMainState extends State<UserMainScreen> {
  final ScrollController listScrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    //if (!mounted) return;

    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body = gameSet(context);      
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: Column(children: [
          Text(
            user.name + textRes.LABEL_USER_INFO,
            style: TextStyle(/*color: primaryColor,*/ fontWeight: FontWeight.bold),
          ),
        ]),
        centerTitle: true,
        elevation: 0.7,
        actionsIconTheme: Theme.of(context).primaryIconTheme,
      ),
      body: Container(
        child: SafeArea(
          top: false,
          bottom: false,
          child: body
        ),
      ),
    ); 
  }

  void _onTap(String menuItem) async {
    Navigator.of(context).push(
      new MaterialPageRoute<void>(
        builder: (BuildContext context) {
          Widget rv = null;
          if(menuItem == textRes.USER_SETTING_MENU[2]) {
            rv= GetUserScreen();
          }
          return rv;
        },
      ),
    );
  }

  Widget menuButton(BuildContext context, String category) {
    String title = category;
    if(category.length == 0) {
      title = textRes.LABEL_QUICK_GAME;
    }
    Widget rv = GestureDetector(
          onTap: () {_onTap(category);},
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

  Widget gameSet(BuildContext context) {
    List<Widget> buttonWidgets = [];
    textRes.USER_SETTING_MENU.forEach((label) {
      buttonWidgets.add(const SizedBox(height: 5.0));
      buttonWidgets.add(menuButton(context, label));
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
