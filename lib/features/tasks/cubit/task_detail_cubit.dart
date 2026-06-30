import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/models/activity_record_model.dart';
import '../../../app/repositories/tasks_repository.dart';
import '../../../core/enums/app_enums.dart';
import 'task_detail_state.dart';

/// Range in metres – photo can be taken only from this far away from the
/// previous capture point (or any location for the very first photo).
const double _kRangeMetres = 100.0;

class TaskDetailCubit extends Cubit<TaskDetailState> {
  final TasksRepository _repo;
  final ImagePicker _picker = ImagePicker();
  StreamSubscription<Position>? _locationSub;

  TaskDetailCubit(this._repo) : super(const TaskDetailInitial());

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> loadTask(String taskId) async {
    emit(const TaskDetailLoading());
    try {
      final task = await _repo.getTaskById(taskId);
      if (isClosed) return;
      if (task == null) {
        emit(const TaskDetailError('Task not found.'));
        return;
      }
      final photos = await _repo.getPhotos(taskId);
      final activities = await _repo.getActivityRecords(taskId);
      if (isClosed) return;
      final loaded = TaskDetailLoaded(
        task: task,
        photos: photos,
        activities: activities,
        canUpload: _repo.canUploadPhoto(task),
        canChangeStatus: _repo.canChangeStatus(task),
        readyToCapture: false, // Wait for actual live location
        currentLat: null,
        currentLng: null,
        currentAddress: null,
      );
      emit(loaded);
      _startLocationTracking();
    } catch (e) {
      emit(TaskDetailError(e.toString()));
    }
  }

  // ── Location tracking ──────────────────────────────────────────────────────

  void _startLocationTracking() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) return;

      // Fetch initial position to display immediately
      final initialPos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (isClosed) return;
      _onPosition(initialPos);

      const settings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // emit every 5 m of movement
      );

      _locationSub = Geolocator.getPositionStream(
        locationSettings: settings,
      ).listen(_onPosition);
    } catch (_) {
      // location unavailable – silently ignore
    }
  }

  void _onPosition(Position pos) async {
    final s = state;
    if (s is! TaskDetailLoaded) return;

    final distance = _distanceFromLastPhoto(
      s.activities,
      pos.latitude,
      pos.longitude,
    );
    final range = s.task.rangeInMeter ?? _kRangeMetres;
    final ready =
        s.activities.isEmpty || (distance != null && distance >= range);

    String? address = s.currentAddress;

    // Resolve address if it's the first time or if the user moved significantly
    // To minimize API calls, we'll just resolve it once for simplicity, or
    // when location changes a lot. We'll resolve it every time here but in production
    // it should be throttled.
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );
      if (isClosed) return;
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        address = [
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.postalCode,
          place.country,
        ].where((e) => e != null && e.isNotEmpty).join(', ');
      }
    } catch (_) {
      // ignore geocoding errors
    }

    if (isClosed) return;
    emit(
      s.copyWith(
        currentLat: pos.latitude,
        currentLng: pos.longitude,
        currentAddress: address ?? s.currentAddress,
        distanceFromLastPhoto: distance,
        readyToCapture: ready,
      ),
    );
  }

  /// Haversine distance (metres) from the last photo's stored GPS tag.
  /// Returns null when last photo has no location data (treat as ready).
  double? _distanceFromLastPhoto(
    List<ActivityRecordModel> activities,
    double lat,
    double lng,
  ) {
    final s = state;
    if (s is! TaskDetailLoaded) return null;

    if (activities.isNotEmpty) {
      final lastAct = activities.last;
      final actLat = double.tryParse(lastAct.latitude ?? '');
      final actLng = double.tryParse(lastAct.longitude ?? '');
      if (actLat != null && actLng != null) {
        return _haversine(actLat, actLng, lat, lng);
      }
    }

    final task = s.task;
    if (task.latitude == null || task.longitude == null) return null;

    return _haversine(task.latitude!, task.longitude!, lat, lng);
  }

  double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371000.0; // Earth radius metres
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  double _toRad(double deg) => deg * math.pi / 180;

  // ── Camera ────────────────────────────────────────────────────────────────

  /// Opens CAMERA only (gallery removed per new spec).
  Future<void> uploadPhoto(String taskId, {String? activityId}) async {
    final s = state;
    if (s is! TaskDetailLoaded) return;

    emit(TaskDetailUpdating(s.task, s.photos));

    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1200,
      );
      if (isClosed) return;
      if (picked == null) {
        emit(s);
        return;
      } // user cancelled

      final photo = await _repo.addPhoto(
        taskId: taskId,
        localPath: picked.path,
        activityId: activityId,
        latitude: s.currentLat,
        longitude: s.currentLng,
        address: s.currentAddress,
      );
      if (isClosed) return;
      final photos = [...s.photos, photo];

      // After capturing, reset distance so next photo needs another 100 m
      emit(
        s.copyWith(
          photos: photos,
          readyToCapture: false,
          distanceFromLastPhoto: 0,
        ),
      );
    } catch (e) {
      emit(TaskDetailError(e.toString()));
    }
  }

  // ── Delete photo ──────────────────────────────────────────────────────────

  Future<void> deletePhoto(String photoId) async {
    final s = state;
    if (s is! TaskDetailLoaded) return;

    emit(TaskDetailUpdating(s.task, s.photos));
    final success = await _repo.deletePhoto(photoId);
    if (isClosed) return;
    if (success) {
      final photos = s.photos.where((p) => p.id != photoId).toList();
      emit(s.copyWith(photos: photos));
    } else {
      emit(s);
    }
  }

  // ── Status ────────────────────────────────────────────────────────────────

  Future<void> updateStatus(String taskId, TaskStatus status) async {
    final s = state;
    if (s is! TaskDetailLoaded) return;

    try {
      await _repo.updateStatus(taskId, status);

      // Update backend status for each activity record associated with the task
      final statusInt = status == TaskStatus.completed ? 3 : 4;
      for (final act in s.activities) {
        await _repo.updateActivityRecord(act.id, {"status": statusInt});
      }

      final newActivities = await _repo.getActivityRecords(s.task.id);

      if (isClosed) return;
      final updated = s.task.copyWith(
        status: status,
        updatedAt: DateTime.now().toIso8601String(),
      );
      emit(
        TaskDetailLoaded(
          task: updated,
          photos: s.photos,
          activities: newActivities,
          canUpload: _repo.canUploadPhoto(updated),
          canChangeStatus: _repo.canChangeStatus(updated),
          currentLat: s.currentLat,
          currentLng: s.currentLng,
        ),
      );
    } catch (e) {
      emit(TaskDetailError(e.toString()));
    }
  }

  // ── Delete Activity Record ──────────────────────────────────────────────────

  Future<bool> deleteActivity(int activityId) async {
    final s = state;
    if (s is! TaskDetailLoaded) return false;
    try {
      await _repo.deleteActivityRecord(activityId);
      final newActivities = await _repo.getActivityRecords(s.task.id);
      if (isClosed) return true;
      emit(s.copyWith(activities: newActivities));
      return true;
    } catch (e) {
      print("Error deleting activity: $e");
      return false;
    }
  }

  // ── Add Photo to Existing Activity ─────────────────────────────────────────

  Future<String?> addPhotoToActivity(ActivityRecordModel activity) async {
    final s = state;
    if (s is! TaskDetailLoaded) return null;
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1200,
      );
      if (picked == null) return null;

      final lat =
          s.currentLat ?? double.tryParse(activity.latitude ?? '') ?? 28.6139;
      final lng =
          s.currentLng ?? double.tryParse(activity.longitude ?? '') ?? 77.2090;

      final response = await _repo.uploadActivityPhoto(
        taskId: s.task.id,
        latitude: lat,
        longitude: lng,
        filePath: picked.path,
      );

      if (response['status'] == true) {
        final newImageUrl = response['image_url'] as String;
        final updatedPhotos = List<String>.from(activity.photos)
          ..add(newImageUrl);

        final body = {
          // "sync_id": activity.syncId,
          // "activity_ref_no": activity.activityRefNo,
          // "emp_id": activity.empId,
          // "project_id": activity.projectId,
          // "dealer_id": activity.dealerId,
          // "flex_id": activity.flexId,
          // "task_id": int.tryParse(s.task.id) ?? activity.taskId,
          // "flex_size": activity.flexSize,
          // "task_sno": activity.taskSno,
          "photo": updatedPhotos.toString(),
          "latitude": activity.latitude,
          "longitude": activity.longitude,
          "gps_address": activity.gpsAddress,
          // "remark": activity.remark,
          // "remark1": activity.remark1,
          // "view_id": activity.viewId,
          // "distance_from_last": activity.distanceFromLast,
          // "status": activity.status,
        };

        await _repo.updateActivityRecord(activity.id, body);

        // Reload activity list
        final newActivities = await _repo.getActivityRecords(s.task.id);
        if (isClosed) return newImageUrl;
        emit(s.copyWith(activities: newActivities));
        return newImageUrl;
      }
      return null;
    } catch (e) {
      print("Error adding photo to activity: $e");
      return null;
    }
  }

  Future<bool> submitDealerRecce({
    required ActivityRecordModel activity,
    required int month,
    required String photoUrl,
    required String remark,
    required String status,
  }) async {
    final s = state;
    if (s is! TaskDetailLoaded) return false;
    try {
      final currentList = List<Map<String, dynamic>>.from(
        activity.parsedDealerInfo,
      );

      final newItem = {
        'month': month,
        'photo_url': photoUrl,
        'remark': remark,
        'date': DateTime.now().toIso8601String(),
        'status': status,
      };

      final index = currentList.indexWhere((item) => item['month'] == month);
      if (index != -1) {
        currentList[index] = newItem;
      } else {
        currentList.add(newItem);
      }

      final dealerInfoStr = jsonEncode(currentList);

      final body = {
        "dealer_info": dealerInfoStr,
        "photo": activity.photos.toString(),
        "latitude": activity.latitude,
        "longitude": activity.longitude,
        "gps_address": activity.gpsAddress,
      };

      await _repo.updateActivityRecord(activity.id, body);

      await loadTask(s.task.id);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> close() {
    _locationSub?.cancel();
    return super.close();
  }
}
