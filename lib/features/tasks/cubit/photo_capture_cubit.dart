import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/repositories/tasks_repository.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/storage/local_storage.dart';
import '../../../app/models/task_model.dart';
import '../../../app/models/activity_record_model.dart';
import 'photo_capture_state.dart';

class PhotoCaptureCubit extends Cubit<PhotoCaptureState> {
  final TasksRepository _repo;
  final LocalStorage _localStorage;

  PhotoCaptureCubit({
    required TasksRepository repo,
    required LocalStorage localStorage,
  }) : _repo = repo,
       _localStorage = localStorage,
       super(const PhotoCaptureState());

  /// Upload photo using repository
  Future<void> uploadPhoto({
    required String taskId,
    required double latitude,
    required double longitude,
    required String filePath,
  }) async {
    emit(
      state.copyWith(
        isUploading: true,
        errorMessage: null,
        successMessage: null,
      ),
    );
    try {
      final response = await _repo.uploadActivityPhoto(
        taskId: taskId,
        latitude: latitude,
        longitude: longitude,
        filePath: filePath,
      );

      if (response['status'] == true) {
        final url = response['image_url'] as String;
        final updatedUrls = List<String>.from(state.uploadedUrls)..add(url);
        emit(
          state.copyWith(
            uploadedUrls: updatedUrls,
            isUploading: false,
            successMessage: 'Photo uploaded successfully!',
          ),
        );
      } else {
        emit(
          state.copyWith(
            isUploading: false,
            errorMessage: response['message'] ?? 'Failed to upload photo',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isUploading: false,
          errorMessage: 'Error uploading photo: $e',
        ),
      );
    }
  }

  /// Remove photo from local state list
  void removePhoto(int index) {
    final updatedUrls = List<String>.from(state.uploadedUrls);
    if (index >= 0 && index < updatedUrls.length) {
      updatedUrls.removeAt(index);
      emit(
        state.copyWith(
          uploadedUrls: updatedUrls,
          errorMessage: null,
          successMessage: null,
        ),
      );
    }
  }

  double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371000.0; // Earth radius metres
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLon = (lon2 - lon1) * math.pi / 180;
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) *
            math.cos(lat2 * math.pi / 180) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  /// Submit final activity record
  Future<void> submitActivity({
    required TaskModel task,
    required double latitude,
    required double longitude,
    required String? address,
    required String remark,
    required String remark1,
    required String district,
    required String tehsil,
    required String village,
    required List<ActivityRecordModel> activities,
  }) async {
    if (district.trim().isEmpty) {
      emit(state.copyWith(errorMessage: 'Please enter District.'));
      return;
    }
    if (tehsil.trim().isEmpty) {
      emit(state.copyWith(errorMessage: 'Please enter Tehsil.'));
      return;
    }
    if (village.trim().isEmpty) {
      emit(state.copyWith(errorMessage: 'Please enter Village.'));
      return;
    }
    if (remark.trim().isEmpty) {
      emit(state.copyWith(errorMessage: 'Please enter Remark.'));
      return;
    }

    if (state.uploadedUrls.length < 3) {
      emit(
        state.copyWith(
          errorMessage: 'Please capture at least 3 photos before submitting.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isSubmitting: true,
        errorMessage: null,
        successMessage: null,
      ),
    );

    try {
      final currentUserId =
          int.tryParse(_localStorage.currentUser?.id.toString() ?? '0') ?? 0;
      final role = _localStorage.currentRole;
      final isUser = role == UserRole.user;
      final isDealer = role == UserRole.dealer;

      final finalEmpId = isUser ? currentUserId : 0;
      final finalDealerId = isDealer ? currentUserId : 0;

      final projectId = int.tryParse(task.projectIdStr) ?? 1;
      final taskIdInt = int.tryParse(task.id) ?? 1;

      final latStr = latitude.toStringAsFixed(4);
      final lngStr = longitude.toStringAsFixed(4);

      String distanceStr = "0.0 KM";
      if (activities.isNotEmpty) {
        final lastAct = activities.last;
        final actLat = double.tryParse(lastAct.latitude ?? '');
        final actLng = double.tryParse(lastAct.longitude ?? '');
        if (actLat != null && actLng != null) {
          final distMetres = _haversine(actLat, actLng, latitude, longitude);
          distanceStr = "${(distMetres / 1000.0).toStringAsFixed(2)} KM";
        }
      }

      final body = {
        "sync_id": DateTime.now().millisecondsSinceEpoch ~/ 1000,
        "activity_ref_no": "ACT${DateTime.now().millisecondsSinceEpoch}",
        "emp_id": finalEmpId,
        "dealer_id": finalDealerId,
        "project_id": projectId,
        "flex_id": taskIdInt,
        "task_id": taskIdInt,
        "flex_size": task.sizeOfFlex.isNotEmpty ? task.sizeOfFlex : "10x20 ft",
        "task_sno": 1,
        "photo": state.uploadedUrls.toString(),
        "latitude": latStr,
        "longitude": lngStr,
        "gps_address": address ?? "-",
        "remark": remark,
        "remark1": remark1,
        "district": district,
        "tehsil": tehsil,
        "village": village,
        "view_id": 1,
        "distance_from_last": distanceStr,
        "status": 1,
        "dealer_info": "[]",
        // "timestaps": DateTime.now().millisecondsSinceEpoch ~/ 1000,
      };
      final response = await _repo.submitActivityRecord(body);

      if (response['status'] == true) {
        emit(
          state.copyWith(
            isSubmitting: false,
            submitSuccess: true,
            successMessage: 'Activity record submitted successfully!',
          ),
        );
      } else {
        print("@@@@@@@@@@@${response}");
        emit(
          state.copyWith(
            isSubmitting: false,
            errorMessage:
                'Submission failed: ${response['message'] ?? "Unknown error"}',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: 'Error submitting activity: $e',
        ),
      );
    }
  }
}
