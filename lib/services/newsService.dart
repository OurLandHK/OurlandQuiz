import 'dart:async';


import 'service.dart';
import 'package:firebase_storage/firebase_storage.dart' as MobFirebaseStorage;
import 'package:cloud_firestore/cloud_firestore.dart' as MobFirestore;
import 'package:firebase/firebase.dart' as WebFirebase;
import 'dart:html'as html;
import 'package:flutter/foundation.dart';
import '../main.dart';
import '../models/news.dart';
import '../models/textRes.dart';

NewsService newsService = new NewsService();

class NewsService {
  NewsService();

  Future<bool> addNews(News news) async {
    var indexData = news.toMap();
    try {
      await mobFirestore
          .collection('news').add(indexData);
      return true;
    } catch (exception) {
      print(exception);
      return false;
    }    
  }

  Future<News> getNews(String id) {
    try {
      return mobFirestore
          .collection('news').document(id)
          .get().then((data) {
            if(data.exists) {
              News rv = News.fromMap(data.data);
              return rv;
            } else {
              return null;
            }
          });
    } catch (exception) {
      print(exception);
    }    
  }

Future<List<News>> getLatestNews(int limit) async {
    List<News> newsList = [];
    try {
      var mobQuery = mobFirestore.collection('news').orderBy("createdAt", descending: true);
      if(limit != 0) {
        mobQuery = mobQuery.limit(limit);
      }
      return mobQuery.getDocuments().then((MobFirestore.QuerySnapshot snapshot) {
        snapshot.documents.forEach((doc) {
          if(doc.exists) {
            Map data = doc.data;            
            News news = News.fromMap(data); 
            newsList.add(news);
          }
        });
        return newsList;
      });
    } catch (exception) {
      print(exception);
      return newsList;
    }
  }
}