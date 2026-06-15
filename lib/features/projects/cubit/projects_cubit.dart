import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/repositories/projects_repository.dart';
import 'projects_state.dart';

class ProjectsCubit extends Cubit<ProjectsState> {
  final ProjectsRepository _repo;
  ProjectsCubit(this._repo) : super(const ProjectsInitial());

  Future<void> loadProjects() async {
    emit(const ProjectsLoading());
    try {
      final projects = await _repo.getProjects();
      emit(ProjectsLoaded(projects));
    } catch (e) {
      emit(ProjectsError(e.toString()));
    }
  }

  void setFilter(String status) {
    final s = state;
    if (s is ProjectsLoaded) emit(s.copyWith(filterStatus: status));
  }
}
