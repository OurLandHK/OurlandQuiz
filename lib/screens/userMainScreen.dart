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
    return  Container(
        child: SafeArea(
          top: false,
          bottom: false,
          child: body
        ),
      );
  }

  void _onTap(String menuItem) async {
    if(menuItem == textRes.USER_SETTING_MENU[0]) {
      locator<NavigationService>().navigateTo('/${Routes[3].route}/${user.id}');
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
  }

  Widget gameSet(BuildContext context) {
    List<Widget> buttonWidgets = [];
    textRes.USER_SETTING_MENU.forEach((label) {
      buttonWidgets.add(const SizedBox(height: 5.0));
      buttonWidgets.add(CategoryMemo(label, _onTap, []));
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
