import 'package:OurlandQuiz/models/textRes.dart';
import 'package:flutter/material.dart';
import '../helper/uiHelper.dart';
import '../models/question.dart';
import '../widgets/questionWidget.dart';
import '../services/questionService.dart';
import 'addQuestionScreen.dart';
import 'listQuestionsScreen.dart';
import '../routing/routeNames.dart';
import '../locator.dart';
import '../services/navigationService.dart';
import '../main.dart';


class SubmitMainScreen extends StatefulWidget {
  @override
  _SubmitMainState createState() => new _SubmitMainState();
}

class _SubmitMainState extends State<SubmitMainScreen> {
  @override

  bool isLoading = true;
  String _messageStatus = "";
  String _pendingMessageStatus = textRes.QUESTION_STATUS_OPTIONS[0];
  List<Question> _questions;
  List<String> quizCategories;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<DropdownMenuItem<String>> _dropDownMenuItems; 

  void initState() {
    quizCategories = categories.keys.toList();
    _dropDownMenuItems = getDropDownMenuItems(textRes.QUESTION_STATUS_OPTIONS.sublist(0, 2) ,'');
    //initPlatformState();
    super.initState();
  }

  initPlatformState() async {
    /*
    _messageService.getLatestQuestion().then((topic) {
      //print("${topic.id}");
      setState(() {
        _recentTopic = topic;
      });
    });
    // get the list for question tag
    _messageService.getSearchFirstPage().then((searchFirstPage){
      setState(() {
        _tagList = searchFirstPage['Tags'].cast<String>();
      });
    });
    */
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading
        ? Container(
          child: Center(
            child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(themeColor)),
          ),
          color: Colors.white.withOpacity(0.8),
        ) :  new Container()
      );
    }    

  Widget buildItem(Question question, BuildContext context) {
    Widget rv; 
    rv = QuestionWidget(question: question, pending: true);
    return rv;
  }    


  void onChangedStatus(String status) {
    setState(() {
      _messageStatus = "";
      _pendingMessageStatus = status;
    });
  }


  List<Widget> buildGrid(List<Question> documents, BuildContext context) {
    List<Widget> _gridItems = [_buildDropDown()];
    for (Question question in documents) {
      _gridItems.add(buildItem(question, context));
    }
    return _gridItems;
  }  

  Widget _buildDropDown() {
    return Row(
            mainAxisAlignment: MainAxisAlignment.center, 
            crossAxisAlignment: CrossAxisAlignment.center, 
            children: [
              Text(textRes.LABEL_PENDING_MESSAGE, textAlign: TextAlign.center), 
              DropdownButton(
                value: _messageStatus,
                items: _dropDownMenuItems,
                onChanged: (value) => onChangedStatus(value),
                style: Theme.of(context).textTheme.subhead
              ),
              RaisedButton(
                child: Text(textRes.LABEL_NEW_QUESTION),
                onPressed: () {
                Navigator.of(context).push(
                  new MaterialPageRoute<void>(
                    builder: (BuildContext context) {
                      return new AddQuestionScreen(question: null);
                    })
                );
              }),]);
  }

  Widget buildListView(BuildContext context) {
    if(this._messageStatus.length == 0)  {
      isLoading = false;
      return new Center(child: new CircularProgressIndicator());
    } else {
      Widget body;
      List<Widget> children =[];
      if(_questions != null && _questions.length > 0) {
        children = buildGrid(_questions, context);
        isLoading = false;
        
      } else {
        isLoading = false;
        children = [
          _buildDropDown(),
          Container(child: Text(textRes.LABEL_NO_PENDING_MESSAGE,
          style: Theme.of(context).textTheme.headline))];
      }
      /*
      body =  ListView(
          padding: EdgeInsets.symmetric(vertical: 8.0), 
          children: children);
          */
      body =  SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children:children
      )
      );
      /*
      widgetList.add(body);
      return Column(children: widgetList);
      */
      return body;
    }
  }

  void updateQuestionList(List<Question> questions) {
    //print("finish");
    setState(() {
      this._questions = questions;
    });    
  }

  void _swapValuable(BuildContext context) {
    if(this._messageStatus.length == 0) {
      questionService.getPendingQuestionList(this._pendingMessageStatus, this.updateQuestionList);
      setState(() {
        this._messageStatus = _pendingMessageStatus;
      });
    }
  }

  void _onTap(String category) async {
    locator<NavigationService>().navigateTo('/${Routes[1].route}/${category}');
    /*
    Navigator.of(context).push(
      new MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return ListQuestionsScreen(category: category);
        },
      ),
    );
    */
  }

  Widget catButton(BuildContext context, String category) {
    String title = category;
    int totalQuestion = 0;
    if(category.length == 0) {
      title = textRes.LABEL_QUICK_GAME;
    } else {
      totalQuestion = categories[category]['count'];
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
                children: [
                  Row(children:[Text(title), Text(" : $totalQuestion")]),
                ]
              ),
            ),
          ),
        );
    return rv;
  }

  Widget catSet(BuildContext context) {
    List<Widget> buttonWidgets = [];
    quizCategories.forEach((category) {
      buttonWidgets.add(const SizedBox(height: 5.0));
      buttonWidgets.add(catButton(context, category));
    });
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
    WidgetsBinding.instance
      .addPostFrameCallback((_) => _swapValuable(context));
    return Container(
                color: Colors.white,
                child: SafeArea(
                  top: false,
                  bottom: false,
                  child: SingleChildScrollView(
                    child:Column(
                      children: [
                        catSet(context),
                        buildListView(context),
                        /*
                        Stack(
                          children: <Widget>[
                            buildListView(context),
                            buildLoading(),
                          ],
                        )
                        */
                      ]
                    ), 
                  )
                )
              );
    /*
    return Scaffold(
          appBar: PreferredSize(
                preferredSize: Size.fromHeight(MediaQuery.of(context).size.height/15), child:Container()
          ),

          //FAB
          floatingActionButton: FloatingActionButton.extended(
              label: Text("Add data"),
              onPressed: () {
                Navigator.of(context).push(
                  new MaterialPageRoute<void>(
                    builder: (BuildContext context) {
                      return new AddQuestionScreen(question: null);
                    })
                );
                setState(() {});
              }),
          //Body
          body: //Home
              Container(
                color: Colors.white,
                child: SafeArea(
                  top: false,
                  bottom: false,
                  child: SingleChildScrollView(
                    child:Column(
                      children: [
                        catSet(context),
                        buildListView(context),
                        /*
                        Stack(
                          children: <Widget>[
                            buildListView(context),
                            buildLoading(),
                          ],
                        )
                        */
                      ]
                    ), 
                  )
                )
              )
    );
    */
  }
}