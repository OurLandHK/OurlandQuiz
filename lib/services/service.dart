import 'package:cloud_firestore/cloud_firestore.dart' as MobFirestore;
import 'package:firebase/firebase.dart' as WebFirebase;
import 'package:firebase/firestore.dart' as WebFirestore;
import 'package:firebase_auth/firebase_auth.dart' as MobFirebaseAuth;
import 'package:firebase_storage/firebase_storage.dart' as MobFirebaseStorage;
import 'package:google_sign_in/google_sign_in.dart';

MobFirebaseAuth.FirebaseUser mobFirebaseUser;
WebFirebase.User webFirebaseUser;

//This is the main Firebase auth object
MobFirebaseAuth.FirebaseAuth mobAuth = MobFirebaseAuth.FirebaseAuth.instance;
WebFirebase.Auth webAuth = WebFirebase.auth();

// For google sign in
final GoogleSignIn mobGoogleSignIn = GoogleSignIn();
WebFirebase.GoogleAuthProvider webGoogleSignIn;

//CloudFireStore
MobFirestore.Firestore mobFirestore = MobFirestore.Firestore.instance;
WebFirestore.Firestore webFirestore = WebFirebase.firestore();

//Firebase Stroe
WebFirebase.StorageReference webStorageRef = WebFirebase.storage().ref();
MobFirebaseStorage.StorageReference mobStorageRef = MobFirebaseStorage.FirebaseStorage.instance.ref(); 

