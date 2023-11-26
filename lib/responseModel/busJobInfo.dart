// To parse this JSON data, do
//
//     final busJobInfo = busJobInfoFromJson(jsonString);

import 'dart:convert';

BusJobInfo busJobInfoFromJson(String str) =>
    BusJobInfo.fromJson(json.decode(str));

String busJobInfoToJson(BusJobInfo data) => json.encode(data.toJson());

class BusJobInfo {
  BusJobInfo({
    required this.resultCode,
    required this.developerMessage,
    required this.resultData,
  });

  String resultCode;
  String developerMessage;
  ResultData resultData;

  factory BusJobInfo.fromJson(Map<String, dynamic> json) => BusJobInfo(
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
    required this.busJobInfoId,
    required this.docNo,
    required this.carMileageStart,
    required this.carMileageEnd,
    required this.destinationImagePath,
    required this.routeInfoId,
    required this.tripDatetime,
    required this.driverId,
    required this.carInfoId,
    required this.numberOfSeat,
    required this.numberOfReserved,
    required this.busReserveStatusId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.driverInfo,
    required this.carInfo,
    required this.routeInfo,
  });

  String busJobInfoId;
  String docNo;
  int? carMileageStart;
  int? carMileageEnd;
  String? destinationImagePath;
  String routeInfoId;
  DateTime tripDatetime;
  String driverId;
  String carInfoId;
  int numberOfSeat;
  int numberOfReserved;
  String busReserveStatusId;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;
  DriverInfo driverInfo;
  CarInfo carInfo;
  RouteInfo routeInfo;

  factory ResultData.fromJson(Map<String, dynamic> json) => ResultData(
        busJobInfoId: json["bus_job_info_id"],
        docNo: json["doc_no"],
        carMileageStart: json["car_mileage_start"] ?? 0,
        carMileageEnd: json["car_mileage_end"] ?? 0,
        destinationImagePath: json["destination_image_path"] ?? "",
        routeInfoId: json["route_info_id"],
        tripDatetime: DateTime.parse(json["trip_datetime"]),
        driverId: json["driver_id"],
        carInfoId: json["car_info_id"],
        numberOfSeat: json["number_of_seat"],
        numberOfReserved: json["number_of_reserved"],
        busReserveStatusId: json["bus_reserve_status_id"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
        driverInfo: DriverInfo.fromJson(json["driver_info"]),
        carInfo: CarInfo.fromJson(json["car_info"]),
        routeInfo: RouteInfo.fromJson(json["route_info"]),
      );

  Map<String, dynamic> toJson() => {
        "bus_job_info_id": busJobInfoId,
        "doc_no": docNo,
        "car_mileage_start": carMileageStart,
        "car_mileage_end": carMileageEnd,
        "destination_image_path": destinationImagePath,
        "route_info_id": routeInfoId,
        "trip_datetime": tripDatetime.toIso8601String(),
        "driver_id": driverId,
        "car_info_id": carInfoId,
        "number_of_seat": numberOfSeat,
        "number_of_reserved": numberOfReserved,
        "bus_reserve_status_id": busReserveStatusId,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "deleted_at": deletedAt,
        "driver_info": driverInfo.toJson(),
        "car_info": carInfo.toJson(),
        "route_info": routeInfo.toJson(),
      };
}

class CarInfo {
  CarInfo({
    required this.carInfoId,
    required this.forServices,
    required this.order,
    required this.status,
    required this.numberOfSeat,
    required this.costPerMonth,
    required this.imgPath,
    required this.carTypeId,
    required this.color,
    required this.brand,
    required this.model,
    required this.carPlate,
    required this.minimumService,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  String carInfoId;
  String forServices;
  int order;
  String status;
  int numberOfSeat;
  int costPerMonth;
  String? imgPath;
  String carTypeId;
  String color;
  String brand;
  String model;
  String carPlate;
  int minimumService;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;

  factory CarInfo.fromJson(Map<String, dynamic> json) => CarInfo(
        carInfoId: json["car_info_id"],
        forServices: json["for_services"],
        order: json["order"],
        status: json["status"],
        numberOfSeat: json["number_of_seat"],
        costPerMonth: json["cost_per_month"],
        imgPath: json["img_path"] ?? "",
        carTypeId: json["car_type_id"],
        color: json["color"],
        brand: json["brand"],
        model: json["model"],
        carPlate: json["car_plate"],
        minimumService: json["minimum_service"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
      );

  Map<String, dynamic> toJson() => {
        "car_info_id": carInfoId,
        "for_services": forServices,
        "order": order,
        "status": status,
        "number_of_seat": numberOfSeat,
        "cost_per_month": costPerMonth,
        "img_path": imgPath,
        "car_type_id": carTypeId,
        "color": color,
        "brand": brand,
        "model": model,
        "car_plate": carPlate,
        "minimum_service": minimumService,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "deleted_at": deletedAt,
      };
}

class DriverInfo {
  DriverInfo({
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
    this.pdpaFlagDatetime,
    this.pdpaFlag,
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
  dynamic pdpaFlagDatetime;
  dynamic pdpaFlag;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;

  factory DriverInfo.fromJson(Map<String, dynamic> json) => DriverInfo(
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

class RouteInfo {
  RouteInfo({
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

  factory RouteInfo.fromJson(Map<String, dynamic> json) => RouteInfo(
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
      };
}
