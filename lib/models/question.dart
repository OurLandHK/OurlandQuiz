import 'dart:math';
import 'dart:convert';
import 'textRes.dart';

class Question {
  String id;
  DateTime lastUpdate;
  DateTime created;
  DateTime eventDate;
  String createdUserid;
  String lastUpdateUserid;
  String status;
  int color;
  String imageUrl;
  String bitbucketUrl;
  String descImageUrl;
  String descBitbucketUrl;
  String title;
  String explanation;
  List<String> tags;
  List<String> options;
  List<String> answers;
  String referenceUrl;

  Question(
      this.id,
      this.title,
      this.options,
      this.answers,
      this.createdUserid,
      this.tags,
      this.explanation,
      this.imageUrl,
      this.bitbucketUrl,
      this.descImageUrl,
      this.descBitbucketUrl,
      this.referenceUrl,
      this.eventDate, // Date related to the question
      this.color) {
    this.created = DateTime.now();
    this.lastUpdate = this.created;
    this.lastUpdateUserid = this.createdUserid;
    this.status = textRes.QUESTION_STATUS_OPTIONS[0];
  }

  int totalText() {
    int rv;
    rv = title.length;
    options.forEach((element) {
      rv += element.length;
    });
    return rv;
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['id'] = id;
    map['title'] = this.title;
    map['lastUpdate'] = this.lastUpdate;
    map['created'] = this.created;
    map['createdUserid'] = this.createdUserid;
    map['lastUpdateUserid'] = this.lastUpdateUserid;
    map['color'] = this.color;
    map['answers'] = this.answers;
    map['options'] = this.options;
    map['status'] = this.status;
    if (imageUrl != null) {
      map['imageUrl'] = imageUrl;
      map['bitbucketUrl'] = bitbucketUrl;
    }
    if (descImageUrl != null) {
      map['descImageUrl'] = descImageUrl;
      map['descBitbucketUrl'] = descBitbucketUrl;
    }
    if (this.explanation != null) {
      map['explanation'] = this.explanation;
    }
    if (this.tags != null) {
      map['tags'] = this.tags;
    }
    if (this.referenceUrl != null) {
      map['referenceUrl'] = this.referenceUrl;
    }
    if (this.eventDate != null) {
      map['eventDate'] = this.eventDate;
      // for search question for this week.
      map['month'] = this.eventDate.month;
      map['day'] = this.eventDate.day;
    } else {
      // for search question for this week.
      map['month'] = -1;
      map['day'] = -1;      
    }
    // enable search for month and date
    return map;
  }

  Question.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.imageUrl = map['imageUrl'];
    this.bitbucketUrl = map['bitbucketUrl'];
    this.descImageUrl = map['descImageUrl'];
    this.descBitbucketUrl = map['descBitbucketUrl'];
    this.title = map['title'];
    if (map['tags'] != null) {
      this.tags = map['tags'].cast<String>();
    }
    if (map['answers'] != null) {
      this.answers = map['answers'].cast<String>();
    }
    if (map['options'] != null) {
      this.options = map['options'].cast<String>();
    }
    this.createdUserid = map['createdUserid'];
    this.lastUpdateUserid = map['lastUpdateUserid'];
    this.explanation = map['explanation'];
    this.referenceUrl = map['referenceUrl'];
    this.color = map['color'];
    this.status = map['status'];
    try {
      this.created = map['created'].toDate();
    } catch (Exception) {
      this.created = map['created'];
    }
    try {
      this.eventDate = map['eventDate'].toDate();
    } catch (Exception) {
      this.eventDate = map['eventDate'];
    }
    try {
      this.lastUpdate = map['lastUpdate'].toDate();
    } catch (Exception) {
      this.lastUpdate = map['lastUpdate'];
    }
  }
}
