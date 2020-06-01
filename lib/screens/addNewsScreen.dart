import 'dart:async';

import 'package:OurlandQuiz/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/services.dart';
import '../models/textRes.dart';
import '../services/newsService.dart';
import '../models/userModel.dart';
import '../models/news.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class AddNewsScreen extends StatefulWidget {
  AddNewsScreen({Key key});

  @override
  State createState() => new AddNewsState();
}

class AddNewsState extends State<AddNewsScreen> {
  String _title = "";
  String _desc = "";

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {

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
      initialValue: this._title,
      textInputAction: TextInputAction.next,
      //textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        border: UnderlineInputBorder(),
        filled: true,
        //icon: Icon(Icons.verified_user),
        labelText: textRes.LABEL_NEWS_TITLE,
      ),
      onChanged: (value) {setState(() {this._title = value;});},
      onSaved: (String value) {this._title = value;},
  // validator: _validateName,
    );
  }

  Widget descUI(BuildContext context, int focusIndex) {
    return TextFormField(
      initialValue: this._desc,
      textInputAction: TextInputAction.next,
      //textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        border: UnderlineInputBorder(),
        filled: true,
        //icon: Icon(Icons.verified_user),
        labelText: textRes.LABEL_NEWS_DETAIL,
      ),
      minLines: 2,
      maxLines: 5,
      onChanged: (value) {setState(() {this._desc = value;});},
      onSaved: (String value) {this._desc = value;},
  // validator: _validateName,
    );
  }

  void setNews() {
    //if (_formKey.currentState.validate()) {
//    If all data are correct then save data to out variables
      _formKey.currentState.save();
      News news = new News(_title, _desc);
      newsService.addNews(news).then((success){
        if(success) {
          onBackPress();
        } else {
          _scaffoldKey.currentState.showSnackBar(
              new SnackBar(content: new Text(textRes.LABEL_UPDATE_NEWS_FAIL)));
        }
      });      
    //}
  }

  Widget _buildSubmit(BuildContext context) {
    return RaisedButton(
            child: Text(textRes.LABEL_UPDATE_NEWS),
            onPressed: setNews,
          );
  }

  Widget formUI(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          idUI(context, 0),
          descUI(context, 1),
          const SizedBox(height: 5.0),
        ],
      )
    );
  }
}
