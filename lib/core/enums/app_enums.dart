// All app-wide enums. Add new values here as the app grows.
enum UserRole {
  superAdmin,
  manager,
  dealer,
  user;

  String get displayName {
    switch (this) {
      case UserRole.superAdmin: return 'Super Admin';
      case UserRole.manager:    return 'Manager';
      case UserRole.dealer:     return 'Dealer';
      case UserRole.user:       return 'User';
    }
  }

  static UserRole fromJson(String v) =>
      UserRole.values.firstWhere((e) => e.name == v, orElse: () => UserRole.user);
}

enum TaskStatus {
  pending,
  inProgress,
  completed,
  rejected;

  String get displayName {
    switch (this) {
      case TaskStatus.pending:    return 'Pending';
      case TaskStatus.inProgress: return 'In Progress';
      case TaskStatus.completed:  return 'Completed';
      case TaskStatus.rejected:   return 'Rejected';
    }
  }

  String get jsonValue {
    switch (this) {
      case TaskStatus.pending:    return 'pending';
      case TaskStatus.inProgress: return 'in_progress';
      case TaskStatus.completed:  return 'completed';
      case TaskStatus.rejected:   return 'rejected';
    }
  }

  static TaskStatus fromJson(dynamic v) {
    if (v == null) return TaskStatus.pending;
    final s = v.toString().trim().toLowerCase();
    switch (s) {
      case '2':
      case 'in_progress':
      case 'inprogress':
        return TaskStatus.inProgress;
      case '3':
      case 'completed':
        return TaskStatus.completed;
      case '4':
      case 'rejected':
        return TaskStatus.rejected;
      case '1':
      case 'pending':
      default:
        return TaskStatus.pending;
    }
  }

  /// Tasks can be edited only when pending or in-progress
  bool get isEditable =>
      this == TaskStatus.pending || this == TaskStatus.inProgress;
}

enum SiteType {
  fieldOffice,
  constructionSite;

  String get displayName {
    switch (this) {
      case SiteType.fieldOffice:       return 'Field Office';
      case SiteType.constructionSite:  return 'Construction Site';
    }
  }

  String get jsonValue {
    switch (this) {
      case SiteType.fieldOffice:      return 'field_office';
      case SiteType.constructionSite: return 'construction_site';
    }
  }

  static SiteType fromJson(String v) =>
      v == 'construction_site' ? SiteType.constructionSite : SiteType.fieldOffice;
}

enum ProjectStatus {
  active,
  completed,
  onHold,
  cancelled;

  String get displayName {
    switch (this) {
      case ProjectStatus.active:     return 'Active';
      case ProjectStatus.completed:  return 'Completed';
      case ProjectStatus.onHold:     return 'On Hold';
      case ProjectStatus.cancelled:  return 'Cancelled';
    }
  }

  String get jsonValue {
    switch (this) {
      case ProjectStatus.active:     return 'active';
      case ProjectStatus.completed:  return 'completed';
      case ProjectStatus.onHold:     return 'on_hold';
      case ProjectStatus.cancelled:  return 'cancelled';
    }
  }

  static ProjectStatus fromJson(String v) {
    switch (v) {
      case 'completed':  return ProjectStatus.completed;
      case 'on_hold':    return ProjectStatus.onHold;
      case 'cancelled':  return ProjectStatus.cancelled;
      default:           return ProjectStatus.active;
    }
  }
}

enum ProjectPriority {
  low,
  medium,
  high,
  critical;

  static ProjectPriority fromJson(String v) =>
      ProjectPriority.values.firstWhere((e) => e.name == v,
          orElse: () => ProjectPriority.medium);
}
