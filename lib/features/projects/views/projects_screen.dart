import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/repositories/projects_repository.dart';
import '../../../common/widgets/common_empty_widget.dart';
import '../../../common/widgets/common_loader.dart';
import '../../../common/widgets/common_text_field.dart';
import '../../../constants/app_colors.dart';
import 'package:get/get.dart';
import '../../../routes/route_names.dart';
import '../cubit/projects_cubit.dart';
import '../cubit/projects_state.dart';
import '../components/project_card.dart';
import '../components/filter_chip_row.dart';

class ProjectsScreen extends StatelessWidget {
  final bool showBackButton;
  const ProjectsScreen({super.key, this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) =>
          ProjectsCubit(ctx.read<ProjectsRepository>())..loadProjects(),
      child: const _ProjectsView(),
    );
  }
}

class _ProjectsView extends StatefulWidget {
  const _ProjectsView();
  @override
  State<_ProjectsView> createState() => _ProjectsViewState();
}

class _ProjectsViewState extends State<_ProjectsView> {
  String _search = '';
  static const _filters = ['All', 'active', 'completed', 'on_hold'];
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          // Search + filter
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: CommonTextField(
                  label: '',
                  hint: 'Search by project name, city...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
                  ),
                  onChanged: (v) => setState(() => _search = v.toLowerCase()),
                ),
              ),
              const SizedBox(height: 12),
              FilterChipRow(
                options: _filters
                    .map((f) => f == 'All' ? 'All' : _label(f))
                    .toList(),
                selected: _selectedFilter == 'All'
                    ? 'All'
                    : _label(_selectedFilter),
                onSelected: (label) {
                  final raw = label == 'All'
                      ? 'all'
                      : _filters.firstWhere(
                          (f) => _label(f) == label,
                          orElse: () => 'all',
                        );
                  setState(() => _selectedFilter = raw == 'all' ? 'All' : raw);
                  context.read<ProjectsCubit>().setFilter(raw);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),

          // List
          Expanded(
            child: BlocBuilder<ProjectsCubit, ProjectsState>(
              builder: (context, state) {
                if (state is ProjectsLoading) return const CommonLoader();
                if (state is ProjectsError) {
                  return CommonEmptyWidget(
                    title: 'Error',
                    subtitle: state.message,
                  );
                }
                if (state is ProjectsLoaded) {
                  var projects = state.filtered;
                  if (_search.isNotEmpty) {
                    projects = projects
                        .where(
                          (p) =>
                              p.projectName.toLowerCase().contains(_search) ||
                              p.city.toLowerCase().contains(_search) ||
                              p.projectCode.toLowerCase().contains(_search),
                        )
                        .toList();
                  }
                  if (projects.isEmpty) {
                    return const CommonEmptyWidget(
                      title: 'No Projects',
                      subtitle: 'No projects found matching your filters.',
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () =>
                        context.read<ProjectsCubit>().loadProjects(),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                      itemCount: projects.length,
                      itemBuilder: (_, i) => ProjectCard(
                        project: projects[i],
                        onTap: () async {
                          await Get.toNamed(
                            RouteNames.tasks,
                            arguments: projects[i].id,
                          );
                          // Refresh projects in case status changed automatically
                          if (context.mounted) {
                            context.read<ProjectsCubit>().loadProjects();
                          }
                        },
                      ),
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

  String _label(String raw) {
    switch (raw) {
      case 'active':
        return 'Active';
      case 'completed':
        return 'Completed';
      case 'on_hold':
        return 'On Hold';
      default:
        return raw;
    }
  }
}
