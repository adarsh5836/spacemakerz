import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/models/activity_record_model.dart';
import '../../../core/api/api_client.dart';
import 'activity_records_state.dart';

class ActivityRecordsCubit extends Cubit<ActivityRecordsState> {
  final ApiClient _apiClient;

  ActivityRecordsCubit(this._apiClient) : super(const ActivityRecordsInitial());

  Future<void> fetchActivityRecords(String taskId) async {
    emit(const ActivityRecordsLoading());
    try {
      final response = await _apiClient.get(
        '/activity-record/?task_id=$taskId',
      );

      if (response != null && response is Map<String, dynamic>) {
        final status = response['status'];
        if (status == true) {
          final data = response['data'];
          if (data is List) {
            final activities = data
                .map((a) => ActivityRecordModel.fromJson(a as Map<String, dynamic>))
                .toList();
            emit(ActivityRecordsLoaded(activities));
            return;
          }
        }
      }

      // If status check fails, we emit an empty list as we only set data when status is true
      emit(const ActivityRecordsLoaded([]));
    } catch (e) {
      emit(ActivityRecordsError('Failed to load activities: $e'));
    }
  }
}
