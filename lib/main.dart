import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';



Future<void> saveFcmToken() async {
  debugPrint('🔥 saveFcmToken called');
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) return;

  final messaging = FirebaseMessaging.instance;

  await messaging.requestPermission();

  final token = await messaging.getToken();

debugPrint(
  '🔥 FCM TOKEN: $token',
);

if (token == null) {
  debugPrint('❌ FCM TOKEN NULL');
  return;
}

  await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
    'fcmToken': token,
    'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialize error: $e');
  }

  // Khởi động giao diện ngay để tránh màn hình trắng trên web
  runApp(const LifeRPGApp());

  // Khởi tạo notification an toàn trong background, không chặn UI
  try {
    NotificationService().init().catchError((e) {
      debugPrint('Notification init warning (safe to ignore on web): $e');
    });
  } catch (e) {
    debugPrint('Notification error: $e');
  }
}