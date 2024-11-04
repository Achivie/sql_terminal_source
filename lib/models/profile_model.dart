// To parse this JSON data, do
//
//     final profileModel = profileModelFromJson(jsonString);

import 'dart:convert';

ProfileModel profileModelFromJson(String str) =>
    ProfileModel.fromJson(json.decode(str));

String profileModelToJson(ProfileModel data) => json.encode(data.toJson());

class ProfileModel {
  bool success;
  String message;
  Profile profile;

  ProfileModel({
    required this.success,
    required this.message,
    required this.profile,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        success: json["success"],
        message: json["message"],
        profile: Profile.fromJson(json["profile"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "profile": profile.toJson(),
      };
}

class Profile {
  String usrFirstName;
  String usrLastName;
  String usrPassword;
  String uid;
  String usrProfilePic;
  String usrDescription;
  String usrProfession;
  int taskBusiness;
  int taskCount;
  int taskDelete;
  int taskPending;
  int taskPersonal;
  String usrEmail;
  int taskDone;
  int usrPoints;
  int verified;
  String did;
  String databaseUsrName;
  String databasePass;
  DateTime dbCreatedTime;
  DateTime dbLastConnected;

  Profile({
    required this.usrFirstName,
    required this.usrLastName,
    required this.usrPassword,
    required this.uid,
    required this.usrProfilePic,
    required this.usrDescription,
    required this.usrProfession,
    required this.taskBusiness,
    required this.taskCount,
    required this.taskDelete,
    required this.taskPending,
    required this.taskPersonal,
    required this.usrEmail,
    required this.taskDone,
    required this.usrPoints,
    required this.verified,
    required this.did,
    required this.databaseUsrName,
    required this.databasePass,
    required this.dbCreatedTime,
    required this.dbLastConnected,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        usrFirstName: json["usrFirstName"],
        usrLastName: json["usrLastName"],
        usrPassword: json["usrPassword"],
        uid: json["uid"],
        usrProfilePic: json["usrProfilePic"],
        usrDescription: json["usrDescription"],
        usrProfession: json["usrProfession"],
        taskBusiness: json["taskBusiness"],
        taskCount: json["taskCount"],
        taskDelete: json["taskDelete"],
        taskPending: json["taskPending"],
        taskPersonal: json["taskPersonal"],
        usrEmail: json["usrEmail"],
        taskDone: json["taskDone"],
        usrPoints: json["usrPoints"],
        verified: json["verified"],
        did: json["did"],
        databaseUsrName: json["database_usrName"],
        databasePass: json["database_pass"],
        dbCreatedTime: DateTime.parse(json["db_createdTime"]),
        dbLastConnected: DateTime.parse(json["db_lastConnected"]),
      );

  Map<String, dynamic> toJson() => {
        "usrFirstName": usrFirstName,
        "usrLastName": usrLastName,
        "usrPassword": usrPassword,
        "uid": uid,
        "usrProfilePic": usrProfilePic,
        "usrDescription": usrDescription,
        "usrProfession": usrProfession,
        "taskBusiness": taskBusiness,
        "taskCount": taskCount,
        "taskDelete": taskDelete,
        "taskPending": taskPending,
        "taskPersonal": taskPersonal,
        "usrEmail": usrEmail,
        "taskDone": taskDone,
        "usrPoints": usrPoints,
        "verified": verified,
        "did": did,
        "database_usrName": databaseUsrName,
        "database_pass": databasePass,
        "db_createdTime": dbCreatedTime.toIso8601String(),
        "db_lastConnected": dbLastConnected.toIso8601String(),
      };
}
