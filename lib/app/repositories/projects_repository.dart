import '../../core/api/api_client.dart';
import '../../core/storage/local_storage.dart';
import '../models/project_model.dart';

class ProjectsRepository {
  final ApiClient _apiClient;
  final LocalStorage _localStorage;

  ProjectsRepository(this._apiClient, this._localStorage);

  /// Returns projects filtered by the current user's manager ID.
  Future<List<ProjectModel>> getProjects() async {
    final managerId = _localStorage.currentUserId ?? '';
    
    // Call GET API: /project-master/?manager_id=<manager_id>
    final response = await _apiClient.get('/project-master/?manager_id=$managerId');

    if (response == null || response is! Map) {
      throw Exception('Failed to load projects from server.');
    }

    final dynamic status = response['status'];
    if (status == 0 || status == false) {
      final errorMsg = response['message'] as String? ?? 'Failed to load projects';
      throw Exception(errorMsg);
    }

    final dynamic data = response['data'];
    if (data is! List) {
      return [];
    }

    return data
        .map<ProjectModel>((item) => ProjectModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Returns a single project by [id].
  Future<ProjectModel?> getProjectById(String id) async {
    final all = await getProjects();
    try {
      return all.firstWhere((p) => p.id.toString() == id);
    } catch (_) {
      return null;
    }
  }
}
