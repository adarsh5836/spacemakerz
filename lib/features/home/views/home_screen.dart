import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/home_cubit.dart';
import '../components/home_drawer.dart';
import 'dashboard_view.dart';
import '../../projects/views/projects_screen.dart';
import '../../tasks/views/tasks_screen.dart';
import '../../profile/views/profile_screen.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_style.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/enums/app_enums.dart';
import '../../../common/widgets/exit_confirmation_dialog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit(),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  int _getActualIndex(int bottomBarIndex, bool hideProjects) {
    if (!hideProjects) return bottomBarIndex;
    if (bottomBarIndex == 0) return 0;
    if (bottomBarIndex == 1) return 2; // bottom 1 -> actual 2 (Tasks)
    return 3; // bottom 2 -> actual 3 (Profile)
  }

  int _getBottomBarIndex(int actualIndex, bool hideProjects) {
    if (!hideProjects) return actualIndex;
    if (actualIndex == 0) return 0;
    if (actualIndex == 1) return 0;
    if (actualIndex == 2) return 1; // actual 2 (Tasks) -> bottom 1
    return 2; // actual 3 (Profile) -> bottom 2
  }

  @override
  Widget build(BuildContext context) {
    final session = context.read<LocalStorage>();
    final role = session.currentRole;
    final hideProjects = role == UserRole.user || role == UserRole.dealer;

    return BlocBuilder<HomeCubit, int>(
      builder: (context, currentIndex) {
        // Safe check: if projects is hidden but currentIndex is somehow 1 (Projects), force redirect to 0 (Dashboard)
        final safeCurrentIndex = (hideProjects && currentIndex == 1) ? 0 : currentIndex;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, Object? result) async {
            if (didPop) return;
            await ExitConfirmationDialog.show(context);
          },
          child: Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            appBar: _buildAppBar(context, safeCurrentIndex),
            drawer: const HomeDrawer(),
            body: _buildBody(safeCurrentIndex),
            bottomNavigationBar: _buildBottomNavigationBar(context, safeCurrentIndex, hideProjects),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, int currentIndex) {
    String title = 'Dashboard';
    switch (currentIndex) {
      case 1:
        title = 'Projects';
        break;
      case 2:
        title = 'Tasks';
        break;
      case 3:
        title = 'Profile';
        break;
    }

    return AppBar(
      title: Text(title, style: AppTextStyle.heading.copyWith(color: AppColors.surfaceWhite)),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.chat_outlined), // Using chat as fallback for WhatsApp
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildBody(int index) {
    switch (index) {
      case 0:
        return const DashboardView();
      case 1:
        return const ProjectsScreen(showBackButton: false);
      case 2:
        return const TasksScreen(showBackButton: false);
      case 3:
        return const ProfileScreen(showBackButton: false);
      default:
        return const DashboardView();
    }
  }

  Widget _buildBottomNavigationBar(BuildContext context, int currentIndex, bool hideProjects) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: BottomNavigationBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            currentIndex: _getBottomBarIndex(currentIndex, hideProjects),
            onTap: (index) {
              final actualIdx = _getActualIndex(index, hideProjects);
              context.read<HomeCubit>().changeTab(actualIdx);
            },
            type: BottomNavigationBarType.fixed,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              if (!hideProjects)
                const BottomNavigationBarItem(
                  icon: Icon(Icons.work_outline),
                  activeIcon: Icon(Icons.work),
                  label: 'Projects',
                ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.task_outlined),
                activeIcon: Icon(Icons.task),
                label: 'Tasks',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
