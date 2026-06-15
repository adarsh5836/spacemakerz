import '../../core/enums/app_enums.dart';
import 'user_model.dart';

class ProjectModel {
  final int id;
  final UserModel? manager;
  final String title;
  final String startDate;
  final String endDate;
  final String description;
  final int statusCode; // Standard backend status integer
  final String createdAt;
  final String updatedAt;

  const ProjectModel({
    required this.id,
    this.manager,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.statusCode,
    required this.createdAt,
    required this.updatedAt,
  });

  // ─── COMPATIBILITY GETTERS FOR EXISTING UI ──────────────────────────────

  String get projectName => title;

  String get projectCode => 'PRJ-${id.toString().padLeft(3, '0')}';

  String get city => manager?.city?.name ?? '-';

  String get state => manager?.state?.name ?? '-';

  ProjectStatus get status {
    switch (statusCode) {
      case 1:
        return ProjectStatus.active;
      case 2:
        return ProjectStatus.completed;
      case 3:
        return ProjectStatus.onHold;
      default:
        return ProjectStatus.active;
    }
  }

  ProjectPriority get priority => ProjectPriority.medium;

  String get managerId => (manager?.id ?? '').toString();

  // ────────────────────────────────────────────────────────────────────────────

  factory ProjectModel.fromJson(Map<String, dynamic> j) => ProjectModel(
    id: j['id'] as int? ?? 0,
    manager: j['manager_id'] != null && j['manager_id'] is Map
        ? UserModel.fromJson(j['manager_id'] as Map<String, dynamic>)
        : null,
    title: j['title'] as String? ?? '',
    startDate: j['start_date'] as String? ?? '',
    endDate: j['end_date'] as String? ?? '',
    description: j['description'] as String? ?? '',
    statusCode: j['status'] as int? ?? 1,
    createdAt: j['created_at'] as String? ?? j['created_date'] as String? ?? '',
    updatedAt: j['updated_at'] as String? ?? j['updated_date'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'manager_id': manager?.toJson(),
    'title': title,
    'start_date': startDate,
    'end_date': endDate,
    'description': description,
    'status': statusCode,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}
