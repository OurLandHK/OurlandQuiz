import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:OurlandQuiz/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/services.dart';


import 'package:image_picker/image_picker.dart' as MobImagePicker;
import 'package:image_picker_web/image_picker_web.dart' as WebImagePicker;

import 'package:shared_preferences/shared_preferences.dart';

import '../helper/stringHelper.dart';
import '../helper/uiHelper.dart';
import '../models/textRes.dart';
import '../services/auth.dart';
import '../models/userModel.dart';
import '../widgets/colorPicker.dart';
import 'package:open_graph_parser/open_graph_parser.dart';
import 'homeScreen.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class GetUserScreen extends StatefulWidget {
  GetUserScreen({Key key});

  @override
  State createState() => new GetUserState();
}

class GetUserState extends State<GetUserScreen> {
  String _id = "";
  String _passcode = "";
  User _user;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _id = user.id;
    _passcode = user.passcode;
    super.initState();
  }

  Future<bool> onBackPress() {
    Navigator.pop(context);
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    Widget body = new WillPopScope(
      child: Column(
        children: <Widget>[            
          new Form(
            key: _formKey,
            autovalidate: true,
            child: formUI(context)
          )
        ],
      ),
      onWillPop: onBackPress,
    );
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(
          textRes.USER_SETTING_MENU[2],
          style: TextStyle(/*color: primaryColor,*/ fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0.7,
        actionsIconTheme: Theme.of(context).primaryIconTheme,
      ),
      body: Container(
        //child: new Container(),
        child: SafeArea(
          top: false,
          bottom: false,
          child: SingleChildScrollView(
            child: body
          ),
        ),

      ),
    ); 
  }

  Widget idUI(BuildContext context, int focusIndex) {
    return TextFormField(
      initialValue: this._id,
      textInputAction: TextInputAction.next,
      //textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        border: UnderlineInputBorder(),
        filled: true,
        icon: Icon(Icons.verified_user),
        labelText: textRes.LABEL_USER_ID,
      ),
      onChanged: (value) {setState(() {this._id = value;});},
      onSaved: (String value) {this._id = value;},
  // validator: _validateName,
    );
  }

  Widget passcodeUI(BuildContext context, int focusIndex) {
    return TextFormField(
      initialValue: this._passcode,
      textInputAction: TextInputAction.next,
      //textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        border: UnderlineInputBorder(),
        filled: true,
        icon: Icon(Icons.code),
        labelText: textRes.LABEL_PASSCODE,
      ),
      onChanged: (value) {setState(() {this._passcode = value;});},
      onSaved: (String value) {this._passcode = value;},
  // validator: _validateName,
    );
  }  

  void sendPendingQuestion() {
    //if (_formKey.currentState.validate()) {
//    If all data are correct then save data to out variables
      _formKey.currentState.save();
      authService.getUser(this._id).then((newUser) {
        print(newUser);
        if(newUser != null && newUser.passcode == this._passcode) {
          sharedPreferences.setString('userID', newUser.id).then((value) {
            setState(() {
              user = newUser;
            });
          });
          onBackPress();
        } else {
          _scaffoldKey.currentState.showSnackBar(
              new SnackBar(content: new Text(textRes.LABEL_ID_PASSCODE_WRONG)));
        }       
      });
      
    //}
  }

  Widget _buildSubmit(BuildContext context) {
    return RaisedButton(
            child: Text(textRes.LABEL_VERIFY),
            onPressed: sendPendingQuestion,
          );
  }

  Widget formUI(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          idUI(context, 0),
          const SizedBox(height: 5.0),
          passcodeUI(context, 1),
          const SizedBox(height: 5.0),                                      
          _buildSubmit(context)
        ],
      )
    );
  }
}
