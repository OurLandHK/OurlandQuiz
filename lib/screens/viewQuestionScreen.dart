import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:OurlandQuiz/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/services.dart';
import 'package:flutter_clipboard_manager/flutter_clipboard_manager.dart';


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

import 'dart:html' as html;


final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class ViewQuestionScreen extends StatefulWidget {
  final Question question;
  final String questionId;
  ViewQuestionScreen({@required this.question, @required this.questionId}) {
    print('screen');
  }

  @override
  State createState() => new ViewQuestionState(question: this.question, questionId: this.questionId);
}

class ViewQuestionState extends State<ViewQuestionScreen> {
  var url = html.window.location.href;
  File imageFile;
  //SharedPreferences prefs;
  //Question _currentQuestion;
  String _newTitleLabel;
  String _desc = "";
  String _parentTitle = "";
  String _reference = "";
  bool _isSubmitDisable;
  Question question;
  final String questionId;  

  ViewQuestionState({@required this.question, @required this.questionId}) {
    print('state');
  }
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
    print('init state');
    
    int _userInputFields = 1 + 1 + 2 * 5 + 2 + 1; //title + header + option pair + link, desc+ button
    for(int i = 0; i < _userInputFields; i++) {
      FocusNode _focusNode = FocusNode();
      _focusNode.addListener(onFocusChange);
      _focusNodes.add(_focusNode);
    }
    List<String> dropdownList = categories.keys.toList();
    print(dropdownList);
    _tagDropDownMenuItems = getDropDownMenuItems(dropdownList, "");
    if(this.question == null) {  
      _firstTag = _tagDropDownMenuItems[0].value;  
      _newTitleLabel = textRes.LABEL_NEW_QUESTION;
      _sendButtonText = new Text(textRes.LABEL_MISSING_NEW_QUESTION);
      Random rng = new Random();
      _color = rng.nextInt(MEMO_COLORS.length);
      _isSubmitDisable = true;
      _descController = TextEditingController(text:'');
      if(this.questionId != null && this.questionId.length > 0) {
        initPlatformState();
      }     
    } else {
      updateUI();
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    print('initPlatformState');
    questionService.getQuestion(this.questionId).then((question) {
      if(question != null) {
        this.question = question;
        updateUI();
      }
    });
  }

  void updateUI() {
    setState(() {
      _firstTag = this.question.tags[0];
      _addMode = false;
      _tags = this.question.tags;
      _options = this.question.options;
      for(int i = 0; i < _options.length; i++) {
        if(this.question.answers.contains(_options[i])) {
          _answers[i] = true;
        }
      }
      _desc = this.question.explanation;
      _parentTitle = this.question.title;
      _reference = this.question.referenceUrl;
      _newTitleLabel = _parentTitle;

      _color = this.question.color;
      _isSubmitDisable = false;
      _descController = TextEditingController(text: this.question.explanation);
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
        actions: <Widget>[_buildShare(context)],
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


  Widget _buildShare(BuildContext context) {
    Widget rv;
    String msg = '${question.title}\n';
    int i = 1;
    question.options.forEach((element) {
      msg += '${i++}. ${element}\n';
    });
    msg += '#${question.tags[0]}\n';
    rv = Row(children: <Widget>[
      RaisedButton(
        child: Text(textRes.LABEL_SHARE_TO_CLIPBOARD),
        onPressed: () async {
          Clipboard.setData(ClipboardData(text: "$msg $url")).then((reult) {
                        final snackBar = SnackBar(
                          content: Text('Copied to Clipboard'),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () {},
                          ),
                        );
                        Scaffold.of(context).showSnackBar(snackBar);
                      });
        },
      )


      
      /*
      RaisedButton(
        child: Text('share to twitter'),
        onPressed: () async {
          var response = await FlutterShareMe().shareToTwitter(
              url: url, msg: msg);
          if (response == 'success') {
            print('navigate success');
          }
        },
      ),
      RaisedButton(
        child: Text('share to WhatsApp'),
        onPressed: () {
          FlutterShareMe()
              .shareToWhatsApp(msg: msg);
        },
      ),
      RaisedButton(
        child: Text('share to shareFacebook'),
        onPressed: () {
          FlutterShareMe().shareToFacebook(
              url: url, msg: msg);
        },
      ),
      RaisedButton(
        child: Text('share to System'),
        onPressed: () async {
          var response = await FlutterShareMe().shareToSystem(msg: msg);
          if (response == 'success') {
            print('navigate success');
          }
        },
      )
      */
    ]);
    return rv;
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
    bool displayResult = (this.question != null && user.questionIDs.contains(this.question.id));
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
    toolbarWidget.add(Expanded(flex: 2, child: new Text(_firstTag)));
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
          //const SizedBox(height: 5.0),
          //_buildShare(context)                                   
        ],
      )
    );
  }
}