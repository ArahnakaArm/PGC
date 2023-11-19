// To parse this JSON data, do
//
//     final auth = authFromJson(jsonString);

import 'dart:convert';

Auth authFromJson(String str) => Auth.fromJson(json.decode(str));

String authToJson(Auth data) => json.encode(data.toJson());

class Auth {
  Auth({
    required this.resultCode,
    required this.developerMessage,
    required this.resultData,
  });

  String resultCode;
  String developerMessage;
  ResultData resultData;

  factory Auth.fromJson(Map<String, dynamic> json) => Auth(
        resultCode: json["resultCode"] ?? null,
        developerMessage: json["developerMessage"] ?? null,
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
    required this.accessToken,
  });

  String accessToken;

  factory ResultData.fromJson(Map<String, dynamic> json) => ResultData(
        accessToken: json["access_token"] ?? null,
      );

  Map<String, dynamic> toJson() => {
        "access_token": accessToken,
      };
}
