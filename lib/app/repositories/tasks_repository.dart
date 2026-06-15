import '../../core/api/api_client.dart';
import '../../core/error/failures.dart';
import '../../core/enums/app_enums.dart';
import '../../core/storage/local_storage.dart';
import '../models/task_model.dart';
import '../models/task_photo_model.dart';
import '../models/activity_record_model.dart';
import '../services/json_storage_service.dart';

class TasksRepository {
  final JsonStorageService _storage;
  final LocalStorage _localStorage;
  final ApiClient _apiClient;

  TasksRepository(this._storage, this._localStorage, this._apiClient);

  // ─── TASKS ────────────────────────────────────────────────────────────────

  /// Returns tasks filtered by the current user's role and optional [projectId].
  Future<List<TaskModel>> getTasks({String? projectId}) async {
    final queryParams = <String, String>{};

    if (projectId != null && projectId.isNotEmpty) {
      queryParams['project_id'] = projectId;
    }

    final role = _localStorage.currentRole;
    final userId = _localStorage.currentUserId ?? '';

    switch (role) {
      case UserRole.user:
        queryParams['user_id'] = userId;
        break;
      case UserRole.manager:
        queryParams['manager_id'] = userId;
        break;
      case UserRole.dealer:
        queryParams['dealer_id'] = userId;
        break;
      case UserRole.superAdmin:
        break;
    }

    try {
      final response = await _apiClient.get(
        '/tasks-record/',
        queryParams: queryParams,
      );
      if (response != null && response is Map<String, dynamic>) {
        final status = response['status'];
        if (status == true) {
          final data = response['data'] as List;
          return data
              .map((t) => TaskModel.fromJson(t as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (_) {
      // Graceful fallback to local JSON storage if API call fails
      await Future.delayed(const Duration(milliseconds: 300));
      final records = await _storage.readAll('tasks.json');
      var all = records.map(TaskModel.fromJson).toList();

      if (projectId != null && projectId.isNotEmpty) {
        all = all.where((t) => t.projectIdStr == projectId).toList();
      }

      switch (role) {
        case UserRole.manager:
          final state = _localStorage.currentState ?? '';
          return all.where((t) => t.state == state).toList();

        case UserRole.dealer:
          final dealerId = _localStorage.currentDealerId ?? userId;
          return all.where((t) => t.dealerId == dealerId).toList();

        case UserRole.user:
          return all.where((t) => t.userId == userId).toList();

        case UserRole.superAdmin:
          return all;
      }
    }
  }

  Future<TaskModel?> getTaskById(String id) async {
    try {
      final response = await _apiClient.get('/tasks-record/$id');
      if (response != null && response is Map<String, dynamic>) {
        final status = response['status'];
        if (status == true) {
          final data = response['data'] as Map<String, dynamic>;
          return TaskModel.fromJson(data);
        }
      }
      return null;
    } catch (_) {
      final records = await _storage.readAll('tasks.json');
      final match = records.cast<Map<String, dynamic>?>().firstWhere(
        (r) => r!['id'] == id,
        orElse: () => null,
      );
      return match == null ? null : TaskModel.fromJson(match);
    }
  }

  /// Updates the status of [taskId].
  Future<void> updateStatus(String taskId, TaskStatus status) async {
    // await _storage.update('tasks.json', taskId, {
    //   'status': status.jsonValue,
    //   'updated_at': DateTime.now().toIso8601String(),
    // });

    // // Sync project status based on task progress
    // await _syncProjectStatus(taskId);

    // Sync backend status
    final statusInt = status == TaskStatus.completed ? 3 : 4;
    await _apiClient.put(
      '/tasks-record/$taskId/',
      body: {'task_status': statusInt, 'status': statusInt},
    );
  }

  /// Checks all tasks in a project and updates project status if needed.
  Future<void> _syncProjectStatus(String taskId) async {
    final allTasks = await _storage.readAll('tasks.json');
    final updatedTask = allTasks.firstWhere((t) => t['id'] == taskId);
    final projectId = updatedTask['project_id'] as String;

    final projectTasks = allTasks
        .where((t) => t['project_id'] == projectId)
        .toList();

    // Determine new status
    // A project is ONLY 'completed' if ALL its tasks are 'completed'.
    // If any tasks are rejected, pending, or in progress, it stays 'active'.
    final allCompleted = projectTasks.every((t) => t['status'] == 'completed');

    if (allCompleted) {
      await _storage.update('projects.json', projectId, {
        'status': 'completed',
        'updated_at': DateTime.now().toIso8601String(),
      });
    } else {
      // If at least one task is not pending, it's active
      // (Most are already active, but this ensures it moves back if a task is reopened)
      await _storage.update('projects.json', projectId, {
        'status': 'active',
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }

  // ─── PHOTOS ───────────────────────────────────────────────────────────────

  /// Returns all photos for [taskId].
  Future<List<TaskPhotoModel>> getPhotos(String taskId) async {
    final records = await _storage.readAll('task_photos.json');
    return records
        .map(TaskPhotoModel.fromJson)
        .where((p) => p.taskId == taskId)
        .toList();
  }

  /// Adds a photo record.
  Future<TaskPhotoModel> addPhoto({
    required String taskId,
    required String localPath,
    String? activityId,
    double? latitude,
    double? longitude,
    String? address,
  }) async {
    final photo = TaskPhotoModel(
      id: '${taskId}_${DateTime.now().millisecondsSinceEpoch}',
      taskId: taskId,
      localPath: localPath,
      uploadedById: _localStorage.currentUserId ?? '',
      uploadedByRole: _localStorage.currentRole,
      createdAt: DateTime.now().toIso8601String(),
      activityId:
          activityId ?? '${taskId}_${DateTime.now().millisecondsSinceEpoch}',
      latitude: latitude,
      longitude: longitude,
      address: address,
    );
    await _storage.add('task_photos.json', photo.toJson());
    return photo;
  }

  /// Deletes a photo by [photoId]. Only the uploader or a manager can delete.
  Future<bool> deletePhoto(String photoId) async {
    final records = await _storage.readAll('task_photos.json');
    final match = records.cast<Map<String, dynamic>?>().firstWhere(
      (r) => r!['id'] == photoId,
      orElse: () => null,
    );
    if (match == null) return false;

    final photo = TaskPhotoModel.fromJson(match);
    final currentId = _localStorage.currentUserId ?? '';
    final currentRole = _localStorage.currentRole;

    // Permission: uploader can delete their own, manager can delete any
    final canDelete =
        photo.uploadedById == currentId ||
        currentRole == UserRole.manager ||
        currentRole == UserRole.superAdmin;

    if (!canDelete) return false;
    await _storage.delete('task_photos.json', photoId);
    return true;
  }

  /// Returns true if the current user can upload to [task].
  bool canUploadPhoto(TaskModel task) {
    if (!task.status.isEditable) return false;
    final role = _localStorage.currentRole;
    // Only dealer and manager can upload if task is editable
    return role == UserRole.dealer || role == UserRole.user;
  }

  /// Returns true if the current user can change [task] status.
  bool canChangeStatus(TaskModel task) {
    if (!task.status.isEditable) return false;
    final role = _localStorage.currentRole;
    // Only dealer and manager can mark complete/reject
    return role == UserRole.dealer || role == UserRole.manager;
  }

  Future<List<ActivityRecordModel>> getActivityRecords(String taskId) async {
    try {
      // final token = _localStorage.getToken() ?? '';
      final response = await _apiClient.get(
        '/activity-record/?task_id=$taskId',
        // headers: {
        //   'accesstoken': token,
        // },
      );
      if (response != null && response is List) {
        return response
            .map((a) => ActivityRecordModel.fromJson(a as Map<String, dynamic>))
            // .where((a) => a.taskId == taskId)
            .toList();
      }
      if (response != null && response is Map<String, dynamic>) {
        final data = response['data'];
        if (data is List) {
          return data
              .map(
                (a) => ActivityRecordModel.fromJson(a as Map<String, dynamic>),
              )
              .toList();
        }
      }
      return [];
    } catch (e) {
      print("Error in getActivityRecords: $e");
      return [];
    }
  }

  /// Uploads a photo to the backend using the multipart GET endpoint.
  Future<Map<String, dynamic>> uploadActivityPhoto({
    required String taskId,
    required double latitude,
    required double longitude,
    required String filePath,
  }) async {
    final response = await _apiClient.uploadImageMultipartGet(
      '/upload-image/',
      filePath: filePath,
      fileKey: 'image',
      queryParams: {
        'task_id': taskId,
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
      },
    );
    if (response is Map<String, dynamic>) {
      return response;
    }
    throw const ServerFailure('Invalid server response during image upload');
  }

  /// Submits the final activity record to the backend POST endpoint.
  Future<Map<String, dynamic>> submitActivityRecord(
    Map<String, dynamic> body,
  ) async {
    final token = _localStorage.getToken() ?? '';
    final response = await _apiClient.post(
      '/activity-record/',
      body: body,
      headers: {'accesstoken': token},
    );
    if (response is Map<String, dynamic>) {
      return response;
    }
    throw const ServerFailure(
      'Invalid server response during activity submission',
    );
  }

  /// Updates an existing activity record via PUT endpoint.
  Future<Map<String, dynamic>> updateActivityRecord(
    int activityId,
    Map<String, dynamic> body,
  ) async {
    final token = _localStorage.getToken() ?? '';
    final response = await _apiClient.put(
      '/activity-record/$activityId/',
      body: body,
      headers: {'accesstoken': token},
    );
    if (response is Map<String, dynamic>) {
      return response;
    }
    throw const ServerFailure('Invalid server response during activity update');
  }

  /// Deletes an activity record via DELETE endpoint.
  Future<void> deleteActivityRecord(int activityId) async {
    final token = _localStorage.getToken() ?? '';
    await _apiClient.delete(
      '/activity-record/$activityId/',
      headers: {'accesstoken': token},
    );
  }
}
