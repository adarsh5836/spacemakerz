import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../enums/app_enums.dart';
import '../../app/models/user_model.dart';

class LocalStorage {
  final SharedPreferences _prefs;

  LocalStorage(this._prefs);

  static const String _tokenKey = 'auth_token';
  static const String _userProfileKey = 'user_profile';
  static const String _userIdKey = 'user_id';
  static const String _userRoleKey = 'user_role';

  // Save user profile details
  Future<bool> saveUserProfile(Map<String, dynamic> userData) async {
    final jsonStr = jsonEncode(userData);
    await _prefs.setInt(_userIdKey, userData['id'] as int? ?? 0);
    await _prefs.setString(
      _userRoleKey,
      (userData['role_type'] ?? 3).toString(),
    );
    return await _prefs.setString(_userProfileKey, jsonStr);
  }

  // Get user profile details
  Map<String, dynamic>? getUserProfile() {
    final jsonStr = _prefs.getString(_userProfileKey);
    if (jsonStr == null) return null;
    try {
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // Clear user profile
  Future<bool> clearUserProfile() async {
    await _prefs.remove(_userIdKey);
    await _prefs.remove(_userRoleKey);
    return await _prefs.remove(_userProfileKey);
  }

  // Save Token
  Future<bool> saveToken(String token) async {
    return await _prefs.setString(_tokenKey, token);
  }

  // Get Token
  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  // Remove Token
  Future<bool> removeToken() async {
    return await _prefs.remove(_tokenKey);
  }

  // Clear all data
  Future<bool> clearAll() async {
    await clearUserProfile();
    return await _prefs.clear();
  }

  // ─── UNIFIED SESSION GETTERS ──────────────────────────────────────────────

  UserModel? get currentUser {
    final data = getUserProfile();
    if (data == null) return null;
    try {
      return UserModel.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  bool get isLoggedIn => getUserProfile() != null;

  String? get currentUserId => currentUser?.id.toString();

  String? get currentUserName => currentUser?.name;

  UserRole get currentRole {
    final roleType = currentUser?.roleType ?? 3;
    if (roleType.toString().toLowerCase() == "manager" || roleType == 1)
      return UserRole.manager;
    if (roleType.toString().toLowerCase() == "dealer" || roleType == 2)
      return UserRole.dealer;
    return UserRole.user;
  }

  String? get currentState => currentUser?.state?.name;

  String? get currentCity => currentUser?.city?.name;

  String? get currentMobile => currentUser?.mobileNo;

  String? get currentDealerId =>
      currentRole == UserRole.dealer ? currentUserId : null;

  String? get currentManagerId =>
      currentRole == UserRole.manager ? currentUserId : null;
}
