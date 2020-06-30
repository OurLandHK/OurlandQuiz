import 'package:cloud_firestore/cloud_firestore.dart' as MobFirestore;
import 'package:firebase/firebase.dart' as WebFirebase;
import 'package:firebase/firestore.dart' as WebFirestore;
import 'package:firebase_storage/firebase_storage.dart' as MobFirebaseStorage;
import 'package:cloud_firestore_web/cloud_firestore_web.dart' as WebFireStore2;


//CloudFireStore
MobFirestore.Firestore mobFirestore = MobFirestore.Firestore.instance;
WebFirestore.Firestore webFirestore = WebFirebase.firestore();

//Firebase Stroe
WebFirebase.StorageReference webStorageRef = WebFirebase.storage().ref();
MobFirebaseStorage.StorageReference mobStorageRef = MobFirebaseStorage.FirebaseStorage.instance.ref(); 

