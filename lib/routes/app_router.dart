import 'package:get/get.dart';
import 'route_names.dart';
import '../features/splash/views/splash_screen.dart';
import '../features/auth/views/login_screen.dart';
import '../features/home/views/home_screen.dart';
import '../features/attendance/views/attendance_screen.dart';
import '../features/projects/views/projects_screen.dart';
import '../features/tasks/views/tasks_screen.dart';
import '../features/profile/views/profile_screen.dart';
import '../features/leave/views/leave_history_screen.dart';
import '../features/tasks/views/activity_records_screen.dart';
import '../features/tasks/views/activity_location_map_screen.dart';
import '../app/models/task_model.dart';
import '../app/models/activity_record_model.dart';

class AppRouter {
  static final routes = [
    GetPage(
      name: RouteNames.splash,
      page: () => const SplashScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: RouteNames.login,
      page: () => const LoginScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: RouteNames.home,
      page: () => const HomeScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: RouteNames.attendance,
      page: () => const AttendanceScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: RouteNames.projects,
      page: () => const ProjectsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: RouteNames.tasks,
      page: () => const TasksScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: RouteNames.profile,
      page: () => const ProfileScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: RouteNames.leaveHistory,
      page: () => const LeaveHistoryScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: RouteNames.activityRecords,
      page: () {
        final task = Get.arguments as TaskModel;
        return ActivityRecordsScreen(task: task);
      },
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: RouteNames.activityLocationMap,
      page: () {
        final activity = Get.arguments as ActivityRecordModel;
        return ActivityLocationMapScreen(activity: activity);
      },
      transition: Transition.rightToLeft,
    ),
  ];
}
