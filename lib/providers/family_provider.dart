import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/user_service.dart';

class FamilyProvider extends ChangeNotifier {
  final UserService _userService = UserService();

  List<Map<String, dynamic>> _children = [];
  StreamSubscription<List<Map<String, dynamic>>>? _childrenSubscription;

  List<Map<String, dynamic>> get children => List.unmodifiable(_children);

  bool get hasChildren => _children.isNotEmpty;

  void listenToLinkedChildren() {
    _childrenSubscription?.cancel();

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      debugPrint('FamilyProvider listen skipped: user null');
      _childrenSubscription = null;
      _children = [];
      return;
    }

    try {
      _childrenSubscription = _userService.getLinkedChildrenStream().listen(
        (children) {
          _children = children;
          notifyListeners();
        },
        onError: (error) {
          debugPrint('FamilyProvider listen error: $error');
          _children = [];
          notifyListeners();
        },
      );
    } catch (error) {
      debugPrint('FamilyProvider listen sync error: $error');
      _childrenSubscription = null;
      _children = [];
    }
  }

  Future<void> linkChild(String childId) async {
    await _userService.linkChildToParent(childId);
    listenToLinkedChildren();
  }

  Future<void> linkChildByCode(String code) async {
    await _userService.linkChildByCode(code);
    listenToLinkedChildren();
  }

  Future<void> unlinkChild(String childId) async {
    await _userService.unlinkChild(childId);
    listenToLinkedChildren();
  }

  void clear() {
    _childrenSubscription?.cancel();
    _childrenSubscription = null;
    _children = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _childrenSubscription?.cancel();
    super.dispose();
  }
}
