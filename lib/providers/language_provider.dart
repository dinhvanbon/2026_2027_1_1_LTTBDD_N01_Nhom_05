import 'package:flutter/material.dart';

import '../core/constants/app_strings.dart';

/// Quản lý ngôn ngữ hiển thị của ứng dụng (Tiếng Việt / English).
class LanguageProvider extends ChangeNotifier {
  /// Trạng thái ngôn ngữ dùng chung để các hàm [tr] / [trv] có thể gọi
  /// ở bất kỳ đâu (kể cả service, model) mà không cần BuildContext.
  static bool _globalIsEnglish = false;
  static bool get globalIsEnglish => _globalIsEnglish;

  bool _isEnglish = _globalIsEnglish;

  bool get isEnglish => _isEnglish;
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
