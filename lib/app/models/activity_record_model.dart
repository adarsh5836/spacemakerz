import 'task_model.dart';

class ActivityRecordModel {
  final int id;
  final String? taskId;
  final TaskModel? task;
  final List<String> photos;
  final int? syncId;
  final String? activityRefNo;
  final int? empId;
  final int? projectId;
  final int? dealerId;
  final int? flexId;
  final String? flexSize;
  final int? taskSno;
  final String? latitude;
  final String? longitude;
  final String? gpsAddress;
  final String? remark;
  final String? remark1;
  final int? viewId;
  final String? distanceFromLast;
  final int? status;
  final String? createdDate;
  final String? updatedDate;
  final int? timestamps;

  const ActivityRecordModel({
    required this.id,
    this.taskId,
    this.task,
    required this.photos,
    this.syncId,
    this.activityRefNo,
    this.empId,
    this.projectId,
    this.dealerId,
    this.flexId,
    this.flexSize,
    this.taskSno,
    this.latitude,
    this.longitude,
    this.gpsAddress,
    this.remark,
    this.remark1,
    this.viewId,
    this.distanceFromLast,
    this.status,
    this.createdDate,
    this.updatedDate,
    this.timestamps,
  });

  factory ActivityRecordModel.fromJson(Map<String, dynamic> json) {
    final photoVal = json['photo'];
    List<String> parsedPhotos = [];
    if (photoVal is List) {
      parsedPhotos = photoVal.map((e) {
        var s = e.toString().trim();
        if (s.startsWith('[')) {
          s = s.substring(1).trim();
        }
        if (s.endsWith(']')) {
          s = s.substring(0, s.length - 1).trim();
        }
        return s.replaceAll('"', '').replaceAll("'", "");
      }).where((s) => s.isNotEmpty).toList();
    } else if (photoVal is String) {
      var s = photoVal.trim();
      if (s.startsWith('[') && s.endsWith(']')) {
        s = s.substring(1, s.length - 1);
      }
      parsedPhotos = s
          .split(',')
          .map((e) {
            var url = e.trim().replaceAll('"', '').replaceAll("'", "");
            if (url.startsWith('[')) {
              url = url.substring(1).trim();
            }
            if (url.endsWith(']')) {
              url = url.substring(0, url.length - 1).trim();
            }
            return url;
          })
          .where((e) => e.isNotEmpty)
          .toList();
    }

    TaskModel? parsedTask;
    String? parsedTaskId;
    if (json['task_id'] != null) {
      if (json['task_id'] is Map) {
        parsedTask = TaskModel.fromJson(json['task_id'] as Map<String, dynamic>);
        parsedTaskId = parsedTask.id;
      } else {
        parsedTaskId = json['task_id'].toString();
      }
    }

    return ActivityRecordModel(
      id: json['id'] as int,
      taskId: parsedTaskId,
      task: parsedTask,
      photos: parsedPhotos,
      syncId: json['sync_id'] as int?,
      activityRefNo: json['activity_ref_no'] as String?,
      empId: json['emp_id'] as int?,
      projectId: json['project_id'] as int?,
      dealerId: json['dealer_id'] as int?,
      flexId: json['flex_id'] as int?,
      flexSize: json['flex_size'] as String?,
      taskSno: json['task_sno'] as int?,
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      gpsAddress: json['gps_address'] as String?,
      remark: json['remark'] as String?,
      remark1: json['remark1'] as String?,
      viewId: json['view_id'] as int?,
      distanceFromLast: json['distance_from_last'] as String?,
      status: json['status'] as int?,
      createdDate: json['created_date'] as String?,
      updatedDate: json['updated_date'] as String?,
      timestamps: (json['timestaps'] ?? json['timestamps']) as int?,
    );
  }
}
