// To parse this JSON data, do
//
//     final routeInfoByPath = routeInfoByPathFromJson(jsonString);

import 'dart:convert';

RouteInfoByPath routeInfoByPathFromJson(String str) =>
    RouteInfoByPath.fromJson(json.decode(str));

String routeInfoByPathToJson(RouteInfoByPath data) =>
    json.encode(data.toJson());

class RouteInfoByPath {
  RouteInfoByPath({
    required this.resultCode,
    required this.developerMessage,
    required this.resultData,
  });

  String resultCode;
  String developerMessage;
  ResultData resultData;

  factory RouteInfoByPath.fromJson(Map<String, dynamic> json) =>
      RouteInfoByPath(
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
    required this.routeInfoId,
    required this.routeCode,
    required this.originRouteNameTh,
    required this.originRouteNameEn,
    required this.originRouteNameMm,
    required this.originRouteNameKh,
    required this.destinationRouteNameTh,
    required this.destinationRouteNameEn,
    required this.destinationRouteNameMm,
    required this.destinationRouteNameKh,
    required this.tripType,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.createdByInfo,
    required this.routePoiInfo,
  });

  String routeInfoId;
  String routeCode;
  String originRouteNameTh;
  String originRouteNameEn;
  String originRouteNameMm;
  String originRouteNameKh;
  String destinationRouteNameTh;
  String destinationRouteNameEn;
  String destinationRouteNameMm;
  String destinationRouteNameKh;
  String tripType;
  String status;
  String createdBy;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;
  CreatedByInfo createdByInfo;
  List<RoutePoiInfo> routePoiInfo;

  factory ResultData.fromJson(Map<String, dynamic> json) => ResultData(
        routeInfoId: json["route_info_id"],
        routeCode: json["route_code"],
        originRouteNameTh: json["origin_route_name_th"],
        originRouteNameEn: json["origin_route_name_en"],
        originRouteNameMm: json["origin_route_name_mm"],
        originRouteNameKh: json["origin_route_name_kh"],
        destinationRouteNameTh: json["destination_route_name_th"],
        destinationRouteNameEn: json["destination_route_name_en"],
        destinationRouteNameMm: json["destination_route_name_mm"],
        destinationRouteNameKh: json["destination_route_name_kh"],
        tripType: json["trip_type"],
        status: json["status"],
        createdBy: json["created_by"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
        createdByInfo: CreatedByInfo.fromJson(json["created_by_info"]),
        routePoiInfo: List<RoutePoiInfo>.from(
            json["route_poi_info"].map((x) => RoutePoiInfo.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "route_info_id": routeInfoId,
        "route_code": routeCode,
        "origin_route_name_th": originRouteNameTh,
        "origin_route_name_en": originRouteNameEn,
        "origin_route_name_mm": originRouteNameMm,
        "origin_route_name_kh": originRouteNameKh,
        "destination_route_name_th": destinationRouteNameTh,
        "destination_route_name_en": destinationRouteNameEn,
        "destination_route_name_mm": destinationRouteNameMm,
        "destination_route_name_kh": destinationRouteNameKh,
        "trip_type": tripType,
        "status": status,
        "created_by": createdBy,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "deleted_at": deletedAt,
        "created_by_info": createdByInfo.toJson(),
        "route_poi_info":
            List<dynamic>.from(routePoiInfo.map((x) => x.toJson())),
      };
}

class CreatedByInfo {
  CreatedByInfo({
    required this.lastLogin,
    required this.userId,
    required this.imageProfileFile,
    this.driverPriority,
    this.signatureFile,
    this.token,
    required this.email,
    required this.password,
    required this.firstnameTh,
    required this.lastnameTh,
    this.firstnameEn,
    this.lastnameEn,
    required this.mobileNo,
    this.dateOfBirth,
    required this.userRoleId,
    required this.userStateId,
    required this.pdpaFlagDatetime,
    required this.pdpaFlag,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  DateTime lastLogin;
  String userId;
  String imageProfileFile;
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
  DateTime pdpaFlagDatetime;
  String pdpaFlag;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;

  factory CreatedByInfo.fromJson(Map<String, dynamic> json) => CreatedByInfo(
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
        pdpaFlagDatetime: DateTime.parse(json["pdpa_flag_datetime"]),
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
        "pdpa_flag_datetime": pdpaFlagDatetime.toIso8601String(),
        "pdpa_flag": pdpaFlag,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "deleted_at": deletedAt,
      };
}

class RoutePoiInfo {
  RoutePoiInfo(
      {required this.routePoiInfoId,
      required this.routeInfoId,
      required this.locationNameTh,
      required this.locationNameEn,
      required this.locationNameMm,
      required this.locationNameKh,
      required this.latitude,
      required this.longitude,
      required this.order,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.status,
      required this.checkInTime,
      required this.passengerCount,
      required this.passengerCountUsed});

  String routePoiInfoId;
  String routeInfoId;
  String locationNameTh;
  String locationNameEn;
  String locationNameMm;
  String locationNameKh;
  String latitude;
  String longitude;
  int order;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;
  String status;
  String checkInTime;
  int passengerCount;
  int passengerCountUsed;

  factory RoutePoiInfo.fromJson(Map<String, dynamic> json) => RoutePoiInfo(
        routePoiInfoId: json["route_poi_info_id"],
        routeInfoId: json["route_info_id"],
        locationNameTh: json["location_name_th"],
        locationNameEn: json["location_name_en"],
        locationNameMm: json["location_name_mm"],
        locationNameKh: json["location_name_kh"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        order: json["order"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
        status: json["status"],
        checkInTime: json["check_in_time"],
        passengerCountUsed: json["passenger_count_used"],
        passengerCount: json["passenger_count"],
      );

  Map<String, dynamic> toJson() => {
        "route_poi_info_id": routePoiInfoId,
        "route_info_id": routeInfoId,
        "location_name_th": locationNameTh,
        "location_name_en": locationNameEn,
        "location_name_mm": locationNameMm,
        "location_name_kh": locationNameKh,
        "latitude": latitude,
        "longitude": longitude,
        "order": order,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "deleted_at": deletedAt,
      };
}
