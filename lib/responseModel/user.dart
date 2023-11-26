// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
  User({
    required this.resultCode,
    required this.developerMessage,
    required this.resultData,
  });

  String resultCode;
  String developerMessage;
  ResultData resultData;

  factory User.fromJson(Map<String, dynamic> json) => User(
        resultCode: json["resultCode"],
        developerMessage: json["developerMessage"],
        resultData: ResultData.fromJson(json["resultData"]),
      );

  Map<String, dynamic> toJson() => {
        "resultCode": resultCode,
        "developerMessage": developerMessage,
        "resultData": resultData.toJson(),
      };
}

class ResultData {
  ResultData({
    required this.lastLogin,
    required this.userId,
    required this.imageProfileFile,
    this.driverPriority,
    this.signatureFile,
    this.token,
    required this.email,
    required this.firstnameTh,
    required this.lastnameTh,
    this.firstnameEn,
    this.lastnameEn,
    required this.mobileNo,
    this.dateOfBirth,
    required this.userRoleId,
    required this.userStateId,
    this.pdpaFlagDatetime,
    this.pdpaFlag,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.driverLicenseInfo,
    required this.userRoleInfo,
    required this.userStateInfo,
    required this.empInfo,
  });

  DateTime lastLogin;
  String userId;
  String imageProfileFile;
  dynamic driverPriority;
  dynamic signatureFile;
  dynamic token;
  String email;
  String firstnameTh;
  String lastnameTh;
  dynamic firstnameEn;
  dynamic lastnameEn;
  String mobileNo;
  dynamic dateOfBirth;
  String userRoleId;
  String userStateId;
  dynamic pdpaFlagDatetime;
  dynamic pdpaFlag;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;
  List<dynamic> driverLicenseInfo;
  UserRoleInfo userRoleInfo;
  UserStateInfo userStateInfo;
  EmpInfo empInfo;

  factory ResultData.fromJson(Map<String, dynamic> json) => ResultData(
        lastLogin: DateTime.parse(json["last_login"]),
        userId: json["user_id"],
        imageProfileFile: json["image_profile_file"],
        driverPriority: json["driver_priority"],
        signatureFile: json["signature_file"],
        token: json["token"],
        email: json["email"],
        firstnameTh: json["firstname_th"],
        lastnameTh: json["lastname_th"],
        firstnameEn: json["firstname_en"],
        lastnameEn: json["lastname_en"],
        mobileNo: json["mobile_no"],
        dateOfBirth: json["date_of_birth"],
        userRoleId: json["user_role_id"],
        userStateId: json["user_state_id"],
        pdpaFlagDatetime: json["pdpa_flag_datetime"],
        pdpaFlag: json["pdpa_flag"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
        driverLicenseInfo:
            List<dynamic>.from(json["driver_license_info"].map((x) => x)),
        userRoleInfo: UserRoleInfo.fromJson(json["user_role_info"]),
        userStateInfo: UserStateInfo.fromJson(json["user_state_info"]),
        empInfo: EmpInfo.fromJson(json["emp_info"]),
      );

  Map<String, dynamic> toJson() => {
        "last_login": lastLogin.toIso8601String(),
        "user_id": userId,
        "image_profile_file": imageProfileFile,
        "driver_priority": driverPriority,
        "signature_file": signatureFile,
        "token": token,
        "email": email,
        "firstname_th": firstnameTh,
        "lastname_th": lastnameTh,
        "firstname_en": firstnameEn,
        "lastname_en": lastnameEn,
        "mobile_no": mobileNo,
        "date_of_birth": dateOfBirth,
        "user_role_id": userRoleId,
        "user_state_id": userStateId,
        "pdpa_flag_datetime": pdpaFlagDatetime,
        "pdpa_flag": pdpaFlag,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "deleted_at": deletedAt,
        "driver_license_info":
            List<dynamic>.from(driverLicenseInfo.map((x) => x)),
        "user_role_info": userRoleInfo.toJson(),
        "user_state_info": userStateInfo.toJson(),
        "emp_info": empInfo.toJson(),
      };
}

class EmpInfo {
  EmpInfo({
    required this.empId,
    required this.empCode,
    required this.userId,
    required this.empPositionId,
    required this.empDepartmentId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.empDepartmentInfo,
  });

  String empId;
  String empCode;
  String userId;
  String empPositionId;
  String empDepartmentId;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;
  EmpDepartmentInfo empDepartmentInfo;

  factory EmpInfo.fromJson(Map<String, dynamic> json) => EmpInfo(
        empId: json["emp_id"],
        empCode: json["emp_code"],
        userId: json["user_id"],
        empPositionId: json["emp_position_id"],
        empDepartmentId: json["emp_department_id"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
        empDepartmentInfo:
            EmpDepartmentInfo.fromJson(json["emp_department_info"]),
      );

  Map<String, dynamic> toJson() => {
        "emp_id": empId,
        "emp_code": empCode,
        "user_id": userId,
        "emp_position_id": empPositionId,
        "emp_department_id": empDepartmentId,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "deleted_at": deletedAt,
        "emp_department_info": empDepartmentInfo.toJson(),
      };
}

class EmpDepartmentInfo {
  EmpDepartmentInfo({
    required this.empDepartmentId,
    required this.address,
    required this.departmentCode,
    required this.empDepartmentNameTh,
    required this.empDepartmentNameEn,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  String empDepartmentId;
  String? address;
  String departmentCode;
  String empDepartmentNameTh;
  String? empDepartmentNameEn;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;

  factory EmpDepartmentInfo.fromJson(Map<String, dynamic> json) =>
      EmpDepartmentInfo(
        empDepartmentId: json["emp_department_id"],
        address: json["address"] ?? "",
        departmentCode: json["department_code"],
        empDepartmentNameTh: json["emp_department_name_th"],
        empDepartmentNameEn: json["emp_department_name_en"] ?? "",
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
      );

  Map<String, dynamic> toJson() => {
        "emp_department_id": empDepartmentId,
        "address": address,
        "department_code": departmentCode,
        "emp_department_name_th": empDepartmentNameTh,
        "emp_department_name_en": empDepartmentNameEn,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "deleted_at": deletedAt,
      };
}

class UserRoleInfo {
  UserRoleInfo({
    required this.userRoleId,
    required this.userRoleNameTh,
    required this.userRoleNameEn,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  String userRoleId;
  String userRoleNameTh;
  String userRoleNameEn;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;

  factory UserRoleInfo.fromJson(Map<String, dynamic> json) => UserRoleInfo(
        userRoleId: json["user_role_id"],
        userRoleNameTh: json["user_role_name_th"],
        userRoleNameEn: json["user_role_name_en"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
      );

  Map<String, dynamic> toJson() => {
        "user_role_id": userRoleId,
        "user_role_name_th": userRoleNameTh,
        "user_role_name_en": userRoleNameEn,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "deleted_at": deletedAt,
      };
}

class UserStateInfo {
  UserStateInfo({
    required this.userStateId,
    required this.userStateNameTh,
    required this.userStateNameEn,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  String userStateId;
  String userStateNameTh;
  String userStateNameEn;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;

  factory UserStateInfo.fromJson(Map<String, dynamic> json) => UserStateInfo(
        userStateId: json["user_state_id"],
        userStateNameTh: json["user_state_name_th"],
        userStateNameEn: json["user_state_name_en"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
      );

  Map<String, dynamic> toJson() => {
        "user_state_id": userStateId,
        "user_state_name_th": userStateNameTh,
        "user_state_name_en": userStateNameEn,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "deleted_at": deletedAt,
      };
}
