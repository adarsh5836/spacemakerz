import 'package:equatable/equatable.dart';
import '../../../app/models/activity_record_model.dart';

abstract class ActivityRecordsState extends Equatable {
  const ActivityRecordsState();

  @override
  List<Object?> get props => [];
}

class ActivityRecordsInitial extends ActivityRecordsState {
  const ActivityRecordsInitial();
}

class ActivityRecordsLoading extends ActivityRecordsState {
  const ActivityRecordsLoading();
}

class ActivityRecordsLoaded extends ActivityRecordsState {
  final List<ActivityRecordModel> activities;
  const ActivityRecordsLoaded(this.activities);

  @override
  List<Object?> get props => [activities];
}

class ActivityRecordsError extends ActivityRecordsState {
  final String message;
  const ActivityRecordsError(this.message);

  @override
  List<Object?> get props => [message];
}
