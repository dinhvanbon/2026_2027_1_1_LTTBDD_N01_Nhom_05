import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> init() async {
    await _requestPermission();
    await saveCurrentUserToken();
    _listenTokenRefresh();
    _listenForegroundMessages();
  }

  Future<void> _requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> saveCurrentUserToken() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final token = await _messaging.getToken();
    if (token == null) return;

    await _firestore.collection('users').doc(user.uid).update({
      'fcmToken': token,
      'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  void _listenTokenRefresh() {
    _messaging.onTokenRefresh.listen((token) async {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('users').doc(user.uid).update({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  void _listenForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Hiện tại chỉ log khi app đang mở.
      // Bước sau có thể thêm flutter_local_notifications nếu muốn popup trong foreground.
      final title = message.notification?.title;
      final body = message.notification?.body;

      debugPrint('FCM foreground message: $title - $body');
    });
  }
  Future<void> createNotificationRequest({
  required String receiverId,
  required String title,
  required String body,
  required String type,
  String? taskId,
}) async {
  final receiverDoc =
      await _firestore.collection('users').doc(receiverId).get();

  final receiverToken = receiverDoc.data()?['fcmToken'];

  if (receiverToken == null || receiverToken.toString().isEmpty) {
    debugPrint('❌ Receiver has no FCM token');
    return;
  }

  await _firestore.collection('notificationRequests').add({
    'receiverId': receiverId,
    'receiverToken': receiverToken,
    'title': title,
    'body': body,
    'type': type,
    'taskId': taskId,
    'status': 'pending',
    'createdAt': FieldValue.serverTimestamp(),
  });
}
}
