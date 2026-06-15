import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/repositories/tasks_repository.dart';
import '../../../core/enums/app_enums.dart';
import 'tasks_state.dart';

class TasksCubit extends Cubit<TasksState> {
  final TasksRepository _repo;
  static TaskStatus? dashboardStatusFilter;
  TasksCubit(this._repo) : super(const TasksInitial());

  Future<void> loadTasks({String? projectId}) async {
    emit(const TasksLoading());
    try {
      var tasks = await _repo.getTasks(projectId: projectId);
      emit(TasksLoaded(tasks));
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }
}
