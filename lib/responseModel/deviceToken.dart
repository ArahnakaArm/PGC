// To parse this JSON data, do
//
//     final deviceTokenModel = deviceTokenModelFromJson(jsonString);

import 'dart:convert';

DeviceTokenModel deviceTokenModelFromJson(String str) =>
    DeviceTokenModel.fromJson(json.decode(str));

String deviceTokenModelToJson(DeviceTokenModel data) =>
    json.encode(data.toJson());

class DeviceTokenModel {
  DeviceTokenModel({
    required this.resultCode,
    required this.developerMessage,
    required this.resultData,
    required this.rowCount,
  });

  String resultCode;
  String developerMessage;
  List<DeviceTokenArray> resultData;
  int rowCount;

  factory DeviceTokenModel.fromJson(Map<String, dynamic> json) =>
      DeviceTokenModel(
        resultCode: json["resultCode"],
        developerMessage: json["developerMessage"],
        resultData: List<DeviceTokenArray>.from(
            json["resultData"].map((x) => DeviceTokenArray.fromJson(x))),
        rowCount: json["rowCount"],
      );

  Map<String, dynamic> toJson() => {
        "resultCode": resultCode,
        "developerMessage": developerMessage,
        "resultData": List<dynamic>.from(resultData.map((x) => x.toJson())),
        "rowCount": rowCount,
      };
}

class DeviceTokenArray {
  DeviceTokenArray({
    required this.rowId,
    required this.userId,
    required this.deviceToken,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  String rowId;
  String userId;
  String deviceToken;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;

  factory DeviceTokenArray.fromJson(Map<String, dynamic> json) =>
      DeviceTokenArray(
        rowId: json["row_id"],
        userId: json["user_id"],
        deviceToken: json["device_token"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
      );

  Map<String, dynamic> toJson() => {
        "row_id": rowId,
        "user_id": userId,
        "device_token": deviceToken,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "deleted_at": deletedAt,
      };
}
