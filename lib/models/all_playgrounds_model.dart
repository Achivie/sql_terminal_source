// To parse this JSON data, do
//
//     final allPlaygroundsModel = allPlaygroundsModelFromJson(jsonString);

import 'dart:convert';

AllPlaygroundsModel allPlaygroundsModelFromJson(String str) =>
    AllPlaygroundsModel.fromJson(json.decode(str));

String allPlaygroundsModelToJson(AllPlaygroundsModel data) =>
    json.encode(data.toJson());

class AllPlaygroundsModel {
  bool success;
  String message;
  List<Playground> playgrounds;

  AllPlaygroundsModel({
    required this.success,
    required this.message,
    required this.playgrounds,
  });

  factory AllPlaygroundsModel.fromJson(Map<String, dynamic> json) =>
      AllPlaygroundsModel(
        success: json["success"],
        message: json["message"],
        playgrounds: List<Playground>.from(
            json["playgrounds"].map((x) => Playground.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "playgrounds": List<dynamic>.from(playgrounds.map((x) => x.toJson())),
      };
}

class Playground {
  String pid;
  String did;
  String pName;
  DateTime pLastEdited;
  DateTime pCreateTimestamp;
  String commands;
  String uid;

  Playground({
    required this.pid,
    required this.did,
    required this.pName,
    required this.pLastEdited,
    required this.pCreateTimestamp,
    required this.commands,
    required this.uid,
  });

  factory Playground.fromJson(Map<String, dynamic> json) => Playground(
        pid: json["pid"],
        did: json["did"],
        pName: json["p_name"],
        pLastEdited: DateTime.parse(json["p_lastEdited"]),
        pCreateTimestamp: DateTime.parse(json["p_createTimestamp"]),
        commands: json["commands"],
        uid: json["uid"],
      );

  Map<String, dynamic> toJson() => {
        "pid": pid,
        "did": did,
        "p_name": pName,
        "p_lastEdited": pLastEdited.toIso8601String(),
        "p_createTimestamp": pCreateTimestamp.toIso8601String(),
        "commands": commands,
        "uid": uid,
      };
}
