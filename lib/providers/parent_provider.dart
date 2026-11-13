import 'package:flutter/material.dart';

import '../services/parent_service.dart';

/// Provider hỗ trợ quản lý hồ sơ Phụ huynh.
class ParentProvider extends ChangeNotifier {
  final ParentService _parentService = ParentService();

  Map<String, dynamic>? _profile;
  bool _isLoading = false;

  Map<String, dynamic>? get profile => _profile;
  bool get isLoading => _isLoading;

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();
    try {
      _profile = await _parentService.getParentProfile();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
