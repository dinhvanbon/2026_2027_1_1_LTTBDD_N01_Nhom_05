import 'package:flutter/material.dart';

import '../core/constants/app_strings.dart';

/// Quản lý ngôn ngữ hiển thị của ứng dụng (Tiếng Việt / English).
class LanguageProvider extends ChangeNotifier {
  /// Trạng thái ngôn ngữ dùng chung để các hàm [tr] / [trv] có thể gọi
  /// ở bất kỳ đâu (kể cả service, model) mà không cần BuildContext.
  static bool _globalIsEnglish = false;
  static bool get globalIsEnglish => _globalIsEnglish;

  static bool _globalIsDarkMode = false;
  static bool get globalIsDarkMode => _globalIsDarkMode;

  bool _isEnglish = _globalIsEnglish;
  bool _isDarkMode = _globalIsDarkMode;
  bool _notificationsEnabled = true;

  bool get isEnglish => _isEnglish;
  bool get isDarkMode => _isDarkMode;
  bool get notificationsEnabled => _notificationsEnabled;
  String get currentLanguageCode => _isEnglish ? 'en' : 'vi';
  String get currentLanguageName => _isEnglish ? 'English' : 'Tiếng Việt';

  void toggleLanguage() {
    setLanguage(!_isEnglish);
  }

  void setLanguage(bool isEnglish) {
    if (_isEnglish != isEnglish) {
      _isEnglish = isEnglish;
      _globalIsEnglish = isEnglish;
      notifyListeners();
    }
  }

  void toggleDarkMode([bool? value]) {
    final next = value ?? !_isDarkMode;
    if (_isDarkMode != next) {
      _isDarkMode = next;
      _globalIsDarkMode = next;
      notifyListeners();
    }
  }

  void toggleNotifications([bool? value]) {
    final next = value ?? !_notificationsEnabled;
    if (_notificationsEnabled != next) {
      _notificationsEnabled = next;
      notifyListeners();
    }
  }

  String tr(String vi, String en) {
    return _isEnglish ? en : vi;
  }
}

/// Trả về chuỗi theo ngôn ngữ hiện tại.
/// Ví dụ: `Text(tr('Nhiệm vụ', 'Quests'))`
String tr(String vi, String en) {
  return LanguageProvider.globalIsEnglish ? en : vi;
}

/// Dịch các giá trị dữ liệu / khóa logic (độ khó, bộ lọc, danh mục...)
/// đang được lưu bằng tiếng Việt sang tiếng Anh khi hiển thị.
String trv(String vi) {
  if (!LanguageProvider.globalIsEnglish) return vi;
  return AppStrings.viToEn[vi] ?? vi;
}

/// Trả về màu tự động thích ứng theo Chế độ Sáng / Chế độ Tối (Dark Mode chuẩn đen-trắng, giữ nguyên màu tím/cam chủ đạo).
Color appBg([Color light = const Color(0xfffffaff)]) =>
    LanguageProvider.globalIsDarkMode ? const Color(0xFF121212) : light;

Color appCard([Color light = Colors.white]) =>
    LanguageProvider.globalIsDarkMode ? const Color(0xFF1E1E24) : light;

Color appSurface([Color light = const Color(0xfff5f0ff)]) =>
    LanguageProvider.globalIsDarkMode ? const Color(0xFF262630) : light;

Color appBorder([Color light = const Color(0xfff0e7fb)]) =>
    LanguageProvider.globalIsDarkMode ? const Color(0xFF333340) : light;

Color appText([Color light = const Color(0xff2d243b)]) =>
    LanguageProvider.globalIsDarkMode ? Colors.white : light;

Color appSubtext([Color light = const Color(0xff8b7c99)]) =>
    LanguageProvider.globalIsDarkMode ? const Color(0xFFB4B4C4) : light;

