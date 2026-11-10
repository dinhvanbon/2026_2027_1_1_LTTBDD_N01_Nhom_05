import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveFcmToken() async {
  debugPrint('🔥 saveFcmToken called from AuthService');

  final user = _auth.currentUser;

  if (user == null) {
    debugPrint('❌ User null');
    return;
  }

  final messaging = FirebaseMessaging.instance;

  await messaging.requestPermission();

  final token = await messaging.getToken();

  debugPrint('🔥 TOKEN = $token');

  if (token == null) return;

  await FirebaseFirestore.instance
    .collection('users')
    .doc(user.uid)
    .set({
  'fcmToken': token,
  'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
}, SetOptions(merge: true));
}

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  Future<UserCredential> loginWithEmail({
  required String email,
  required String password,
}) async {
  final credential =
      await _auth.signInWithEmailAndPassword(
    email: email.trim(),
    password: password.trim(),
  );

  await saveFcmToken();

  return credential;
}

  Future<void> logout() async {
    await _auth.signOut();
  }
}
