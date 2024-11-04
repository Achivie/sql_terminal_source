// To parse this JSON data, do
//
//     final dbModel = dbModelFromJson(jsonString);

import 'dart:convert';

DbModel dbModelFromJson(String str) => DbModel.fromJson(json.decode(str));

String dbModelToJson(DbModel data) => json.encode(data.toJson());

class DbModel {
  String uid;
  String did;
  String databaseUsrName;
  String databasePass;
  DateTime dbCreatedTime;
  DateTime dbLastConnected;

  DbModel({
    required this.uid,
    required this.did,
    required this.databaseUsrName,
    required this.databasePass,
    required this.dbCreatedTime,
    required this.dbLastConnected,
  });

  factory DbModel.fromJson(Map<String, dynamic> json) => DbModel(
        uid: json["uid"],
        did: json["did"],
        databaseUsrName: json["database_usrName"],
        databasePass: json["database_pass"],
        dbCreatedTime: DateTime.parse(json["db_createdTime"]),
        dbLastConnected: DateTime.parse(json["db_lastConnected"]),
      );

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "did": did,
        "database_usrName": databaseUsrName,
        "database_pass": databasePass,
        "db_createdTime": dbCreatedTime.toIso8601String(),
        "db_lastConnected": dbLastConnected.toIso8601String(),
      };
}
