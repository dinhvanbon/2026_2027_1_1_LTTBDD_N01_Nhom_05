import 'dart:async';

import 'package:flutter/material.dart';

import '../models/activity_model.dart';
import '../services/activity_service.dart';

class ActivityProvider extends ChangeNotifier {
  final ActivityService _activityService = ActivityService();

  final List<ActivityModel> _activities = [];
  StreamSubscription? _activitySubscription;

  List<ActivityModel> get activities => List.unmodifiable(_activities);

  void listenActivities(String childId) {
    _activitySubscription?.cancel();

    _activitySubscription = _activityService.getActivities(childId).listen(
      (snapshot) {
        _activities
          ..clear()
          ..addAll(
            snapshot.docs.map((doc) {
              final data = doc.data();

              return ActivityModel(
                title: data['title'] ?? '',
                description: data['description'] ?? '',
                createdAt:
                    (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
              );
            }),
          );

        notifyListeners();
      },
    );
  }

  Future<void> addActivity({
    required String childId,
    required String title,
    required String description,
  }) async {
    await _activityService.addActivity(
      childId: childId,
      title: title,
      description: description,
    );
  }

  @override
  void dispose() {
    _activitySubscription?.cancel();
    super.dispose();
  }
}