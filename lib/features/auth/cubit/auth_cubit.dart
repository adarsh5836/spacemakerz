import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/models/user_model.dart';
import '../../../app/repositories/auth_repository.dart';

// ─── STATES ───────────────────────────────────────────────────────────────────

abstract class AuthState extends Equatable {
  const AuthState();
  @override List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  final bool obscurePassword;
  const AuthInitial({this.obscurePassword = true});
  @override List<Object?> get props => [obscurePassword];
}

class AuthLoading extends AuthState {
  final bool obscurePassword;
  const AuthLoading({this.obscurePassword = true});
  @override List<Object?> get props => [obscurePassword];
}

class AuthSuccess extends AuthState {
  final UserModel user;
  const AuthSuccess(this.user);
  @override List<Object?> get props => [user];
}

class AuthFailure extends AuthState {
  final String message;
  final bool obscurePassword;
  const AuthFailure(this.message, {this.obscurePassword = true});
  @override List<Object?> get props => [message, obscurePassword];
}

// ─── CUBIT ────────────────────────────────────────────────────────────────────

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(const AuthInitial());

  bool get _obscure {
    final s = state;
    if (s is AuthInitial) return s.obscurePassword;
    if (s is AuthLoading) return s.obscurePassword;
    if (s is AuthFailure) return s.obscurePassword;
    return true;
  }

  void togglePasswordVisibility() {
    final s = state;
    if (s is AuthInitial) emit(AuthInitial(obscurePassword: !s.obscurePassword));
    if (s is AuthFailure) emit(AuthFailure(s.message, obscurePassword: !s.obscurePassword));
  }

  Future<void> login(String mobileNo, String password) async {
    emit(AuthLoading(obscurePassword: _obscure));
    try {
      final user = await _repository.login(mobileNo.trim(), password.trim());
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthFailure(e.toString().replaceFirst('Exception: ', ''),
          obscurePassword: _obscure));
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    emit(const AuthInitial());
  }
}
