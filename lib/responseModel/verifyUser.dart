// To parse this JSON data, do
//
//     final verifyUserModel = verifyUserModelFromJson(jsonString);

import 'dart:convert';

VerifyUserModel verifyUserModelFromJson(String str) =>
    VerifyUserModel.fromJson(json.decode(str));

String verifyUserModelToJson(VerifyUserModel data) =>
    json.encode(data.toJson());

class VerifyUserModel {
  VerifyUserModel({
    required this.resultCode,
    required this.developerMessage,
    required this.resultData,
  });

  String resultCode;
  String developerMessage;
  VerifyUserResultData resultData;

  factory VerifyUserModel.fromJson(Map<String, dynamic> json) =>
      VerifyUserModel(
        resultCode: json["resultCode"],
        developerMessage: json["developerMessage"],
        resultData: VerifyUserResultData.fromJson(json["resultData"]),
      );

  Map<String, dynamic> toJson() => {
        "resultCode": resultCode,
        "developerMessage": developerMessage,
        "resultData": resultData.toJson(),
      };
}

class VerifyUserResultData {
  VerifyUserResultData({
    this.lastLogin,
    required this.userId,
    this.imageProfileFile,
    this.driverPriority,
    required this.signatureFile,
    required this.token,
    required this.email,
    required this.password,
    required this.firstnameTh,
    required this.lastnameTh,
    required this.firstnameEn,
    required this.lastnameEn,
    required this.mobileNo,
    required this.dateOfBirth,
    required this.userRoleId,
    required this.userStateId,
    this.pdpaFlagDatetime,
    this.pdpaFlag,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.empInfo,
  });

  dynamic lastLogin;
  String userId;
  String? imageProfileFile;
  dynamic driverPriority;
  String signatureFile;
  String token;
  String email;
  String password;
  String firstnameTh;
  String lastnameTh;
  String firstnameEn;
  String lastnameEn;
  String mobileNo;
  DateTime dateOfBirth;
  String userRoleId;
  String userStateId;
  dynamic pdpaFlagDatetime;
  dynamic pdpaFlag;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;
  VerifyUserEmpInfo empInfo;

  factory VerifyUserResultData.fromJson(Map<String, dynamic> json) =>
      VerifyUserResultData(
        lastLogin: json["last_login"],
        userId: json["user_id"],
        imageProfileFile: json["image_profile_file"] ?? null,
        driverPriority: json["driver_priority"],
        signatureFile: json["signature_file"],
        token: json["token"],
        email: json["email"],
        password: json["password"],
        firstnameTh: json["firstname_th"],
        lastnameTh: json["lastname_th"],
        firstnameEn: json["firstname_en"],
        lastnameEn: json["lastname_en"],
        mobileNo: json["mobile_no"],
        dateOfBirth: DateTime.parse(json["date_of_birth"]),
        userRoleId: json["user_role_id"],
        userStateId: json["user_state_id"],
        pdpaFlagDatetime: json["pdpa_flag_datetime"],
        pdpaFlag: json["pdpa_flag"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
        empInfo: VerifyUserEmpInfo.fromJson(json["emp_info"]),
      );

  Map<String, dynamic> toJson() => {
        "last_login": lastLogin,
        "user_id": userId,
        "image_profile_file": imageProfileFile,
        "driver_priority": driverPriority,
        "signature_file": signatureFile,
        "token": token,
        "email": email,
        "password": password,
        "firstname_th": firstnameTh,
        "lastname_th": lastnameTh,
        "firstname_en": firstnameEn,
        "lastname_en": lastnameEn,
        "mobile_no": mobileNo,
        "date_of_birth":
            "${dateOfBirth.year.toString().padLeft(4, '0')}-${dateOfBirth.month.toString().padLeft(2, '0')}-${dateOfBirth.day.toString().padLeft(2, '0')}",
        "user_role_id": userRoleId,
        "user_state_id": userStateId,
        "pdpa_flag_datetime": pdpaFlagDatetime,
        "pdpa_flag": pdpaFlag,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "deleted_at": deletedAt,
        "emp_info": empInfo.toJson(),
      };
}

class VerifyUserEmpInfo {
  VerifyUserEmpInfo({
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
  VerifyUserEmpDepartmentInfo empDepartmentInfo;

  factory VerifyUserEmpInfo.fromJson(Map<String, dynamic> json) =>
      VerifyUserEmpInfo(
        empId: json["emp_id"],
        empCode: json["emp_code"],
        userId: json["user_id"],
        empPositionId: json["emp_position_id"],
        empDepartmentId: json["emp_department_id"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
        empDepartmentInfo:
            VerifyUserEmpDepartmentInfo.fromJson(json["emp_department_info"]),
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

class VerifyUserEmpDepartmentInfo {
  VerifyUserEmpDepartmentInfo({
    required this.empDepartmentId,
    required this.address,
    required this.departmentCode,
    required this.empDepartmentNameTh,
    required this.empDepartmentNameEn,
    required this.managerId,
    required this.adminId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  String empDepartmentId;
  String address;
  String departmentCode;
  String empDepartmentNameTh;
  String empDepartmentNameEn;
  String managerId;
  String adminId;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;

  factory VerifyUserEmpDepartmentInfo.fromJson(Map<String, dynamic> json) =>
      VerifyUserEmpDepartmentInfo(
        empDepartmentId: json["emp_department_id"],
        address: json["address"],
        departmentCode: json["department_code"],
        empDepartmentNameTh: json["emp_department_name_th"],
        empDepartmentNameEn: json["emp_department_name_en"],
        managerId: json["manager_id"],
        adminId: json["admin_id"],
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
        "manager_id": managerId,
        "admin_id": adminId,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "deleted_at": deletedAt,
      };
}
