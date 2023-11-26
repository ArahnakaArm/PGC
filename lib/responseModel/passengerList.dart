// To parse this JSON data, do
//
//     final passengerList = passengerListFromJson(jsonString);

import 'dart:convert';

PassengerList passengerListFromJson(String str) =>
    PassengerList.fromJson(json.decode(str));

String passengerListToJson(PassengerList data) => json.encode(data.toJson());

class PassengerList {
  PassengerList({
    required this.resultCode,
    required this.developerMessage,
    required this.resultData,
    required this.rowCount,
  });

  String resultCode;
  String developerMessage;
  List<ResultDataPassengerList> resultData;
  int rowCount;

  factory PassengerList.fromJson(Map<String, dynamic> json) => PassengerList(
        resultCode: json["resultCode"],
        developerMessage: json["developerMessage"],
        resultData: List<ResultDataPassengerList>.from(
            json["resultData"].map((x) => ResultDataPassengerList.fromJson(x))),
        rowCount: json["rowCount"],
      );

  Map<String, dynamic> toJson() => {
        "resultCode": resultCode,
        "developerMessage": developerMessage,
        "resultData": List<dynamic>.from(resultData.map((x) => x.toJson())),
        "rowCount": rowCount,
      };
}

class ResultDataPassengerList {
  ResultDataPassengerList({
    required this.busReservePassengerId,
    required this.tripDatetime,
    required this.busReserveInfoId,
    required this.routeInfoId,
    required this.routePoiInfoId,
    required this.userId,
    required this.empId,
    required this.driverId,
    required this.carInfoId,
    this.busProviderName,
    required this.passengerStatusId,
    required this.busJobInfoId,
    this.usedAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.busReserveInfo,
    required this.carInfo,
    required this.userInfo,
    required this.routeInfo,
    required this.routePoiInfo,
    required this.empInfo,
    required this.driverInfo,
  });

  String busReservePassengerId;
  DateTime tripDatetime;
  String busReserveInfoId;
  String routeInfoId;
  String routePoiInfoId;
  String userId;
  String empId;
  String driverId;
  String carInfoId;
  dynamic busProviderName;
  String passengerStatusId;
  String busJobInfoId;
  dynamic usedAt;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;
  BusReserveInfo busReserveInfo;
  CarInfo carInfo;
  UserInfo userInfo;
  RouteInfo routeInfo;
  RoutePoiInfo routePoiInfo;
  EmpInfo empInfo;
  DriverInfo driverInfo;

  factory ResultDataPassengerList.fromJson(Map<String, dynamic> json) =>
      ResultDataPassengerList(
        busReservePassengerId: json["bus_reserve_passenger_id"],
        tripDatetime: DateTime.parse(json["trip_datetime"]),
        busReserveInfoId: json["bus_reserve_info_id"],
        routeInfoId: json["route_info_id"],
        routePoiInfoId: json["route_poi_info_id"],
        userId: json["user_id"],
        empId: json["emp_id"],
        driverId: json["driver_id"],
        carInfoId: json["car_info_id"],
        busProviderName: json["bus_provider_name"],
        passengerStatusId: json["passenger_status_id"],
        busJobInfoId: json["bus_job_info_id"],
        usedAt: json["used_at"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
        busReserveInfo: BusReserveInfo.fromJson(json["bus_reserve_info"]),
        carInfo: CarInfo.fromJson(json["car_info"]),
        userInfo: UserInfo.fromJson(json["user_info"]),
        routeInfo: RouteInfo.fromJson(json["route_info"]),
        routePoiInfo: RoutePoiInfo.fromJson(json["route_poi_info"]),
        empInfo: EmpInfo.fromJson(json["emp_info"]),
        driverInfo: DriverInfo.fromJson(json["driver_info"]),
      );

  Map<String, dynamic> toJson() => {
        "bus_reserve_passenger_id": busReservePassengerId,
        "trip_datetime": tripDatetime.toIso8601String(),
        "bus_reserve_info_id": busReserveInfoId,
        "route_info_id": routeInfoId,
        "route_poi_info_id": routePoiInfoId,
        "user_id": userId,
        "emp_id": empId,
        "driver_id": driverId,
        "car_info_id": carInfoId,
        "bus_provider_name": busProviderName,
        "passenger_status_id": passengerStatusId,
        "bus_job_info_id": busJobInfoId,
        "used_at": usedAt,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "deleted_at": deletedAt,
        "bus_reserve_info": busReserveInfo.toJson(),
        "car_info": carInfo.toJson(),
        "user_info": userInfo.toJson(),
        "route_info": routeInfo.toJson(),
        "route_poi_info": routePoiInfo.toJson(),
        "emp_info": empInfo.toJson(),
        "driver_info": driverInfo.toJson(),
      };
}

class UserInfo {
  UserInfo({
    this.lastLogin,
    required this.userId,
    this.imageProfileFile,
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

  dynamic lastLogin;
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
        lastLogin: json["last_login"],
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

class BusReserveInfo {
  BusReserveInfo({
    required this.busReserveInfoId,
    required this.carReserveInfoId,
    this.allocatedBy,
    required this.docNo,
    required this.routeInfoId,
    required this.tripDatetime,
    required this.isNormalTime,
    required this.empDepartmentId,
    required this.busReserveStatusId,
    required this.reserveReason,
    this.busReserveReasonCancelId,
    required this.busReserveReasonText,
    this.canceledBy,
    this.canceledAt,
    required this.createdBy,
    this.expiredAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  String busReserveInfoId;
  dynamic carReserveInfoId;
  dynamic allocatedBy;
  String docNo;
  String routeInfoId;
  DateTime tripDatetime;
  String isNormalTime;
  String empDepartmentId;
  String busReserveStatusId;
  String reserveReason;
  dynamic busReserveReasonCancelId;
  String busReserveReasonText;
  dynamic canceledBy;
  dynamic canceledAt;
  String createdBy;
  dynamic expiredAt;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;

  factory BusReserveInfo.fromJson(Map<String, dynamic> json) => BusReserveInfo(
        busReserveInfoId: json["bus_reserve_info_id"],
        carReserveInfoId: json["car_reserve_info_id"],
        allocatedBy: json["allocated_by"],
        docNo: json["doc_no"],
        routeInfoId: json["route_info_id"],
        tripDatetime: DateTime.parse(json["trip_datetime"]),
        isNormalTime: json["is_normal_time"],
        empDepartmentId: json["emp_department_id"],
        busReserveStatusId: json["bus_reserve_status_id"],
        reserveReason: json["reserve_reason"],
        busReserveReasonCancelId: json["bus_reserve_reason_cancel_id"],
        busReserveReasonText: json["bus_reserve_reason_text"],
        canceledBy: json["canceled_by"],
        canceledAt: json["canceled_at"],
        createdBy: json["created_by"],
        expiredAt: json["expired_at"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
      );

  Map<String, dynamic> toJson() => {
        "bus_reserve_info_id": busReserveInfoId,
        "car_reserve_info_id": carReserveInfoId,
        "allocated_by": allocatedBy,
        "doc_no": docNo,
        "route_info_id": routeInfoId,
        "trip_datetime": tripDatetime.toIso8601String(),
        "is_normal_time": isNormalTime,
        "emp_department_id": empDepartmentId,
        "bus_reserve_status_id": busReserveStatusId,
        "reserve_reason": reserveReason,
        "bus_reserve_reason_cancel_id": busReserveReasonCancelId,
        "bus_reserve_reason_text": busReserveReasonText,
        "canceled_by": canceledBy,
        "canceled_at": canceledAt,
        "created_by": createdBy,
        "expired_at": expiredAt,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "deleted_at": deletedAt,
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
    required this.carTypeInfo,
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
  CarTypeInfo carTypeInfo;

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
        carTypeInfo: CarTypeInfo.fromJson(json["car_type_info"]),
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
        "car_type_info": carTypeInfo.toJson(),
      };
}

class CarTypeInfo {
  CarTypeInfo({
    required this.carTypeId,
    this.priority,
    required this.excludeIncaseNoDriver,
    required this.status,
    required this.carTypeNameTh,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  String carTypeId;
  dynamic priority;
  String excludeIncaseNoDriver;
  String status;
  String carTypeNameTh;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;

  factory CarTypeInfo.fromJson(Map<String, dynamic> json) => CarTypeInfo(
        carTypeId: json["car_type_id"],
        priority: json["priority"],
        excludeIncaseNoDriver: json["exclude_incase_no_driver"],
        status: json["status"],
        carTypeNameTh: json["car_type_name_th"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
      );

  Map<String, dynamic> toJson() => {
        "car_type_id": carTypeId,
        "priority": priority,
        "exclude_incase_no_driver": excludeIncaseNoDriver,
        "status": status,
        "car_type_name_th": carTypeNameTh,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "deleted_at": deletedAt,
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
  String? managerId;
  String? adminId;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;

  factory EmpDepartmentInfo.fromJson(Map<String, dynamic> json) =>
      EmpDepartmentInfo(
        empDepartmentId: json["emp_department_id"],
        address: json["address"],
        departmentCode: json["department_code"],
        empDepartmentNameTh: json["emp_department_name_th"],
        empDepartmentNameEn: json["emp_department_name_en"],
        managerId: json["manager_id"] ?? "",
        adminId: json["admin_id"] ?? "",
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

class RouteInfo {
  RouteInfo({
    required this.routeInfoId,
    required this.busLineInfoId,
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
  String busLineInfoId;
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
        busLineInfoId: json["bus_line_info_id"],
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
        "bus_line_info_id": busLineInfoId,
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

class RoutePoiInfo {
  RoutePoiInfo({
    required this.routePoiInfoId,
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
  });

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

class DriverInfo {
  DriverInfo({
    this.lastLogin,
    required this.userId,
    this.imageProfileFile,
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

  dynamic lastLogin;
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

  factory DriverInfo.fromJson(Map<String, dynamic> json) => DriverInfo(
        lastLogin: json["last_login"],
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
