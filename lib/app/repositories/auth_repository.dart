import '../../core/api/api_client.dart';
import '../../core/storage/local_storage.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final LocalStorage _localStorage;

  AuthRepository(this._apiClient, this._localStorage);

  /// Authenticates using the backend API endpoint.
  /// Saves raw response data to LocalStorage on success.
  /// Returns the logged-in [UserModel].
  Future<UserModel> login(String mobileNo, String password) async {
    final response = await _apiClient.post(
      '/login/',
      body: {'mobile_no': mobileNo, 'password': password},
    );

    if (response == null || response is! Map) {
      throw Exception('Invalid response received from authentication server.');
    }

    final dynamic status = response['status'];
    if (status == 0 || status == false) {
      final errorMsg =
          response['message'] as String? ?? 'Invalid mobile number or password';
      throw Exception(errorMsg);
    }

    if (!response.containsKey('data')) {
      throw Exception('Invalid response received from authentication server.');
    }

    final userData = response['data'] as Map<String, dynamic>;
    final user = UserModel.fromJson(userData);

    // Save to LocalStorage (saves profile, id, role_type etc. inside preferences)
    await _localStorage.saveUserProfile(userData);

    // Save token if available in the response
    if (userData.containsKey('token')) {
      await _localStorage.saveToken(userData['token'].toString());
    }

    return user;
  }

  Future<UserModel> fetchUserProfile(String userId) async {
    final token = _localStorage.getToken() ?? '';
    final response = await _apiClient.get(
      '/app-users/$userId/',
      headers: {
        if (token.isNotEmpty) 'accesstoken': token,
      },
    );

    if (response != null && response is Map<String, dynamic>) {
      if (response['status'] == true && response['data'] != null) {
        final userData = response['data'] as Map<String, dynamic>;
        await _localStorage.saveUserProfile(userData);
        return UserModel.fromJson(userData);
      }
    }
    throw Exception('Failed to fetch user profile.');
  }

  Future<void> logout() async {
    await _localStorage.clearUserProfile();
    await _localStorage.removeToken();
  }

  bool get isLoggedIn => _localStorage.isLoggedIn;
}
