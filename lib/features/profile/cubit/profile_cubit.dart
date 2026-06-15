import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/repositories/auth_repository.dart';
import '../../../core/storage/local_storage.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final AuthRepository _authRepo;
  final LocalStorage _localStorage;

  ProfileCubit(this._authRepo, this._localStorage) : super(const ProfileInitial());

  Future<void> loadProfile() async {
    emit(const ProfileLoading());
    try {
      final userId = _localStorage.currentUserId;
      if (userId == null) {
        emit(const ProfileError('User session not found. Please log in again.'));
        return;
      }
      final user = await _authRepo.fetchUserProfile(userId);
      emit(ProfileLoaded(user));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
