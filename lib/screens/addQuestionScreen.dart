import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:html'as html;

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
import '../widgets/colorPicker.dart';
import 'package:open_graph_parser/open_graph_parser.dart';


final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class AddQuestionScreen extends StatefulWidget {
  final Question question;
  AddQuestionScreen({Key key, @required this.question});

  @override
  State createState() => new AddQuestionState();
}

class AddQuestionState extends State<AddQuestionScreen> {
  File imageFile;
  Image image;
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
      _newTitleLabel = textRes.LABEL_APPROVE + ": " + _parentTitle;

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
    Uint8List rawbyte = await WebImagePicker.ImagePickerWeb.getImage(outputType: WebImagePicker.ImageType.bytes);
    File newImageFile = File.fromRawPath(rawbyte);
    Image tempImage = Image.file(newImageFile);
    if(tempImage != null) {
      setState(() {
        image = tempImage;
        imageFile = newImageFile;
      });
    }
  }  

  Future mobGetImage(MobImagePicker.ImageSource imageSource) async {
    File newImageFile = await MobImagePicker.ImagePicker.pickImage(source: imageSource);
    if (newImageFile != null) {
      Image tempImage = Image.file(newImageFile);
      if(tempImage != null) {
      setState(() {
        image = tempImage;
        imageFile = newImageFile;
        //print("${imageFile.uri.toString()}");
      });
      }
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
        hintText: textRes.HINT_QUESTION,
        labelText: textRes.LABEL_QUESTION,
      ),
      minLines: 1,
      maxLines: 10,
      validator: (value) {
        return validation(textRes.LABEL_QUESTION, value);
      },
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
  Widget answerHeader(BuildContext context, int focusIndex) {
    return Row(children: <Widget> [
      SizedBox(
        child: Text(textRes.LABEL_OPTION, textAlign: TextAlign.center),
        width: MediaQuery.of(context).size.width - 60,
      ),
      Text(textRes.LABEL_ANSWER, textAlign: TextAlign.center),
    ]);
  }

  Widget optionWidget(BuildContext context, int answerIndex,int focusIndex) {
    return Row(children: <Widget> [
      SizedBox(
        child: TextFormField(
          enabled: _addMode,
          initialValue: this._options[answerIndex],
          focusNode: _focusNodes[focusIndex],
          onFieldSubmitted: (term) {
            fieldFocusChange(context, _focusNodes[focusIndex], _focusNodes[focusIndex+1]);
          },
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            border: UnderlineInputBorder(),
            filled: true,
            icon: Icon(Icons.info),
            labelText: (answerIndex+1).toString(),
          ),
          validator: (value) {
            return validation(textRes.LABEL_OPTION, value);
          },
          //onChanged: (value) {checkforLink(value);},
          onSaved: (String value) {_options[answerIndex] = value;},
        // validator: _validateName,
        ),
        width: MediaQuery.of(context).size.width - 70,
      ),
      Checkbox(
        focusNode: _focusNodes[focusIndex+1],
        value: _answers[answerIndex],
        onChanged: (bool value) {
          if(_addMode) {
            validation(textRes.LABEL_ANSWER, "");
            setState(() {
              _answers[answerIndex] = value;
            });
          }
        }
      ),
    ]);
  }

  Widget referenceWidget(BuildContext context, int focusIndex) {
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
      validator: (value) {
        return validation(textRes.LABEL_REFERENCE, value);
      },
      onChanged: (value) {checkforLink(value);},
      onSaved: (String value) {this._reference= value;},
    // validator: _validateName,
      );
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
      validator: (value) {
        return validation(textRes.LABEL_DETAIL, value);
      },
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
          image != null ? Stack(children: [SizedBox(width: MediaQuery.of(context).size.width / 2, child: image),
           IconButton(icon: Icon(Icons.close), onPressed: removeImage,)]) : new Container(),
          /*
          imageFile != null ? Stack(children: [Image.file(
            imageFile, width: MediaQuery.of(context).size.width / 2
          ), IconButton(icon: Icon(Icons.close), onPressed: removeImage,)]) : new Container(), */
        ]
      )        
    ],
    crossAxisAlignment: CrossAxisAlignment.center,
    );
  }

  void removeImage() {setState((){image = null;});}

  void searchForKeywords(String desc) {
    String parseText = desc.replaceAll("\n", " ");
    List<String> tempTags = StringHelper.keywordSearch(parseText, "#");
    setState(() {
      _tags = tempTags;
    });
  }

  void checkforLink(String topic) {
    if(topic.contains("http")) {
      OpenGraphParser.getOpenGraphData(topic).then((Map data) {
        if(data['title'] != null) {
          String topicTitle = data['title'];
          print("Desc: $topicTitle");
          setState(() {
            _descController.text = topicTitle;
          });
        }
      });
    }
  }

  String checkOptionsAndAnswer() {
    String rv = "";
    if(this._options.toSet().length != 5) {
      rv = textRes.ERROR_DUPLICATE_OPTION;
    } else {
      bool emptyString = false;
      this._options.forEach((element) {
        if(element.length == 0) {
          emptyString = true;
        }
      });
      if(emptyString) {
        rv = textRes.ERROR_EMPTY_OPTION;
      } else {
        if(this._answers.toSet().length == 1 && this._answers[0] == false) {
          rv= textRes.ERROR_NO_ANSWER_SELECTED;
        }
      }
    }

    return rv;
  }
  
  String validation(String label, String value) {
    String rv;
    String temp;
    if(label == textRes.LABEL_QUESTION) {
      if(value.isEmpty || value.length == 0) {
        _isSubmitDisable = true;
        _sendButtonText = Text(textRes.LABEL_MISSING_NEW_QUESTION);
        rv = textRes.LABEL_MISSING_NEW_QUESTION;
      } else {
        _formKey.currentState.save();
        temp = checkOptionsAndAnswer();
        if(temp.length == 0) {
          _isSubmitDisable = false;
        } else {
          _isSubmitDisable = true;
          _sendButtonText = Text(temp);
        }
      }
    } 
    if(label == textRes.LABEL_OPTION) {
      if(value.isEmpty || value.length == 0) {
        _isSubmitDisable = true;
        _sendButtonText = Text(textRes.ERROR_EMPTY_OPTION);
        rv = textRes.ERROR_EMPTY_OPTION;
      } else {
        _formKey.currentState.save();
        if(this._parentTitle.length == 0) {
           _isSubmitDisable = true;
          _sendButtonText = Text(textRes.LABEL_MISSING_NEW_QUESTION);
        } else {
          rv = checkOptionsAndAnswer();
          if(rv.length == 0) {
            _isSubmitDisable = false;
          } else {
            _isSubmitDisable = true;
            _sendButtonText = Text(rv);
          }
        }
      }            
    }
    if(label == textRes.LABEL_ANSWER) {
      if(_isSubmitDisable) {
        if(this._parentTitle.length > 0) {
          rv = checkOptionsAndAnswer();
          if(rv.length == 0) {
            print(3);
            _isSubmitDisable = false;
          } 
        } else {
          _sendButtonText = Text(textRes.LABEL_MISSING_NEW_QUESTION);
        }
      } else {
        rv = checkOptionsAndAnswer();
        if(rv.length != 0) {
          _isSubmitDisable = true;
          _sendButtonText = Text(rv);
        } 
      }
    }
    if(!_isSubmitDisable) {
      if(this._reference.length == 0) {
        _sendButtonText = Text(textRes.LABEL_SUGGEST_ADD_REFERECE);
      } else {
        if(this._desc.length == 0) {
          _sendButtonText = Text(textRes.LABEL_SUGGEST_ADD_DESC);
        } else {
          _sendButtonText = Text(textRes.LABEL_SUBMIT_QUESTION);
        }
      }
    }
    return rv;
  }
  void sendPendingQuestion() {
    //if (_formKey.currentState.validate()) {
//    If all data are correct then save data to out variables
      _formKey.currentState.save();
      List<String> tags = [this._firstTag];
      tags.addAll(_tags);
      tags = tags.toSet().toList();
      List<String> _answerString = [];
      for(int i = 0; i < this._answers.length; i++) {
        if(this._answers[i]) {
          _answerString.add(this._options[i]);
        }
      }
      Question sendQuestion = new Question(
          "",
          this._parentTitle,
          this._options,
          _answerString,
          user.id,
          tags,
          this._desc,
          null,
          this._reference,
          this._color);
      questionService.sendPendingQuestion(sendQuestion, imageFile);
      onBackPress();
    //}
  }

  void rejectQuestion() {
    widget.question.lastUpdateUserid = user.id;
    questionService.rejectPendingQuestion(widget.question);
    onBackPress();
  }

  void approveQuestion() {
    widget.question.lastUpdateUserid = user.id;
    questionService.approvePendingQuestion(widget.question);
    onBackPress();
  }  

  Widget _buildSubmit(BuildContext context) {
    Widget rv;
    if(_addMode) {
      rv = RaisedButton(
            focusNode: _focusNodes[14],
            child: _sendButtonText,
            onPressed: _isSubmitDisable ? null : sendPendingQuestion,
          );
    } else {
      if(user.role == 'admin') {
        rv = Row(children: <Widget>[
          Expanded(flex: 1, child: RaisedButton(
              child: Text(textRes.LABEL_REJECT),
              onPressed: rejectQuestion,
            )),
          Expanded(flex: 1, child: RaisedButton(
              child: Text(textRes.LABEL_APPROVE),
              onPressed: approveQuestion,
            ))
        ]);
      } else {
        rv = Container();
      }
    }
    return rv;
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
          const SizedBox(height: 12.0),
          ColorPicker(
            selectedIndex: _color,
            onTap: (index) {
              setState(() {
                _color = index;
              });
            },
          ),
          titleUI(context, 0),
          const SizedBox(height: 5.0),
          //topicImageUI(context),
          answerHeader(context, 1),
          optionWidget(context, 0, 2), 
          optionWidget(context, 1, 4),
          optionWidget(context, 2, 6),
          optionWidget(context, 3, 8),
          optionWidget(context, 4, 10),  
          const SizedBox(height: 5.0),                                      
          (!kIsWeb) ? topicImageUI(context): Container(), 
          const SizedBox(height: 5.0),
          referenceWidget(context,12),
          const SizedBox(height: 5.0),
          tagUI(context),
          descUI(context,13),
          _buildSubmit(context)
        ],
      )
    );
  }
}
