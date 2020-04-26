import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../main.dart';
import '../models/userModel.dart';
import 'service.dart';
import 'package:firebase/firebase.dart' as WebFirebase;

User user;

//
//
//
//
bool blIsSignedIn = false;

List<String> _POSTIVE_ADJ = [
      "善良的",
      "清潔的",
      "悲傷的",
      "重要的",
      "寬闊的",
      "快速的",
      "嶄新的",
      "愉快的",
      "寂靜的",
      "狹窄的",
      "簡單的",
      "輕巧的",
      "明亮的",
      "高大的",
      "苗條的",
      "富裕的",
      "肥沃的",
      "新鮮的",
      "深厚的",
      "堅硬的",
      "勇敢的",
      "慷慨的",
      "善意的",
      "堅強的",
      "活潑的",
      "開朗的",
      "坦率的",
      "爽快的",
      "豁達的",
      "豪邁的",
      "不拘小節的",
      "樂觀的",
      "意志堅定的",
      "勇敢的",
      "果斷的",
      "堅毅不屈的",
      "熱情的",
      "文靜的",
      "文質彬彬的",
      "溫文有禮的",
      "謹慎的",
      "心思縝密的",
      "成熟穩重的",
      "平易近人的",
      "溫柔體貼的",
      "和藹可親的",
      "親切的",
      "細心的",
      "談吐得體的",
      "誠實的",
      "宅心仁厚的",
      "善良的",
      "待人寬厚的",
      "實事求事的",
      "樂於助人的",
      "有恩必報的",
      "有信用的",
      "公平無私的",
      "不平則鳴的",
      "勤奮的",
      "聰明的",
      "精明的",
      "學識淵博的",
      "好學不倦的",
      "謙虛的",
      "謙遜的",
      "有智謀的",
      "有遠見的",
      "天資聰敏的",
      "靈活變通的",
      "機靈的",
      "才思敏捷的",
      "才華洋溢的",
      "智勇雙全的",
      "有幽默感的",
      "有領導才能的"
    ];
  List<String> _POSTIVE_NAME = [
      "謹申",
      "耀忠",
      "國麟",
      "孟靜",
      "志偉",
      "乃光",
      "志全",
      "繼昌",
      "家麒",
      "榮鏗",
      "超雄",
      "碧雲",
      "建源",
      "岳橋",
      "兆堅",
      "凱廸",
      "君堯",
      "卓廷",
      "家臻",
      "沛然",
      "淑莊",
      "智峯",
      "松泰",
      "俊宇",
      "文豪",
      "國威",
      "諾軒",
      "頌恆",
      "蕙禎",
      "天琦",
      "浩天",
      "台仰",
      "庭",
      "思堯",
      "之鋒",
      "冠聰",
      "國雄",
      "耀廷",
      "文遠",
      "小麗",
      "蕙禎"
    ];

class AuthService {
  // constructor
  AuthService() {
    String _userID = sharedPreferences.get("userID"); 
    checkIsSignedIn(_userID).then((_blIsSignedIn) {
      //redirect to appropriate screen
      mainNavigationPage();
    });
  }

  //Checks if the user has signed in
  Future<bool> checkIsSignedIn(String _userID) async {
    DateTime now = DateTime.now();
    if(_userID == null) {
      Random rng = new Random();
      int passcode = rng.nextInt(999999);
      String name = _POSTIVE_ADJ[rng.nextInt(_POSTIVE_ADJ.length)] + _POSTIVE_NAME[rng.nextInt(_POSTIVE_NAME.length)];
      user = new User(now.millisecondsSinceEpoch.toString(), passcode.toString(), name, now, now);
      return updateUser(user).then((good) {
        if(good) {
          return sharedPreferences.setString('userID', user.id).then((value) {
            blIsSignedIn = value;
            return value;});
        } else {
          return false;
        };
      });
    } else {
      return getUser(_userID).then((value) {
        if(value != null) {
          blIsSignedIn = true;
          user = value;
        }
        return blIsSignedIn;
      });
    }
  }

  //Log in using google
  Future<dynamic> googleSignIn() async {
    if (!kIsWeb) {
      //For mobile

      // Step 1
      GoogleSignInAccount googleUser = await mobGoogleSignIn.signIn();

      // Step 2
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      AuthResult _res = await mobAuth.signInWithCredential(credential);
      mobFirebaseUser = _res.user;

      return mobFirebaseUser;
    } else {
      //For web
      var provider = new WebFirebase.GoogleAuthProvider();
      try {
        WebFirebase.UserCredential _userCredential = await webAuth.signInWithPopup(provider);
        webFirebaseUser = _userCredential.user;
      } catch (e) {
        webFirebaseUser = null;
        print("Error in sign in with google: $e");
      }

      return webFirebaseUser;
    }
  }

  //Gets the userData
  Future<User> getUser(String _userID) async {
    User _user;
    if (!kIsWeb) {
      //For mobile
      return mobFirestore.collection('User')
          .document(_userID).get().then((snapshot) async {
        if (snapshot.data != null) {
          var map = snapshot.data;
          map['updatedAt'] = DateTime.now();
          _user = User.fromMap(map);
        } 
        return _user;
      });
    } else {
      //For Web
      return webFirestore.collection('User').doc(_userID).get().then((snapshot) async {
        print(_userID);
        if (snapshot.data() != null) {
          var map = snapshot.data();
          map['updatedAt'] = DateTime.now();
          _user = User.fromMap(map);
        } 
        return _user;
      });
    }
  }

  //Update the data into the database
  Future<bool> updateUser(User _user) async {
    bool blReturn = false;
    if (!kIsWeb) {
      //For mobile
      var map = user.toMap();
      map['updatedAt'] = DateTime.now();
      await mobFirestore
          .collection('User')
          .document(user.id)
          .setData(map, merge: false)
          .then((onValue) async {
        blReturn = true;
      });
    } else {
      //For Web
//      WebFirestore.SetOptions options;
      var map = user.toMap();
      map['updatedAt'] = DateTime.now();
      await webFirestore.collection('User').doc(user.id).set(map).then((onValue) async {
        blReturn = true;
      });
    }
    return blReturn;
  }

  void signOut() {
    if (!kIsWeb) {
      //For mobile
      mobAuth.signOut();
    } else {
      //For web
      webAuth.signOut();
    }
  }
}

