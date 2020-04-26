import 'package:firebase/firebase.dart' as WebFirebase;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'screens/homeScreen.dart';
//import 'screens/signin.dart';
import 'services/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './screens/layoutTemplate.dart';
import './services/questionService.dart';
import './screens/submitMainScreen.dart';
import './screens/quizMainScreen.dart';
import './screens/userMainScreen.dart';
import './screens/resultMainScreen.dart';

import './locator.dart';

//==================This file is the Splash Screen for the app==================
BuildContext _context;
SharedPreferences sharedPreferences;
AuthService authService;
Map<String, dynamic> categories;

Widget quizMain = Container();
Widget resultMain = Container();

final ThemeData kIOSTheme = new ThemeData(
  primarySwatch: Colors.blue,
  primaryColor: Colors.grey,
  primaryColorBrightness: Brightness.light,
);

final ThemeData kDefaultTheme = new ThemeData(
        primarySwatch:  Colors.blue,
        accentColor: Colors.yellow,
        
        primaryIconTheme: IconThemeData(color: Colors.black),
        primaryTextTheme: TextTheme(
          title: TextStyle(
          color: Colors.black
        )),
        //backgroundColor: Colors.black,
        textTheme: TextTheme(
          headline: TextStyle(
              fontFamily: 'Sans',
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 20),
          body1: TextStyle(
              fontFamily: 'Sans',
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 16),
          body2: TextStyle(
              fontFamily: 'Sans',
              fontWeight: FontWeight.normal,
              color: Colors.black,
              fontSize: 12),
          subtitle: TextStyle(
              fontFamily: 'Sans',
              fontWeight: FontWeight.normal,
              color: Colors.black,
              fontSize: 10),
        ),
      );

void main() {
  setupLocator();
//  //For Web
  if (kIsWeb) {
    WebFirebase.initializeApp(
      apiKey: "AIzaSyAcCCpASdf_PJ6TBk5KpvFmWm0DdTQBvlo",
      authDomain: "ourlandquiz.firebaseapp.com",
      databaseURL: "https://ourlandquiz.firebaseio.com",
      projectId: "ourlandquiz",
      storageBucket: "ourlandquiz.appspot.com",
      messagingSenderId: "347244200453",
      appId: "1:347244200453:web:1baf6aedc531c6b6aad26c",
      measurementId: "G-KE4ZB4TE5S");
  }
  setupLocator();

  runApp(new MaterialApp(
    initialRoute: '/',
    theme: ThemeData(primarySwatch: Colors.orange), 
    home: new SplashScreen()));
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => new _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    //Call the Class constructor and initialize the object
    SharedPreferences.getInstance().then((value) {
      sharedPreferences = value;
      authService = new AuthService();
    });
    loadUserData();
    super.initState();
  }

  Future<void> loadUserData() async {
    //Get the data from firestore
    questionService.getCategories().then((_cat) {
    //Not setState, to reflect the changes of Map to the widget tree
      setState(() {
        categories = _cat;
        quizMain = QuizMainScreen();
        resultMain = ResultMainScreen(categories.keys.toList());
        print(categories);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return LayoutTemplate();
    /*
    return new Scaffold(
        body: Container(
      color: Colors.yellow,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text("榮光",
                  style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.25)),
            Text("教育",
                  style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.25)),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("委員會",
                  style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.1)),
            )
          ],
        ),
      ),
    ));
    */
  }
}

void mainNavigationPage() {
  //if (blIsSignedIn) {
    Navigator.pushReplacement(
      _context,
      //MaterialPageRoute(builder: (context) => LayoutTemplate(),),
      MaterialPageRoute(builder: (context) => HomeScreen(),),
    );
  /*
  } else {
    Navigator.pushReplacement(
      _context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
    );
  }
  */
}