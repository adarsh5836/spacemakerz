import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/repositories/tasks_repository.dart';
import '../../../common/widgets/common_loader.dart';
import '../../../common/widgets/common_empty_widget.dart';
import '../../../constants/app_colors.dart';

import '../../../common/widgets/common_text_field.dart';
import '../../../core/enums/app_enums.dart';
import '../cubit/tasks_cubit.dart';
import '../cubit/tasks_state.dart';
import '../components/task_card.dart';
import 'task_details_screen.dart';

import 'package:get/get.dart';

class TasksScreen extends StatelessWidget {
  final bool showBackButton;
  const TasksScreen({super.key, this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    final String? projectId = Get.arguments?.toString();
    return BlocProvider(
      create: (ctx) =>
          TasksCubit(ctx.read<TasksRepository>())
            ..loadTasks(projectId: projectId),
      child: _TasksView(
        showAppBar: projectId != null || showBackButton,
        projectId: projectId,
      ),
    );
  }
}

class _TasksView extends StatefulWidget {
  final bool showAppBar;
  final String? projectId;
  const _TasksView({required this.showAppBar, this.projectId});
  @override
  State<_TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends State<_TasksView> {
  String _search = '';

  TaskStatus? get _selectedStatus => TasksCubit.dashboardStatusFilter;
  set _selectedStatus(TaskStatus? val) {
    TasksCubit.dashboardStatusFilter = val;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('Project Tasks'),
              leading: widget.showAppBar
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Get.back(),
                    )
                  : null,
            )
          : null,
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: CommonTextField(
              label: '',
              hint: 'Search by location, dealer or code...',
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textSecondary,
              ),
              onChanged: (v) => setState(() => _search = v.toLowerCase()),
            ),
          ),
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                _buildFilterChip('All', null),
                const SizedBox(width: 8),
                _buildFilterChip('Pending', TaskStatus.pending),
                const SizedBox(width: 8),
                _buildFilterChip('In Progress', TaskStatus.inProgress),
                const SizedBox(width: 8),
                _buildFilterChip('Completed', TaskStatus.completed),
                const SizedBox(width: 8),
                _buildFilterChip('Rejected', TaskStatus.rejected),
              ],
            ),
          ),
          // List
          Expanded(
            child: BlocBuilder<TasksCubit, TasksState>(
              builder: (context, state) {
                if (state is TasksLoading) {
                  return const CommonLoader();
                }
                if (state is TasksError) {
                  return CommonEmptyWidget(
                    title: 'Error',
                    subtitle: state.message,
                  );
                }
                if (state is TasksLoaded) {
                  var tasks = state.tasks;

                  // 1. Status Filter
                  if (_selectedStatus != null) {
                    tasks = tasks
                        .where((t) => t.status == _selectedStatus)
                        .toList();
                  }

                  // 2. Search Filter
                  if (_search.isNotEmpty) {
                    tasks = tasks
                        .where(
                          (t) =>
                              t.taskTitle.toLowerCase().contains(_search) ||
                              (t.dealerName?.name.toLowerCase().contains(_search) ?? false) ||
                              t.district.toLowerCase().contains(_search) ||
                              t.taskCode.toLowerCase().contains(_search),
                        )
                        .toList();
                  }

                  return RefreshIndicator(
                    onRefresh: () => context.read<TasksCubit>().loadTasks(
                      projectId: widget.projectId,
                    ),
                    child: tasks.isEmpty
                        ? ListView(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                            children: [
                              const SizedBox(height: 100),
                              const CommonEmptyWidget(
                                title: 'No Tasks',
                                subtitle:
                                    'No tasks found matching your criteria.',
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                            itemCount: tasks.length,
                            itemBuilder: (ctx, i) {
                              final task = tasks[i];
                              return TaskCard(
                                task: task,
                                onTap: () async {
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          TaskDetailsScreen(taskId: task.id),
                                    ),
                                  );
                                  if (context.mounted) {
                                    context.read<TasksCubit>().loadTasks(
                                      projectId: widget.projectId,
                                    );
                                  }
                                },
                              );
                            },
                          ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, TaskStatus? status) {
    final isSelected = _selectedStatus == status;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = status;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
