// To parse this JSON data, do
//
//     final busRef = busRefFromJson(jsonString);

import 'dart:convert';

BusRef busRefFromJson(String str) => BusRef.fromJson(json.decode(str));

String busRefToJson(BusRef data) => json.encode(data.toJson());

class BusRef {
  BusRef({
    this.resultCode,
    this.developerMessage,
    this.resultData,
    this.rowCount,
  });

  String resultCode;
  String developerMessage;
  List<ResultDatum> resultData;
  int rowCount;

  factory BusRef.fromJson(Map<String, dynamic> json) => BusRef(
        resultCode: json["resultCode"],
        developerMessage: json["developerMessage"],
        resultData: List<ResultDatum>.from(
            json["resultData"].map((x) => ResultDatum.fromJson(x))),
        rowCount: json["rowCount"],
      );

  Map<String, dynamic> toJson() => {
        "resultCode": resultCode,
        "developerMessage": developerMessage,
        "resultData": List<dynamic>.from(resultData.map((x) => x.toJson())),
        "rowCount": rowCount,
      };
}

class ResultDatum {
  ResultDatum({
    this.busJobRefReserveId,
    this.busJobInfoId,
    this.busReserveInfoId,
    this.busJobInfoInfo,
    this.busReserveInfoInfo,
  });

  String busJobRefReserveId;
  String busJobInfoId;
  String busReserveInfoId;
  BusJobInfoInfo busJobInfoInfo;
  BusReserveInfoInfo busReserveInfoInfo;

  factory ResultDatum.fromJson(Map<String, dynamic> json) => ResultDatum(
        busJobRefReserveId: json["bus_job_ref_reserve_id"],
        busJobInfoId: json["bus_job_info_id"],
        busReserveInfoId: json["bus_reserve_info_id"],
        busJobInfoInfo: BusJobInfoInfo.fromJson(json["bus_job_info_info"]),
        busReserveInfoInfo:
            BusReserveInfoInfo.fromJson(json["bus_reserve_info_info"]),
      );

  Map<String, dynamic> toJson() => {
        "bus_job_ref_reserve_id": busJobRefReserveId,
        "bus_job_info_id": busJobInfoId,
        "bus_reserve_info_id": busReserveInfoId,
        "bus_job_info_info": busJobInfoInfo.toJson(),
        "bus_reserve_info_info": busReserveInfoInfo.toJson(),
      };
}

class BusJobInfoInfo {
  BusJobInfoInfo({
    this.busJobInfoId,
    this.docNo,
    this.carMileageStart,
    this.carMileageEnd,
    this.destinationImagePath,
    this.routeInfoId,
    this.tripDatetime,
    this.driverId,
    this.carInfoId,
    this.numberOfSeat,
    this.numberOfReserved,
    this.busReserveStatusId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  String busJobInfoId;
  String docNo;
  int carMileageStart;
  int carMileageEnd;
  dynamic destinationImagePath;
  String routeInfoId;
  DateTime tripDatetime;
  String driverId;
  String carInfoId;
  dynamic numberOfSeat;
  dynamic numberOfReserved;
  String busReserveStatusId;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;

  factory BusJobInfoInfo.fromJson(Map<String, dynamic> json) => BusJobInfoInfo(
        busJobInfoId: json["bus_job_info_id"],
        docNo: json["doc_no"],
        carMileageStart: json["car_mileage_start"],
        carMileageEnd: json["car_mileage_end"],
        destinationImagePath: json["destination_image_path"],
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
      };
}

class BusReserveInfoInfo {
  BusReserveInfoInfo({
    this.busReserveInfoId,
    this.carReserveInfoId,
    this.allocatedBy,
    this.docNo,
    this.routeInfoId,
    this.tripDatetime,
    this.isNormalTime,
    this.empDepartmentId,
    this.busReserveStatusId,
    this.reserveReason,
    this.busReserveReasonCancelId,
    this.busReserveReasonText,
    this.canceledBy,
    this.canceledAt,
    this.createdBy,
    this.expiredAt,
    this.createdAt,
    this.updatedAt,
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
  dynamic busReserveReasonText;
  dynamic canceledBy;
  dynamic canceledAt;
  String createdBy;
  DateTime expiredAt;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;

  factory BusReserveInfoInfo.fromJson(Map<String, dynamic> json) =>
      BusReserveInfoInfo(
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
        /*   expiredAt: DateTime.parse(json["expired_at"]), */
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
        "expired_at": expiredAt.toIso8601String(),
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "deleted_at": deletedAt,
      };
}
