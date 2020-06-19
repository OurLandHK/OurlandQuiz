import 'package:OurlandQuiz/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'getUserScreen.dart';
import 'setUserScreen.dart';
import '../models/textRes.dart';
import '../models/userModel.dart';
import '../services/auth.dart';
import '../routing/routeNames.dart';
import '../locator.dart';
import '../services/navigationService.dart';
import '../widgets/categoryMemo.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class UserMainScreen extends StatefulWidget {
  String userid;
  UserMainScreen({Key key, @required this.userid});

  @override
  State createState() => new UserMainState();
}

class UserMainState extends State<UserMainScreen> {
  final ScrollController listScrollController = new ScrollController();
  User _profileUser;

  @override
  void initState() {
    super.initState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    authService.getUser(widget.userid).then((profileUser) {
      setState(() {
        _profileUser = profileUser;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    String title = _profileUser == null ? widget.userid: _profileUser.name;
    Widget rv = Container(
        child: SafeArea(
          top: false,
          bottom: false,
          child: gameSet(context)
        ),
      );
    if(widget.userid != user.id) {
      rv = Scaffold(
        appBar: new AppBar(
          backgroundColor: MEMO_COLORS[9],
          title: new Text(
            title,
            style: TextStyle(/*color: primaryColor,*/ fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            elevation: 0.7,
            actionsIconTheme: Theme.of(context).primaryIconTheme,
        ),
        body: rv
      );
    }
    return rv;
  }

  void _onTap(String menuItem) async {
    if(menuItem == textRes.USER_SETTING_MENU[0]) {
      locator<NavigationService>().navigateTo('/${MainRoutes[3].route}/${widget.userid}/question');
    } 
    if(menuItem == textRes.USER_SETTING_MENU[1]) {
      showDialog<void>(
      context: context,
      //barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return SetUserScreen();
      }); 
    }
    if(menuItem == textRes.USER_SETTING_MENU[2]) {
      showDialog<void>(
      context: context,
      //barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return GetUserScreen();
      }); 
    }
    if(menuItem == textRes.USER_SETTING_MENU[3]) {
      locator<NavigationService>().navigateTo('/${MainRoutes[3].route}/${widget.userid}/result');
    } 
  }

  Widget gameSet(BuildContext context) {
    List<Widget> buttonWidgets = [];
    int i = 0;
    textRes.USER_SETTING_MENU.forEach((label) {
      if(widget.userid == user.id || i == 0 || i == 3) {
        buttonWidgets.add(const SizedBox(height: 5.0));
        buttonWidgets.add(CategoryMemo(label, _onTap, []));
      }
      i++;
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
