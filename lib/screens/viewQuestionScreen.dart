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
import '../services/questionService.dart';
import '../services/auth.dart';
import '../models/question.dart';
import '../helper/uiHelper.dart';
import 'package:open_graph_parser/open_graph_parser.dart';
import 'homeScreen.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class ViewQuestionScreen extends StatefulWidget {
  final Question question;
  ViewQuestionScreen({Key key, @required this.question});

  @override
  State createState() => new ViewQuestionState();
}

class ViewQuestionState extends State<ViewQuestionScreen> {
  File imageFile;
  //SharedPreferences prefs;
  //Question _currentQuestion;
  String _newTitleLabel;
  String _desc = "";
  String _parentTitle = "";
  String _reference = "";
  bool _isSubmitDisable;

  final TextEditingController textEditingController = new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  List<DropdownMenuItem<String>> _tagDropDownMenuItems;

  String _firstTag;
  bool _addMode = true;
  TextEditingController _descController;
  List<String> _tags = [];
  List<String> _options = ["","","","",""];
  List<bool> _answers = [false, false, false, false, false];
  int _color;
  Text _sendButtonText;
  List<FocusNode> _focusNodes = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    
    int _userInputFields = 1 + 1 + 2 * 5 + 2 + 1; //title + header + option pair + link, desc+ button
    for(int i = 0; i < _userInputFields; i++) {
      FocusNode _focusNode = FocusNode();
      _focusNode.addListener(onFocusChange);
      _focusNodes.add(_focusNode);
    }
    List<String> dropdownList = categories.keys.toList();
    print(dropdownList);
    _tagDropDownMenuItems = getDropDownMenuItems(dropdownList, "");
    if(widget.question == null) {  
      _firstTag = _tagDropDownMenuItems[0].value;  
      _newTitleLabel = textRes.LABEL_NEW_QUESTION;
      _sendButtonText = new Text(textRes.LABEL_MISSING_NEW_QUESTION);
      Random rng = new Random();
      _color = rng.nextInt(MEMO_COLORS.length);
      _isSubmitDisable = true;
      _descController = TextEditingController(text:'');
    } else {
      _firstTag = widget.question.tags[0];
      _addMode = false;
      _tags = widget.question.tags;
      _options = widget.question.options;
      for(int i = 0; i < _options.length; i++) {
        if(widget.question.answers.contains(_options[i])) {
          _answers[i] = true;
        }
      }
      _desc = widget.question.explanation;
      _parentTitle = widget.question.title;
      _reference = widget.question.referenceUrl;
      _newTitleLabel = _parentTitle;

      _color = widget.question.color;
      _isSubmitDisable = false;
      _descController = TextEditingController(text: widget.question.explanation);
    }
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

  void onFocusChange() {
    if (_focusNodes[0].hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
      });
    }
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
        backgroundColor: MEMO_COLORS[_color],
        title: new Text(
          _newTitleLabel,
          style: TextStyle(/*color: primaryColor,*/ fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0.7,
        actionsIconTheme: Theme.of(context).primaryIconTheme,
      ),
      body: Container(
        color: MEMO_COLORS[_color],
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

  Future getImageFromGallery() async {
    if (!kIsWeb) {
      await mobGetImage(MobImagePicker.ImageSource.gallery);
    } else {
      await webGetImage(WebImagePicker.ImageType.file);
    }
  }

  Future getImageFromCamera() async {
    await mobGetImage(MobImagePicker.ImageSource.camera);
  }

  Future webGetImage(WebImagePicker.ImageType outputType) async {
    File newImageFile = await WebImagePicker.ImagePickerWeb.getImage(outputType: outputType);
    if (newImageFile != null) {
      setState(() {
        imageFile = newImageFile;
        //print("${imageFile.uri.toString()}");
      });
    }
  }  

  Future mobGetImage(MobImagePicker.ImageSource imageSource) async {
    File newImageFile = await MobImagePicker.ImagePicker.pickImage(source: imageSource);

    if (newImageFile != null) {
      setState(() {
        imageFile = newImageFile;
        //print("${imageFile.uri.toString()}");
      });
    }
  }

  Widget titleUI(BuildContext context, int focusIndex) {
    return TextFormField(
      enabled: _addMode,
      initialValue: this._parentTitle,
      focusNode: _focusNodes[focusIndex],
      onFieldSubmitted: (term) {
        fieldFocusChange(context, _focusNodes[focusIndex], _focusNodes[focusIndex+1]);
      },
      textInputAction: TextInputAction.next,
      //textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        border: UnderlineInputBorder(),
        filled: true,
        icon: Icon(Icons.live_help),
        labelText: textRes.LABEL_QUESTION,
      ),
      minLines: 1,
      maxLines: 10,
      onChanged: (value) {setState(() {this._parentTitle = value;});},
      onSaved: (String value) {this._parentTitle = value;},
  // validator: _validateName,
    );
  }

  Widget tagUI(BuildContext context) {
    List<Chip> chips = [];
    this._tags.forEach((tag) {
      chips.add(Chip(label: Text(tag)));
    });
    return Wrap(runSpacing: 4.0, spacing: 8.0, children: chips);
  }
  Widget answerHeader(BuildContext context) {
    return Row(children: <Widget> [
      SizedBox(
        child: Text(textRes.LABEL_OPTION, textAlign: TextAlign.center),
        width: MediaQuery.of(context).size.width - 60,
      ),
    ]);
  }

  Widget optionWidget(BuildContext context, int answerIndex) {
    bool displayResult = user.questionIDs.contains(widget.question.id);
    BoxDecoration decoration;
    if(displayResult? _answers[answerIndex]:false) {
      decoration = BoxDecoration(
          //gradient: gradient,
          border: Border.all(width: 1, color: Colors.red),
          color: Colors.white,
        );
    } else {
      decoration = BoxDecoration(
          //gradient: gradient,
          //border: Border.all(width: 0.5, color: Colors.red),
          color: Colors.grey,
        );
    }
    return SizedBox(
      width: MediaQuery.of(context).size.width - 60,
      child: Container(
        decoration: decoration,
        child: 
          FlatButton(
            child: Text(this._options[answerIndex]), 
          )
      )
    );
  }

  Widget referenceWidget(BuildContext context, int focusIndex) {
    if(this._reference.length > 0) {
      if(this._reference.contains("http")) {
        TextStyle style = Theme.of(context).textTheme.body2;
        style.apply(decoration: TextDecoration.underline);
        Widget widget1 = Padding(
          padding: EdgeInsets.all(2.0),
          child: new Text(this._reference,
              overflow: TextOverflow.ellipsis,
              style: style,
              textAlign: TextAlign.left));
      return InkWell(child: widget1, onTap: () => launchURL(this._reference));

      } else {
        return TextFormField(
          enabled: _addMode,
          initialValue: this._reference,
          focusNode: _focusNodes[focusIndex],
            onFieldSubmitted: (term) {
              fieldFocusChange(context, _focusNodes[focusIndex], _focusNodes[focusIndex+1]);
            },
          textInputAction: TextInputAction.next,
          //textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            border: UnderlineInputBorder(),
            filled: true,
            icon: Icon(Icons.link),
            hintText: textRes.HINT_REFERENCE,
            labelText: textRes.LABEL_REFERENCE,
          ),
          onSaved: (String value) {this._reference= value;},
        // validator: _validateName,
          );
      }
    } else {
      return Container();
    }
  }

  Widget descUI(BuildContext context, int focusIndex) {
    return TextFormField(
      //enabled: _addMode,
      controller: _descController,
      focusNode: _focusNodes[focusIndex],
        onFieldSubmitted: (term) {
          fieldFocusChange(context, _focusNodes[focusIndex], _focusNodes[focusIndex+1]);
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        icon: Icon(Icons.note),
        hintText: textRes.HINT_DEATIL,
        helperText: textRes.HELPER_DETAIL,
        labelText: textRes.LABEL_DETAIL,
      ),
      minLines: 1,
      maxLines: 10,
      onChanged: (value) {searchForKeywords(value);},
      onSaved: (String value) {this._desc = value;},
    );
  }

  Widget topicImageUI(BuildContext context) {
    return 
      Column(children: <Widget>[
        Row(children: <Widget> [
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 1.0),
              child: new IconButton(
                icon: new Icon(Icons.image),
                onPressed: getImageFromGallery,
                //color: primaryColor,
              ),
            ),
            color: MEMO_COLORS[_color],
          ),
          (!kIsWeb) ?
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 1.0),
              child: new IconButton(
                icon: new Icon(Icons.camera_enhance),
                onPressed: getImageFromCamera,
                //color: primaryColor,
              ),
            ),
            color: MEMO_COLORS[_color],
          ) : Container(),
          imageFile != null ? Stack(children: [Image.file(
            imageFile, width: MediaQuery.of(context).size.width / 2
          ), IconButton(icon: Icon(Icons.close), onPressed: removeImage,)]) : new Container(), 
        ]
      )        
    ],
    crossAxisAlignment: CrossAxisAlignment.center,
    );
  }

  void removeImage() {setState((){imageFile = null;});}

  void searchForKeywords(String desc) {
    String parseText = desc.replaceAll("\n", " ");
    List<String> tempTags = StringHelper.keywordSearch(parseText, "#");
    setState(() {
      _tags = tempTags;
    });
  }

  Widget formUI(BuildContext context) {
    List<Widget> toolbarWidget = [];
    toolbarWidget.add(Expanded(flex: 1, child: new Text(textRes.LABEL_TOPIC)));
    if(_addMode) {
      toolbarWidget.add(Expanded(flex: 2, child: new DropdownButton(
                  value: _firstTag,
                  items: _tagDropDownMenuItems,
                  onChanged: (String value) {setState(() {_firstTag = value;});},
                )));
    } else {
      toolbarWidget.add(Expanded(flex: 2, child: new Text(_firstTag)));
    }
    Row toolbar = Row(children: toolbarWidget);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          toolbar,
          titleUI(context, 0),
          const SizedBox(height: 5.0),
          tagUI(context),
          (!kIsWeb) ? topicImageUI(context): Container(), 
          const SizedBox(height: 5.0),
          referenceWidget(context,12),
          const SizedBox(height: 5.0),
          descUI(context,13),
          answerHeader(context),
          optionWidget(context, 0), 
          optionWidget(context, 1),
          optionWidget(context, 2),
          optionWidget(context, 3),
          optionWidget(context, 4),  
          const SizedBox(height: 5.0),                                      

          //_buildSubmit(context)
        ],
      )
    );
  }
}
