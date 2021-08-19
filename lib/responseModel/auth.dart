// To parse this JSON data, do
//
//     final auth = authFromJson(jsonString);

import 'dart:convert';

Auth authFromJson(String str) => Auth.fromJson(json.decode(str));

String authToJson(Auth data) => json.encode(data.toJson());

class Auth {
  Auth({
    this.resultCode,
    this.developerMessage,
    this.resultData,
  });

  String resultCode;
  String developerMessage;
  ResultData resultData;

  factory Auth.fromJson(Map<String, dynamic> json) => Auth(
        resultCode: null ? null : json["resultCode"],
        developerMessage: null ? null : json["developerMessage"],
        resultData: null ? null : ResultData.fromJson(json["resultData"]),
      );

  Map<String, dynamic> toJson() => {
        "resultCode": null ? null : resultCode,
        "developerMessage": null ? null : developerMessage,
        "resultData": null ? null : resultData.toJson(),
      };
}

class ResultData {
  ResultData({
    this.accessToken,
  });

  String accessToken;

  factory ResultData.fromJson(Map<String, dynamic> json) => ResultData(
        accessToken: null ? null : json["access_token"],
      );

  Map<String, dynamic> toJson() => {
        "access_token": null ? null : accessToken,
      };
}
