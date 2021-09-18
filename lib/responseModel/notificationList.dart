// To parse this JSON data, do
//
//     final notificationListModel = notificationListModelFromJson(jsonString);

import 'dart:convert';

NotificationListModel notificationListModelFromJson(String str) =>
    NotificationListModel.fromJson(json.decode(str));

String notificationListModelToJson(NotificationListModel data) =>
    json.encode(data.toJson());

class NotificationListModel {
  NotificationListModel({
    this.resultCode,
    this.developerMessage,
    this.resultData,
    this.rowCount,
  });

  String resultCode;
  String developerMessage;
  List<ResultNotificationList> resultData;
  int rowCount;

  factory NotificationListModel.fromJson(Map<String, dynamic> json) =>
      NotificationListModel(
        resultCode: json["resultCode"],
        developerMessage: json["developerMessage"],
        resultData: List<ResultNotificationList>.from(
            json["resultData"].map((x) => ResultNotificationList.fromJson(x))),
        rowCount: json["rowCount"],
      );

  Map<String, dynamic> toJson() => {
        "resultCode": resultCode,
        "developerMessage": developerMessage,
        "resultData": List<dynamic>.from(resultData.map((x) => x.toJson())),
        "rowCount": rowCount,
      };
}

class ResultNotificationList {
  ResultNotificationList({
    this.notificationId,
    this.receiverId,
    this.isRead,
    this.notiText,
    this.notiDetail,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  String notificationId;
  String receiverId;
  String isRead;
  String notiText;
  String notiDetail;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;

  factory ResultNotificationList.fromJson(Map<String, dynamic> json) =>
      ResultNotificationList(
        notificationId: json["notification_id"],
        receiverId: json["receiver_id"],
        isRead: json["is_read"],
        notiText: json["text"],
        notiDetail: json["detail"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
      );

  Map<String, dynamic> toJson() => {
        "notification_id": notificationId,
        "receiver_id": receiverId,
        "is_read": isRead,
        "text": notiText,
        "detail": notiDetail,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "deleted_at": deletedAt,
      };
}
