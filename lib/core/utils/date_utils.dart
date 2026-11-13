/// Các hàm tiện ích định dạng ngày giờ cho nhiệm vụ và lịch sử hoạt động.
class AppDateUtils {
  AppDateUtils._();

  static String formatDate(DateTime? date) {
    if (date == null) return '--/--/----';
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }

  static String formatDateTime(DateTime? date) {
    if (date == null) return '--/--/---- --:--';
    final d = formatDate(date);
    final hh = date.hour.toString().padLeft(2, '0');
    final mm = date.minute.toString().padLeft(2, '0');
    return '$d $hh:$mm';
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
