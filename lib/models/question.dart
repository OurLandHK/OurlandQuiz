import 'dart:math';
import 'dart:convert';
import 'textRes.dart';

class Question {
  String _id;
  DateTime _lastUpdate;
  DateTime _created;
  String _createdUserid;
  String lastUpdateUserid;
  String status;
  int _color;
  String _imageUrl;
  String _title;
  String _explanation;
  List<dynamic> _tags;
  List<dynamic> _options;
  List<dynamic> _answers;
  String _referenceUrl;

  Question(this._id, this._title, this._options, this._answers, this._createdUserid, this._tags, this._explanation, this._imageUrl, this._referenceUrl, this._color) {
        this._created = DateTime.now();
        this._lastUpdate = this._created;
        this.lastUpdateUserid = this._createdUserid;
        this.status = textRes.QUESTION_STATUS_OPTIONS[0];
  }

  String get id => _id;
  String get imageUrl => _imageUrl;
  String get title => _title;
  String get explanation => _explanation;
//  List<String> get tags => _tags;
  List<String> get tags => _tags.cast<String>();
  List<String> get answers => _answers.cast<String>();
  List<String> get options => _options.cast<String>();

  DateTime get lastUpdate => _lastUpdate;
  DateTime get created => _created;
  String get createdUserid => _createdUserid;
  int get color => _color;
  String get referenceUrl => _referenceUrl;
  
  int totalText() {
    int rv;
    rv = title.length;
    options.forEach((element) { rv += element.length;});
    return rv;
  }
  
  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['id'] = _id;
    map['title'] = this._title;
    map['lastUpdate'] = this._lastUpdate;
    map['created'] = this._created;
    map['createdUserid'] = this._createdUserid;
    map['lastUpdateUserid'] = this.lastUpdateUserid;
    map['color'] = this._color;
    map['answers'] = this._answers;
    map['options'] = this._options;
    map['status'] = this.status;
    if (_imageUrl != null) {
      map['imageUrl'] = _imageUrl;
    }
    if (this._explanation!= null) {
      map['explanation'] = this._explanation;
    }
    if (this._tags != null) {
      map['tags'] = this._tags;
    }
    if( this._referenceUrl != null) {
      map['referenceUrl'] = this._referenceUrl;
    }
    return map;
  }

  Question.fromMap(Map<String, dynamic> map) {
    this._id = map['id'];
    this._imageUrl = map['imageUrl'];
    this._title = map['title'];
    this._tags = map['tags'];
    this._answers = map['answers'];
    this._options = map['options'];
    this._createdUserid = map['createdUserid'];
    this.lastUpdateUserid =  map['lastUpdateUserid'];
    this._explanation = map['explanation'];
    this._referenceUrl = map['referenceUrl'];
    this._color = map['color'];
    this.status = map['status'];
    try {
      
      this._created = map['created'].toDate();
    } catch(Exception) {
      this._created = map['created'];
    }
    try {
      this._lastUpdate = map['lastUpdate'].toDate();
    } catch(Exception) {
      this._lastUpdate = map['lastUpdate'];
    }
  }
}
