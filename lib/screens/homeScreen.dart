import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../services/questionService.dart';
import 'submitMainScreen.dart';
import 'quizMainScreen.dart';
import 'userMainScreen.dart';
import 'resultMainScreen.dart';
import '../models/textRes.dart';
import '../widgets/fabBottomAppBar.dart';

//==================This is the Homepage for the app==================

BuildContext _context;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin{
  TabController _tabController;
  String _fabText = "";
  bool _isFabShow = false;
  Widget main = Container();
  Widget exam = Container();
  @override
  void initState() {
    loadUserData();
    _tabController = new TabController(vsync: this, initialIndex: 0, length: 4);
    super.initState();
  }


  //Loads user data
  Future<void> loadUserData() async {
    //Get the data from firestore
    questionService.getCategories().then((_cat) {
    //Not setState, to reflect the changes of Map to the widget tree
      setState(() {
        categories = _cat;
        main = QuizMainScreen();
        exam = ResultMainScreen(categories.keys.toList());
        print(categories);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return MaterialApp(
        color: Colors.white,
        theme: defaultTargetPlatform == TargetPlatform.iOS
          ? kIOSTheme
          : kDefaultTheme,
        home: Scaffold(
          appBar: AppBar(
            title: Text(textRes.LABBEL_TITLE),
          ),
          body: new TabBarView(
            physics: NeverScrollableScrollPhysics(),
            controller: _tabController,
            children: <Widget>[
              main,
              SubmitMainScreen(),
              exam,
              UserMainScreen(),            //new CircularProgressIndicator(),
            ],
          ), 
          
          bottomNavigationBar: FABBottomAppBar(
          centerItemText: _fabText,
          backgroundColor: Theme.of(context).primaryColor,
          selectedColor: Theme.of(context).accentColor,
          notchedShape: _isFabShow ? CircularNotchedRectangle() : null,
          onTabSelected: (_selectedTab) => _tabController.index = _selectedTab,
          items: [
            FABBottomAppBarItem(iconData: Icons.layers, text: '考試'),
            FABBottomAppBarItem(iconData: Icons.dashboard, text: '課程'),
            FABBottomAppBarItem(iconData: Icons.access_alarm, text: '排行榜'),
            FABBottomAppBarItem(iconData: Icons.bookmark, text: '個人'),
          ],
        ),
        ));
  }
}