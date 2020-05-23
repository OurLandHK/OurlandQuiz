import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String _id;
  String name;
  String _fcmToken;
  String _role;
  DateTime _createdAt;
  DateTime _updatedAt;
  String _passcode;
  List<String> _questionIDs;

  User(this._id, this._passcode, this.name, this._createdAt, this._updatedAt) {
        this._fcmToken = '';
        this._role = 'user';
        this._questionIDs = [];
  }

  String get id => _id;
  String get passcode => _passcode;
  DateTime get createdAt => _createdAt;
  DateTime get updatedAt => _updatedAt;
  String get fcmToken => _fcmToken;
  String get role => _role;
  List<String> get questionIDs => _questionIDs;

  bool updateQuestionIDs(String questionID) {
    bool rv = false;
    if(!this._questionIDs.contains(questionID)) {
      this._questionIDs.add(questionID);
      rv =true;
    }
    return rv;
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (_id != null) {
      map['uuid'] = _id;
    }

    if (name != null) {
      map['name'] = name;
    }

    if (_createdAt != null) {
      map['createdAt'] = _createdAt;
    }

    if (_updatedAt != null) {
      map['updatedAt'] = _updatedAt;
    }

    map['passcode'] = _passcode;

    if(_fcmToken != '') {
     map['fcmToken'] = _fcmToken; 
    }

    if(_role != '') {
      map['role'] = _role;
    }

    if(_questionIDs.length > 0) {
      map['questionIDs'] = _questionIDs;
    }

    return map;
  }


  User.fromMap(Map<String, dynamic> map) {
    this._id = map['uuid'];
    this.name = map['name'];
    if(map['questionIDs'] != null) {
      List<dynamic> tmp = map['questionIDs'];
      this._questionIDs = tmp.cast<String>();
    } else {
      this._questionIDs = [];
    }
    if(map['createdAt'] != null) {
      try{      
        this._createdAt = map['createdAt'];
      } catch (e) {
        Timestamp timeStamp = map['createdAt'];
        this._createdAt = timeStamp.toDate();
      }
    } else {
      this._createdAt = DateTime.now();
    }
    if(map['updatedAt'] != null) {
      try{      
        this._updatedAt = map['updatedAt'];
      } catch (e) {
        Timestamp timeStamp = map['updatedAt'];
        this._updatedAt = timeStamp.toDate();
      }
    } else {
      this._updatedAt = DateTime.now();
    }
    this._passcode = map['passcode'];

    try {
      if(map['fcmToken'] == null) {
        this._fcmToken = '';
      } else {
        this._fcmToken = map['fcmToken'];
      }
    } catch (exception) {
      this._fcmToken = '';
    }

    try {
      if(map['role'] == null) {
        this._role = 'user';
      } else {
        this._role = map['role'];
      }
    } catch (exception) {
      this._role = '';
    }
  }
}

