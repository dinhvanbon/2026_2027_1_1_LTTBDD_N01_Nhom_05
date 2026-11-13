/// Định nghĩa tên các tuyến điều hướng (Routes) trong ứng dụng Life RPG.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String roleSelect = '/role-select';

  static const String parentMain = '/parent';
  static const String parentDashboard = '/parent/dashboard';
  static const String createTask = '/parent/create-task';
  static const String verifyTask = '/parent/verify-task';
  static const String manageChildren = '/parent/children';
  static const String parentRewards = '/parent/rewards';
  static const String parentProfile = '/parent/profile';

  static const String childMain = '/child';
  static const String childHome = '/child/home';
  static const String childTasks = '/child/tasks';
  static const String childRewards = '/child/rewards';
  static const String childProfile = '/child/profile';

  static const String achievements = '/achievements';
  static const String activityLog = '/activity-log';
  static const String leaderboard = '/leaderboard';
  static const String settings = '/settings';
  static const String groupInfo = '/group-info';
}
