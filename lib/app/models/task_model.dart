import '../../core/enums/app_enums.dart';
import 'project_model.dart';
import 'user_model.dart';

class TaskModel {
  final String id;
  final String taskTitle;
  final ProjectModel? projectId;
  final String date;
  final String utcDate;
  final int nds;
  final UserModel? dealerName;
  final String address;
  final StateModel? state;
  final CityModel? city;
  final String district;
  final TaskStatus status;
  final SiteType siteType;
  final double? latitude;
  final double? longitude;
  final String taskCode;
  final String managerId;
  final String? userId;
  final String? dealerId;
  final String? remarks;
  final String? installationLocation;
  final double? rangeInMeter;
  final String createdAt;
  final String updatedAt;

  // Nullable/Dynamic API fields
  final UserModel? empId;
  final UserModel? clientId;

  // New API fields for extra details
  final String tehsil;
  final String locationType;
  final int noOfFlex;
  final String sizeOfFlex;
  final String remark;

  const TaskModel({
    required this.id,
    required this.taskTitle,
    this.projectId,
    required this.date,
    required this.utcDate,
    required this.nds,
    this.dealerName,
    required this.address,
    this.state,
    this.city,
    required this.district,
    required this.status,
    required this.siteType,
    this.latitude,
    this.longitude,
    required this.taskCode,
    required this.managerId,
    this.userId,
    this.dealerId,
    this.remarks,
    this.installationLocation,
    this.rangeInMeter,
    required this.createdAt,
    required this.updatedAt,
    this.empId,
    this.clientId,
    this.tehsil = '',
    this.locationType = '',
    this.noOfFlex = 0,
    this.sizeOfFlex = '',
    this.remark = '',
  });

  /// Getter to provide a safe, non-null String fallback for dealer name in UI widgets
  String get displayDealerName {
    if (dealerName == null) return '-';
    return dealerName!.name.isNotEmpty
        ? dealerName!.name
        : (dealerName!.profileCode.isNotEmpty ? dealerName!.profileCode : '-');
  }

  /// Helper getters for state and city names
  String get stateName => state?.name ?? '';
  String get cityName => city?.name ?? '';

  /// Backward-compatibility getter for when code expects projectId as String
  String get projectIdStr => projectId?.id.toString() ?? '';

  factory TaskModel.fromJson(Map<String, dynamic> j) {
    // Safely extract project details into ProjectModel
    ProjectModel? parsedProject;
    String extractedManagerId = '';

    if (j['project_id'] is Map) {
      parsedProject = ProjectModel.fromJson(
        j['project_id'] as Map<String, dynamic>,
      );
      extractedManagerId = parsedProject.managerId;
    } else if (j['project_id'] != null) {
      final idVal = int.tryParse(j['project_id'].toString()) ?? 0;
      parsedProject = ProjectModel(
        id: idVal,
        title: 'Project $idVal',
        startDate: '',
        endDate: '',
        description: '',
        statusCode: 1,
        createdAt: '',
        updatedAt: '',
      );
    }

    // Parse status safely using the enhanced dynamic fromJson
    final taskStatusValue = j['task_status'] ?? j['status'];
    final parsedStatus = TaskStatus.fromJson(taskStatusValue);

    // Site Type fallback
    final siteTypeValue = j['location_type'] ?? j['site_type'] ?? '';
    final parsedSiteType = SiteType.fromJson(siteTypeValue.toString());

    // NDS/No of flex
    final ndsVal = j['no_of_flex'] ?? j['nds'] ?? 0;
    final int parsedNds = ndsVal is int
        ? ndsVal
        : (int.tryParse(ndsVal.toString()) ?? 0);

    // Range
    final rangeVal = j['range_in_meter'] ?? j['flex_range'];
    final double? parsedRange = rangeVal != null
        ? (double.tryParse(rangeVal.toString()))
        : null;

    // Parse State safely
    StateModel? parsedState;
    if (j['state'] != null) {
      if (j['state'] is Map) {
        parsedState = StateModel.fromJson(j['state'] as Map<String, dynamic>);
      } else if (j['state'] is String && (j['state'] as String).isNotEmpty) {
        parsedState = StateModel(
          id: 0,
          name: j['state'] as String,
          code: '',
          countryId: 1,
          status: 1,
          createdDate: '',
          updatedDate: '',
        );
      }
    }

    // Parse City safely
    CityModel? parsedCity;
    if (j['city'] != null) {
      if (j['city'] is Map) {
        parsedCity = CityModel.fromJson(j['city'] as Map<String, dynamic>);
      } else if (j['city'] is String && (j['city'] as String).isNotEmpty) {
        parsedCity = CityModel(
          id: 0,
          name: j['city'] as String,
          code: '',
          stateId: 0,
          status: 1,
          createdDate: '',
          updatedDate: '',
        );
      }
    }

    // Parse Dealer safely
    UserModel? parsedDealer;
    if (j['dealer_name'] != null) {
      if (j['dealer_name'] is Map) {
        parsedDealer = UserModel.fromJson(j['dealer_name'] as Map<String, dynamic>);
      } else if (j['dealer_name'] is String && (j['dealer_name'] as String).isNotEmpty) {
        parsedDealer = UserModel(
          id: 0,
          state: null,
          city: null,
          profileCode: '',
          name: j['dealer_name'] as String,
          contactPerson: '',
          mobileNo: '',
          address: '',
          profileImage: '',
          password: '',
          roleType: 'Dealer',
          joiningDate: '',
          onlineStatus: 1,
          workingHrs: '',
          isOvertimeAllowed: 1,
          status: 1,
          updatedDate: '',
          createdDate: '',
        );
      }
    }

    // Parse Employee safely
    UserModel? parsedEmp;
    if (j['emp_id'] != null) {
      if (j['emp_id'] is Map) {
        parsedEmp = UserModel.fromJson(j['emp_id'] as Map<String, dynamic>);
      } else if (j['emp_id'] is String && (j['emp_id'] as String).isNotEmpty) {
        parsedEmp = UserModel(
          id: 0,
          state: null,
          city: null,
          profileCode: '',
          name: j['emp_id'] as String,
          contactPerson: '',
          mobileNo: '',
          address: '',
          profileImage: '',
          password: '',
          roleType: 'User',
          joiningDate: '',
          onlineStatus: 1,
          workingHrs: '',
          isOvertimeAllowed: 1,
          status: 1,
          updatedDate: '',
          createdDate: '',
        );
      }
    }

    // Parse Client safely
    UserModel? parsedClient;
    if (j['client_id'] != null) {
      if (j['client_id'] is Map) {
        parsedClient = UserModel.fromJson(j['client_id'] as Map<String, dynamic>);
      } else if (j['client_id'] is String && (j['client_id'] as String).isNotEmpty) {
        parsedClient = UserModel(
          id: 0,
          state: null,
          city: null,
          profileCode: '',
          name: j['client_id'] as String,
          contactPerson: '',
          mobileNo: '',
          address: '',
          profileImage: '',
          password: '',
          roleType: 'Manager',
          joiningDate: '',
          onlineStatus: 1,
          workingHrs: '',
          isOvertimeAllowed: 1,
          status: 1,
          updatedDate: '',
          createdDate: '',
        );
      }
    }

    final String? parsedUserId = parsedEmp != null ? parsedEmp.id.toString() : j['user_id']?.toString();
    final String? parsedDealerId = parsedDealer != null ? parsedDealer.id.toString() : j['dealer_id']?.toString();

    return TaskModel(
      id: (j['id'] ?? '').toString(),
      taskTitle: (j['task_name'] ?? '').toString(),
      projectId: parsedProject,
      date: (j['created_date'] ?? j['date'] ?? j['created_at'] ?? '')
          .toString(),
      utcDate: (j['updated_date'] ?? j['utc_date'] ?? j['updated_at'] ?? '')
          .toString(),
      nds: parsedNds,
      dealerName: parsedDealer,
      address: (j['site_location'] ?? j['address'] ?? '').toString(),
      state: parsedState,
      city: parsedCity,
      district: (j['tehsil'] ?? j['district'] ?? '').toString(),
      status: parsedStatus,
      siteType: parsedSiteType,
      latitude: j['latitude'] != null
          ? double.tryParse(j['latitude'].toString())
          : null,
      longitude: j['longitude'] != null
          ? double.tryParse(j['longitude'].toString())
          : null,
      taskCode: (j['code'] ?? j['task_code'] ?? '').toString(),
      managerId: extractedManagerId.isNotEmpty
          ? extractedManagerId
          : (j['manager_id'] ?? '').toString(),
      userId: parsedUserId,
      dealerId: parsedDealerId,
      remarks: (j['remark'] ?? j['remarks'] ?? '').toString(),
      installationLocation:
          (j['site_location'] ?? j['installation_location'] ?? '').toString(),
      rangeInMeter: parsedRange,
      createdAt: (j['created_date'] ?? j['created_at'] ?? '').toString(),
      updatedAt: (j['updated_date'] ?? j['updated_at'] ?? '').toString(),
      empId: parsedEmp,
      clientId: parsedClient,
      tehsil: (j['tehsil'] ?? '').toString(),
      locationType: (j['location_type'] ?? '').toString(),
      noOfFlex: parsedNds,
      sizeOfFlex: (j['size_of_flex'] ?? '').toString(),
      remark: (j['remark'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'task_title': taskTitle,
    'project_id': projectId?.toJson(),
    'date': date,
    'utc_date': utcDate,
    'nds': nds,
    'dealer_name': dealerName?.toJson(),
    'address': address,
    'state': state?.toJson(),
    'city': city?.toJson(),
    'district': district,
    'status': status.jsonValue,
    'site_type': siteType.jsonValue,
    'latitude': latitude,
    'longitude': longitude,
    'task_code': taskCode,
    'manager_id': managerId,
    'user_id': userId,
    'dealer_id': dealerId,
    'remarks': remarks,
    'installation_location': installationLocation,
    'range_in_meter': rangeInMeter,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'emp_id': empId?.toJson(),
    'client_id': clientId?.toJson(),
    'tehsil': tehsil,
    'location_type': locationType,
    'no_of_flex': noOfFlex,
    'size_of_flex': sizeOfFlex,
    'remark': remark,
  };

  TaskModel copyWith({
    TaskStatus? status,
    String? remarks,
    String? updatedAt,
    ProjectModel? projectId,
    UserModel? empId,
    UserModel? clientId,
    UserModel? dealerName,
    StateModel? state,
    CityModel? city,
  }) => TaskModel(
    id: id,
    taskTitle: taskTitle,
    projectId: projectId ?? this.projectId,
    date: date,
    utcDate: utcDate,
    nds: nds,
    dealerName: dealerName ?? this.dealerName,
    address: address,
    state: state ?? this.state,
    city: city ?? this.city,
    district: district,
    status: status ?? this.status,
    siteType: siteType,
    latitude: latitude,
    longitude: longitude,
    taskCode: taskCode,
    managerId: managerId,
    userId: userId,
    dealerId: dealerId,
    remarks: remarks ?? this.remarks,
    installationLocation: installationLocation,
    rangeInMeter: rangeInMeter,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    empId: empId ?? this.empId,
    clientId: clientId ?? this.clientId,
    tehsil: tehsil,
    locationType: locationType,
    noOfFlex: noOfFlex,
    sizeOfFlex: sizeOfFlex,
    remark: remark,
  );
}
