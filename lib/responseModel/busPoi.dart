// To parse this JSON data, do
//
//     final busPoi = busPoiFromJson(jsonString);

import 'dart:convert';

BusPoi busPoiFromJson(String str) => BusPoi.fromJson(json.decode(str));

String busPoiToJson(BusPoi data) => json.encode(data.toJson());

class BusPoi {
  BusPoi({
    this.resultCode,
    this.developerMessage,
    this.resultData,
    this.rowCount,
  });

  String resultCode;
  String developerMessage;
  List<ResultDatum> resultData;
  int rowCount;

  factory BusPoi.fromJson(Map<String, dynamic> json) => BusPoi(
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
    this.busJobPoiId,
    this.busJobInfoId,
    this.routeInfoId,
    this.routePoiInfoId,
    this.checkinDatetime,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.routeInfo,
  });

  String busJobPoiId;
  String busJobInfoId;
  String routeInfoId;
  String routePoiInfoId;
  DateTime checkinDatetime;
  String status;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;

  RouteInfo routeInfo;

  factory ResultDatum.fromJson(Map<String, dynamic> json) => ResultDatum(
        busJobPoiId: json["bus_job_poi_id"],
        busJobInfoId: json["bus_job_info_id"],
        routeInfoId: json["route_info_id"],
        routePoiInfoId: json["route_poi_info_id"],
        checkinDatetime: DateTime.parse(json["checkin_datetime"]),
        status: json["status"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
        routeInfo: RouteInfo.fromJson(json["route_info"]),
      );

  Map<String, dynamic> toJson() => {
        "bus_job_poi_id": busJobPoiId,
        "bus_job_info_id": busJobInfoId,
        "route_info_id": routeInfoId,
        "route_poi_info_id": routePoiInfoId,
        "checkin_datetime": checkinDatetime.toIso8601String(),
        "status": status,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "deleted_at": deletedAt,
        "route_info": routeInfo.toJson(),
      };
}

class RouteInfo {
  RouteInfo({
    this.routeInfoId,
    this.routeCode,
    this.originRouteNameTh,
    this.originRouteNameEn,
    this.originRouteNameMm,
    this.originRouteNameKh,
    this.destinationRouteNameTh,
    this.destinationRouteNameEn,
    this.destinationRouteNameMm,
    this.destinationRouteNameKh,
    this.tripType,
    this.status,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
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
