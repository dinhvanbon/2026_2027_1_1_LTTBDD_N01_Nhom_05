import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService = TaskService();

  List<TaskModel> _tasks = [];

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<List<TaskModel>>? _tasksSubscription;

  TaskProvider() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      _tasksSubscription?.cancel();

      if (user == null) {
        _tasks = [];
        notifyListeners();
        return;
      }

      listenToTasks();
    });
  }

  List<TaskModel> get tasks => List.unmodifiable(_tasks);

  List<TaskModel> get pendingTasks {
    return _tasks.where((task) => task.status == TaskStatus.pending).toList();
  }

  List<TaskModel> get submittedTasks {
    return _tasks.where((task) => task.status == TaskStatus.submitted).toList();
  }

  List<TaskModel> get approvedTasks {
    return _tasks.where((task) => task.status == TaskStatus.approved).toList();
  }

  void listenToTasks() {
    _tasksSubscription?.cancel();

    _tasksSubscription = _taskService.getTasksStream().listen((tasks) {
      _tasks = tasks;
      notifyListeners();
    });
  }

  void submitTask(String taskId, {String? childNote, String? proofImage}) {
  final index = _tasks.indexWhere((task) => task.id == taskId);

  if (index == -1) return;

  _tasks[index] = _tasks[index].copyWith(
    status: TaskStatus.submitted,
    submittedAt: DateTime.now(),
    childNote: childNote,
    proofImage: proofImage,
  );

  notifyListeners();
}

  @override
  void dispose() {
    _authSubscription?.cancel();
    _tasksSubscription?.cancel();
    super.dispose();
  }
}