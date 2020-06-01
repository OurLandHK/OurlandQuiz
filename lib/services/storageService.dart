import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:image/image.dart' as Img;


import 'service.dart';
import 'package:firebase_storage/firebase_storage.dart' as MobFirebaseStorage;
import 'package:cloud_firestore/cloud_firestore.dart' as MobFirestore;
import 'package:firebase/firebase.dart' as WebFirebase;
import 'package:flutter/foundation.dart';


StorageService storageService = new StorageService();

class StorageService {
  StorageService();

  Future<Map> uploadImage(List<int> blob) async {
    
    String fileName = 'photo/' + DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';
    
    Img.Image originImage = Img.decodeImage(blob);
    Img.Image image = originImage;
    print("upload Image ${originImage.width} x ${originImage.height}");
    bool newImage = false;
    if(originImage.width > originImage.height && originImage.width > 1280) {
      image = Img.copyResize(originImage, width: 1280);
      print("after resize");
      newImage = true;
    } else {
      if(originImage.height > originImage.width && originImage.height > 1280) {
        int width = (originImage.width * 1280 / originImage.height).round();
        print("new width $width");
        image = Img.copyResize(originImage, width: width, height: 1280); 
        print("after resize"); 
        newImage = true;     
      }
    }

    if(newImage) {
  //    uploadImage = new File('temp.png').writeAsBytesSync(Img.encodePng(image));
//      blob = new Img.PngEncoder({level: 3}).encodeImage(image);
      blob = new Img.JpegEncoder(quality: 75).encodeImage(image);
      print("after encode");
    }
    Map rv = Map();
    if (!kIsWeb) {
      //For mobile
      MobFirebaseStorage.StorageReference mobUploadFileRef = mobStorageRef.child(fileName);
      MobFirebaseStorage.StorageUploadTask mobUploadTask = mobUploadFileRef.putData(blob);
      MobFirebaseStorage.StorageTaskSnapshot mobStorageTaskSnapshot = await mobUploadTask.onComplete;
      String downloadUrl = await mobStorageTaskSnapshot.ref.getDownloadURL();
      String serverPath = await mobStorageTaskSnapshot.ref.getPath();
      String bucketPath = await mobStorageTaskSnapshot.ref.getBucket();   
      rv['downloadUrl'] = downloadUrl;
      rv['serverUrl'] = "gs://" + bucketPath + "/" + serverPath;
    } else {
      WebFirebase.StorageReference storageRef = WebFirebase.storage().ref('images/$fileName');
      WebFirebase.UploadTaskSnapshot webStorageTaskSnapshot= await storageRef.put(blob).future;
      Uri downloadUri = await webStorageTaskSnapshot.ref.getDownloadURL();
      String downloadUrl = downloadUri.toString();
      String bucketFullPath = webStorageTaskSnapshot.ref.toString(); 
      print(downloadUrl);
      print(bucketFullPath);
      rv['downloadUrl'] = downloadUrl;
      rv['serverUrl'] = bucketFullPath;     
    }
    return rv;
  } 
  
}