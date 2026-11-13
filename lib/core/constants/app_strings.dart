/// Các chuỗi dùng chung và bảng dịch Việt - Anh cho dữ liệu hiển thị.
class AppStrings {
  AppStrings._();

  static const String appName = 'Life RPG';
  static const String groupName = 'Nhóm 05';
  static const String studentName = 'Đinh Văn Bốn';
  static const String studentId = '22010067';

  /// Bảng dịch cho các giá trị được lưu bằng tiếng Việt trong dữ liệu
  /// (độ khó, trạng thái, bộ lọc, danh mục) - dùng với hàm `trv()`.
  static const Map<String, String> viToEn = {
    // Bộ lọc / trạng thái nhiệm vụ
    'Tất cả': 'All',
    'Cần làm': 'To do',
    'Đã nộp': 'Submitted',
    'Đã duyệt': 'Approved',
    'Từ chối': 'Rejected',
    // Độ khó
    'Dễ': 'Easy',
    'Vừa': 'Medium',
    'Trung bình': 'Medium',
    'Khó': 'Hard',
    // Danh mục
    'Học tập': 'Study',
    'Việc nhà': 'Housework',
    'Sức khỏe': 'Health',
  };
}
