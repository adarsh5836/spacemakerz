import 'package:equatable/equatable.dart';
import '../../../app/models/project_model.dart';

abstract class ProjectsState extends Equatable {
  const ProjectsState();
  @override List<Object?> get props => [];
}

class ProjectsInitial extends ProjectsState { const ProjectsInitial(); }
class ProjectsLoading extends ProjectsState { const ProjectsLoading(); }

class ProjectsLoaded extends ProjectsState {
  final List<ProjectModel> projects;
  final String filterStatus; // 'all' | 'active' | 'completed'
  const ProjectsLoaded(this.projects, {this.filterStatus = 'all'});

  List<ProjectModel> get filtered {
    if (filterStatus == 'all') return projects;
    return projects.where((p) => p.status.jsonValue == filterStatus).toList();
  }

  @override List<Object?> get props => [projects, filterStatus];

  ProjectsLoaded copyWith({String? filterStatus}) =>
      ProjectsLoaded(projects, filterStatus: filterStatus ?? this.filterStatus);
}

class ProjectsError extends ProjectsState {
  final String message;
  const ProjectsError(this.message);
  @override List<Object?> get props => [message];
}
