import '../../core/enums/app_enums.dart';

class StateModel {
  final int id;
  final String name;
  final String code;
  final int countryId;
  final int status;
  final String createdDate;
  final String updatedDate;

  const StateModel({
    required this.id,
    required this.name,
    required this.code,
    required this.countryId,
    required this.status,
    required this.createdDate,
    required this.updatedDate,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) => StateModel(
    id: json['id'] as int? ?? 0,
    name: json['name'] as String? ?? '',
    code: json['code'] as String? ?? '',
    countryId: json['country_id'] as int? ?? 1,
    status: json['status'] as int? ?? 1,
    createdDate: json['created_date'] as String? ?? '',
    updatedDate: json['updated_date'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'code': code,
    'country_id': countryId,
    'status': status,
    'created_date': createdDate,
    'updated_date': updatedDate,
  };
}

class CityModel {
  final int id;
  final String name;
  final String code;
  final int stateId;
  final int status;
  final String createdDate;
  final String updatedDate;

  const CityModel({
    required this.id,
    required this.name,
    required this.code,
    required this.stateId,
    required this.status,
    required this.createdDate,
    required this.updatedDate,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) => CityModel(
    id: json['id'] as int? ?? 0,
    name: json['name'] as String? ?? '',
    code: json['code'] as String? ?? '',
    stateId: json['state_id'] as int? ?? 0,
    status: json['status'] as int? ?? 1,
    createdDate: json['created_date'] as String? ?? '',
    updatedDate: json['updated_date'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'code': code,
    'state_id': stateId,
    'status': status,
    'created_date': createdDate,
    'updated_date': updatedDate,
  };
}

class UserModel {
  final int id;
  final StateModel? state;
  final CityModel? city;
  final String profileCode;
  final String name;
  final String contactPerson;
  final String mobileNo;
  final String address;
  final String profileImage;
  final String password;
  final String roleType;
  final String joiningDate;
  final int onlineStatus;
  final String workingHrs;
  final int isOvertimeAllowed;
  final int status;
  final String updatedDate;
  final String createdDate;

  const UserModel({
    required this.id,
    this.state,
    this.city,
    required this.profileCode,
    required this.name,
    required this.contactPerson,
    required this.mobileNo,
    required this.address,
    required this.profileImage,
    required this.password,
    required this.roleType,
    required this.joiningDate,
    required this.onlineStatus,
    required this.workingHrs,
    required this.isOvertimeAllowed,
    required this.status,
    required this.updatedDate,
    required this.createdDate,
  });

  // Helper to map roleType (int) to application's local UserRole enum
  UserRole get role {
    switch (roleType) {
      case "Manager":
        return UserRole.manager;
      case "Dealer":
        return UserRole.dealer;
      default:
        return UserRole.user;
    }
  }

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as int? ?? 0,
    state: json['state'] != null && json['state'] is Map
        ? StateModel.fromJson(json['state'] as Map<String, dynamic>)
        : null,
    city: json['city'] != null
        ? (json['city'] is Map
            ? CityModel.fromJson(json['city'] as Map<String, dynamic>)
            : (json['city'] is String
                ? CityModel(
                    id: 0,
                    name: json['city'] as String,
                    code: '',
                    stateId: 0,
                    status: 1,
                    createdDate: '',
                    updatedDate: '',
                  )
                : null))
        : null,
    profileCode: json['profile_code'] as String? ?? '',
    name: json['name'] as String? ?? '',
    contactPerson: json['contact_person'] as String? ?? '',
    mobileNo: json['mobile_no'] as String? ?? '',
    address: json['address'] as String? ?? '',
    profileImage: json['profile_image'] as String? ?? '',
    password: json['password'] as String? ?? '',
    roleType: json['role_type'] as String? ?? "",
    joiningDate: json['joining_date'] as String? ?? '',
    onlineStatus: json['online_status'] as int? ?? 1,
    workingHrs: json['working_hrs'] as String? ?? '',
    isOvertimeAllowed: json['is_overtime_allowed'] as int? ?? 1,
    status: json['status'] as int? ?? 1,
    updatedDate:
        json['updated_date'] as String? ?? json['updated_at'] as String? ?? '',
    createdDate:
        json['created_date'] as String? ?? json['created_at'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'state': state?.toJson(),
    'city': city?.toJson(),
    'profile_code': profileCode,
    'name': name,
    'contact_person': contactPerson,
    'mobile_no': mobileNo,
    'address': address,
    'profile_image': profileImage,
    'password': password,
    'role_type': roleType,
    'joining_date': joiningDate,
    'online_status': onlineStatus,
    'working_hrs': workingHrs,
    'is_overtime_allowed': isOvertimeAllowed,
    'status': status,
    'updated_date': updatedDate,
    'created_date': createdDate,
  };
}
