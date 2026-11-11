import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _activitiesRef(String childId) {
    return _firestore.collection('users').doc(childId).collection('activities');
  }

  Future<void> addActivity({
    required String childId,
    required String title,
    required String description,
  }) async {
    await _activitiesRef(childId).add({
      'title': title,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getActivities(String childId) {
    return _activitiesRef(
      childId,
    ).orderBy('createdAt', descending: true).snapshots();
  }
}

extension ActivityMigration on ActivityService {
  Future<void> syncOldTasksToActivity() async {
    final tasks = await FirebaseFirestore.instance.collection('tasks').get();

    for (final doc in tasks.docs) {
      final data = doc.data();

      final childId = data['childId'];

      if (childId == null) continue;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(childId)
          .collection('activities')
          .add({
            'title': 'Task ${data['status']}',
            'description': data['title'] ?? '',
            'createdAt': data['createdAt'] ?? FieldValue.serverTimestamp(),
          });
    }
  }
}
