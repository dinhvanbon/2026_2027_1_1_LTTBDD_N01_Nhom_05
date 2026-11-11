import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/task_model.dart';
import 'notification_service.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createTask({
    required String title,
    required String description,
    required String difficulty,
    required int expReward,
    required int rewardAmount,
    required String childId,
    DateTime? deadlineAt,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User chưa đăng nhập');
    }

    await _firestore.collection('tasks').add({
      'title': title,
      'description': description,
      'difficulty': difficulty,
      'expReward': expReward,
      'rewardAmount': rewardAmount,
      'parentId': user.uid,
      'childId': childId,
      'status': 'pending',
      'proofImage': null,
      'childNote': null,
      'submittedAt': null,
      'verifiedAt': null,
      'deadlineAt': deadlineAt == null ? null : Timestamp.fromDate(deadlineAt),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<TaskModel>> getTasksStream() async* {
    final user = _auth.currentUser;

    if (user == null) {
      yield <TaskModel>[];
      return;
    }

    final userDoc = await _firestore.collection('users').doc(user.uid).get();

    final role = userDoc.data()?['role'];

    Query<Map<String, dynamic>> query;

    if (role == 'parent') {
      query = _firestore
          .collection('tasks')
          .where('parentId', isEqualTo: user.uid);
    } else if (role == 'child') {
      query = _firestore
          .collection('tasks')
          .where('childId', isEqualTo: user.uid);
    } else {
      yield <TaskModel>[];
      return;
    }

    await for (final snapshot in query.snapshots()) {
      final tasks = snapshot.docs.map((doc) {
        return TaskModel.fromMap(doc.data(), doc.id);
      }).toList();

      yield tasks;
    }
  }

  Future<int> approveTask(String taskId) async {
    final taskRef = _firestore.collection('tasks').doc(taskId);

    return _firestore
        .runTransaction((transaction) async {
          final taskDoc = await transaction.get(taskRef);

          if (!taskDoc.exists) {
            throw Exception('Không tìm thấy task');
          }

          final taskData = taskDoc.data()!;

          final childId = taskData['childId'];
          final int expReward = (taskData['expReward'] ?? 0).toInt();

          final int rewardAmount = (taskData['rewardAmount'] ?? 0).toInt();

          if (childId == null || childId.toString().isEmpty) {
            throw Exception('Task chưa có childId');
          }

          final childRef = _firestore.collection('children').doc(childId);

          final userRef = _firestore.collection('users').doc(childId);

          final childDoc = await transaction.get(childRef);

          int currentExp = 0;
          int currentLevel = 1;

          if (childDoc.exists) {
            final childData = childDoc.data();

            currentExp = (childData?['exp'] ?? 0).toInt();

            currentLevel = (childData?['level'] ?? 1).toInt();
          }

          int newExp = currentExp + expReward;
          int newLevel = currentLevel;

          while (newExp >= newLevel * 100) {
            newExp -= newLevel * 100;
            newLevel++;
          }

          transaction.update(taskRef, {
            'status': 'approved',
            'verifiedAt': FieldValue.serverTimestamp(),
          });

          transaction.set(childRef, {
            'exp': newExp,
            'level': newLevel,
            'coins': FieldValue.increment(rewardAmount),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          transaction.set(userRef, {
            'exp': newExp,
            'level': newLevel,
            'coins': FieldValue.increment(rewardAmount),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          return newLevel;
        })
        .then((newLevel) async {
          final taskDoc = await _firestore
              .collection('tasks')
              .doc(taskId)
              .get();

          final taskData = taskDoc.data();

          if (taskData != null) {
            final childId = taskData['childId'];

            if (childId != null) {
              await NotificationService().createNotificationRequest(
                receiverId: childId,
                title: 'Nhiệm vụ đã được duyệt',
                body: 'Phụ huynh đã duyệt nhiệm vụ của bạn.',
                type: 'task_approved',
                taskId: taskId,
              );
            }
          }

          return newLevel;
        });
  }

  Future<void> rejectTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).update({
      'status': 'rejected',
      'verifiedAt': FieldValue.serverTimestamp(),
    });

    final taskDoc = await _firestore.collection('tasks').doc(taskId).get();

    final taskData = taskDoc.data();

    if (taskData != null) {
      final childId = taskData['childId'];

      if (childId != null) {
        await NotificationService().createNotificationRequest(
          receiverId: childId,
          title: 'Nhiệm vụ bị từ chối',
          body: 'Phụ huynh đã từ chối nhiệm vụ.',
          type: 'task_rejected',
          taskId: taskId,
        );
      }
    }
  }

  Future<void> submitTask({
    required String taskId,
    required String childNote,
    required String proofImage,
  }) async {
    await _firestore.collection('tasks').doc(taskId).update({
      'status': 'submitted',
      'childNote': childNote,
      'proofImage': proofImage,
      'submittedAt': FieldValue.serverTimestamp(),
    });
    final taskDoc = await _firestore.collection('tasks').doc(taskId).get();
    final taskData = taskDoc.data();

    if (taskData != null) {
      final parentId = taskData['parentId'];

      if (parentId != null) {
        try {
          await NotificationService().createNotificationRequest(
            receiverId: parentId,
            title: 'Con đã gửi nhiệm vụ',
            body: 'Một nhiệm vụ mới đang chờ phụ huynh xác nhận.',
            type: 'task_submitted',
            taskId: taskId,
          );
        } catch (e) {
          debugPrint('SUBMIT_TASK_NOTIFICATION_ERROR: $e');
        }
      }
    }
  }

  Future<int> getChildLevel(String childId) async {
    final doc = await _firestore.collection('users').doc(childId).get();

    final data = doc.data();

    if (data == null) return 1;

    return (data['level'] ?? 1).toInt();
  }
}
