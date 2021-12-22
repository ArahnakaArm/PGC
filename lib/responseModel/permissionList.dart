// To parse this JSON data, do
//
//     final permissionList = permissionListFromJson(jsonString);

import 'dart:convert';

PermissionList permissionListFromJson(String str) =>
    PermissionList.fromJson(json.decode(str));

String permissionListToJson(PermissionList data) => json.encode(data.toJson());

class PermissionList {
  PermissionList({
    this.resultCode,
    this.developerMessage,
    this.resultData,
    this.rowCount,
  });

  String resultCode;
  String developerMessage;
  List<PermissionResult> resultData;
  int rowCount;

  factory PermissionList.fromJson(Map<String, dynamic> json) => PermissionList(
        resultCode: json["resultCode"],
        developerMessage: json["developerMessage"],
        resultData: List<PermissionResult>.from(
            json["resultData"].map((x) => PermissionResult.fromJson(x))),
        rowCount: json["rowCount"],
      );

  Map<String, dynamic> toJson() => {
        "resultCode": resultCode,
        "developerMessage": developerMessage,
        "resultData": List<dynamic>.from(resultData.map((x) => x.toJson())),
        "rowCount": rowCount,
      };
}

class PermissionResult {
  PermissionResult({
    this.userPermissionId,
    this.userId,
    this.permissionId,
    this.permissionRoleId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.userInfo,
    this.permissionRoleInfo,
    this.permissionInfo,
  });

  String userPermissionId;
  String userId;
  String permissionId;
  String permissionRoleId;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;
  UserInfo userInfo;
  PermissionRoleInfo permissionRoleInfo;
  PermissionInfo permissionInfo;

  factory PermissionResult.fromJson(Map<String, dynamic> json) =>
      PermissionResult(
        userPermissionId: json["user_permission_id"],
        userId: json["user_id"],
        permissionId: json["permission_id"],
        permissionRoleId: json["permission_role_id"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
        userInfo: UserInfo.fromJson(json["user_info"]),
        permissionRoleInfo:
            PermissionRoleInfo.fromJson(json["permission_role_info"]),
        permissionInfo: PermissionInfo.fromJson(json["permission_info"]),
      );

  Map<String, dynamic> toJson() => {
        "user_permission_id": userPermissionId,
        "user_id": userId,
        "permission_id": permissionId,
        "permission_role_id": permissionRoleId,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "deleted_at": deletedAt,
        "user_info": userInfo.toJson(),
        "permission_role_info": permissionRoleInfo.toJson(),
        "permission_info": permissionInfo.toJson(),
      };
}

class PermissionInfo {
  PermissionInfo({
    this.permissionId,
    this.permissionSystemName,
    this.order,
  });

  String permissionId;
  String permissionSystemName;
  int order;

  factory PermissionInfo.fromJson(Map<String, dynamic> json) => PermissionInfo(
        permissionId: json["permission_id"],
        permissionSystemName: json["permission_system_name"],
        order: json["order"],
      );

  Map<String, dynamic> toJson() => {
        "permission_id": permissionId,
        "permission_system_name": permissionSystemName,
        "order": order,
      };
}

class PermissionRoleInfo {
  PermissionRoleInfo({
    this.permissionRoleId,
    this.permissionId,
    this.permissionRoleName,
    this.order,
  });

  String permissionRoleId;
  String permissionId;
  String permissionRoleName;
  int order;

  factory PermissionRoleInfo.fromJson(Map<String, dynamic> json) =>
      PermissionRoleInfo(
        permissionRoleId: json["permission_role_id"],
        permissionId: json["permission_id"],
        permissionRoleName: json["permission_role_name"],
        order: json["order"],
      );

  Map<String, dynamic> toJson() => {
        "permission_role_id": permissionRoleId,
        "permission_id": permissionId,
        "permission_role_name": permissionRoleName,
        "order": order,
      };
}

class UserInfo {
  UserInfo({
    this.lastLogin,
    this.userId,
    this.imageProfileFile,
    this.driverPriority,
    this.signatureFile,
    this.token,
    this.email,
    this.password,
    this.firstnameTh,
    this.lastnameTh,
    this.firstnameEn,
    this.lastnameEn,
    this.mobileNo,
    this.dateOfBirth,
    this.userRoleId,
    this.userStateId,
    this.pdpaFlagDatetime,
    this.pdpaFlag,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  DateTime lastLogin;
  String userId;
  dynamic imageProfileFile;
  dynamic driverPriority;
  dynamic signatureFile;
  dynamic token;
  String email;
  String password;
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

  factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
        lastLogin: DateTime.parse(json["last_login"]),
        userId: json["user_id"],
        imageProfileFile: json["image_profile_file"],
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
        dateOfBirth: json["date_of_birth"],
        userRoleId: json["user_role_id"],
        userStateId: json["user_state_id"],
        pdpaFlagDatetime: json["pdpa_flag_datetime"],
        pdpaFlag: json["pdpa_flag"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
      );

  Map<String, dynamic> toJson() => {
        "last_login": lastLogin.toIso8601String(),
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
        "date_of_birth": dateOfBirth,
        "user_role_id": userRoleId,
        "user_state_id": userStateId,
        "pdpa_flag_datetime": pdpaFlagDatetime,
        "pdpa_flag": pdpaFlag,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "deleted_at": deletedAt,
      };
}
