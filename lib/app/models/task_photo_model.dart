import '../../core/enums/app_enums.dart';

class TaskPhotoModel {
  final String id;
  final String taskId;
  final String localPath;   // absolute path on device — no network URLs
  final String uploadedById;
  final UserRole uploadedByRole;
  final String createdAt;
  final String? activityId; // Groups photos into a single activity session
  final double? latitude;
  final double? longitude;
  final String? address;

  const TaskPhotoModel({
    required this.id,
    required this.taskId,
    required this.localPath,
    required this.uploadedById,
    required this.uploadedByRole,
    required this.createdAt,
    this.activityId,
    this.latitude,
    this.longitude,
    this.address,
  });

  factory TaskPhotoModel.fromJson(Map<String, dynamic> j) => TaskPhotoModel(
        id:             j['id']               as String,
        taskId:         j['task_id']          as String,
        localPath:      j['local_path']       as String,
        uploadedById:   j['uploaded_by_id']   as String,
        uploadedByRole: UserRole.fromJson(j['uploaded_by_role'] as String),
        createdAt:      j['created_at']       as String,
        activityId:     j['activity_id']      as String?,
        latitude:       (j['latitude']        as num?)?.toDouble(),
        longitude:      (j['longitude']       as num?)?.toDouble(),
        address:        j['address']          as String?,
      );

  Map<String, dynamic> toJson() => {
        'id':               id,
        'task_id':          taskId,
        'local_path':       localPath,
        'uploaded_by_id':   uploadedById,
        'uploaded_by_role': uploadedByRole.name,
        'created_at':       createdAt,
        if (activityId != null) 'activity_id': activityId,
        if (latitude != null)   'latitude': latitude,
        if (longitude != null)  'longitude': longitude,
        if (address != null)    'address': address,
      };
}
