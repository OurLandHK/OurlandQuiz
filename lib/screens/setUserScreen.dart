import 'dart:async';

import 'package:OurlandQuiz/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/services.dart';
import '../models/textRes.dart';
import '../services/auth.dart';
import '../models/userModel.dart';
//import 'homeScreen.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class SetUserScreen extends StatefulWidget {
  SetUserScreen({Key key});

  @override
  State createState() => new SetUserState();
}

class SetUserState extends State<SetUserScreen> {
  String _name = "";
  User _user;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _name = user.name;
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
    return AlertDialog(
        title: Text(
            textRes.USER_SETTING_MENU[1],
            style: TextStyle(/*color: primaryColor,*/ fontWeight: FontWeight.bold),
          ),
        content: SingleChildScrollView(child: body),
        actions: [_buildSubmit(context)]
    );
  }

  Widget idUI(BuildContext context, int focusIndex) {
    return TextFormField(
      initialValue: this._name,
      textInputAction: TextInputAction.next,
      //textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        border: UnderlineInputBorder(),
        filled: true,
        icon: Icon(Icons.verified_user),
        labelText: textRes.LABEL_USER_NAME,
      ),
      onChanged: (value) {setState(() {this._name = value;});},
      onSaved: (String value) {this._name = value;},
  // validator: _validateName,
    );
  }

  void setUser() {
    //if (_formKey.currentState.validate()) {
//    If all data are correct then save data to out variables
      _formKey.currentState.save();
      user.name = this._name;
      authService.updateUser(user).then((success){
        if(success) {
          onBackPress();
        } else {
          _scaffoldKey.currentState.showSnackBar(
              new SnackBar(content: new Text(textRes.LABEL_UPDATE_USER_FAIL)));
        }
      });      
    //}
  }

  Widget _buildSubmit(BuildContext context) {
    return RaisedButton(
            child: Text(textRes.LABEL_UPDATE_USER),
            onPressed: setUser,
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
          //_buildSubmit(context)
        ],
      )
    );
  }
}
