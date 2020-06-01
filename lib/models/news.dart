import 'package:cloud_firestore/cloud_firestore.dart';

class News {
  String _title;
  DateTime _createdAt;
  String _detail;
  News(this._title, this._detail) {
    this._createdAt = DateTime.now();
  }


  String get title => _title;
  String get detail => _detail;
  DateTime get createdAt => _createdAt;


  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['title'] = _title;
    map['createdAt'] = _createdAt;
    map['detail'] = _detail;
    return map;
  }

  News.fromMap(Map<String, dynamic> map) {
    this._title = map['title'];
    this._detail = map['detail'];
    try {
      this._createdAt = map['createdAt'].toDate();
    } catch(Exception) {
      this._createdAt = map['createdAt'];
    }
  }
  
}