import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up
  Future<UserModel?> signUp(
    String email,
    String password,
    String name,
    String role,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      UserModel user = UserModel(
        uid: result.user!.uid,
        email: email,
        name: name,
        role: role,
      );

      await _firestore
          .collection('users')
          .doc(result.user!.uid)
          .set(user.toJson());
      return user;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  // Sign in
  Future<UserModel?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(result.user!.uid)
          .get();
      return UserModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  Stream<UserModel?> get currentUser {
    return _auth.authStateChanges().asyncMap((User? user) async {
      if (user != null) {
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }
}
