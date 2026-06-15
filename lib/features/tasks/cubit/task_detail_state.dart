import 'package:equatable/equatable.dart';
import '../../../app/models/task_model.dart';
import '../../../app/models/task_photo_model.dart';
import '../../../app/models/activity_record_model.dart';

abstract class TaskDetailState extends Equatable {
  const TaskDetailState();
  @override
  List<Object?> get props => [];
}

class TaskDetailInitial extends TaskDetailState {
  const TaskDetailInitial();
}

class TaskDetailLoading extends TaskDetailState {
  const TaskDetailLoading();
}

class TaskDetailUpdating extends TaskDetailState {
  final TaskModel task;
  final List<TaskPhotoModel> photos;
  final List<ActivityRecordModel> activities;
  const TaskDetailUpdating(
    this.task,
    this.photos, {
    this.activities = const [],
  });
  @override
  List<Object?> get props => [task, photos, activities];
}

class TaskDetailLoaded extends TaskDetailState {
  final TaskModel task;
  final List<TaskPhotoModel> photos;
  final List<ActivityRecordModel> activities;
  final bool canUpload;
  final bool canChangeStatus;

  // Live location
  final double? currentLat;
  final double? currentLng;
  final String? currentAddress;

  // Distance from the last photo location (metres). null = not yet computed.
  final double? distanceFromLastPhoto;

  // Whether the user is >= 100 m from the last photo spot (or no photo yet).
  final bool readyToCapture;

  const TaskDetailLoaded({
    required this.task,
    required this.photos,
    this.activities = const [],
    required this.canUpload,
    required this.canChangeStatus,
    this.currentLat,
    this.currentLng,
    this.currentAddress,
    this.distanceFromLastPhoto,
    this.readyToCapture = true,
  });

  @override
  List<Object?> get props => [
    task,
    photos,
    activities,
    canUpload,
    canChangeStatus,
    currentLat,
    currentLng,
    currentAddress,
    distanceFromLastPhoto,
    readyToCapture,
  ];

  TaskDetailLoaded copyWith({
    TaskModel? task,
    List<TaskPhotoModel>? photos,
    List<ActivityRecordModel>? activities,
    double? currentLat,
    double? currentLng,
    String? currentAddress,
    double? distanceFromLastPhoto,
    bool? readyToCapture,
  }) => TaskDetailLoaded(
    task: task ?? this.task,
    photos: photos ?? this.photos,
    activities: activities ?? this.activities,
    canUpload: canUpload,
    canChangeStatus: canChangeStatus,
    currentLat: currentLat ?? this.currentLat,
    currentLng: currentLng ?? this.currentLng,
    currentAddress: currentAddress ?? this.currentAddress,
    distanceFromLastPhoto: distanceFromLastPhoto ?? this.distanceFromLastPhoto,
    readyToCapture: readyToCapture ?? this.readyToCapture,
  );
}

class TaskDetailError extends TaskDetailState {
  final String message;
  const TaskDetailError(this.message);
  @override
  List<Object?> get props => [message];
}
