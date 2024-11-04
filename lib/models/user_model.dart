// To parse this JSON data, do
//
//     final userLoginModel = userLoginModelFromJson(jsonString);

import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  bool success;
  String message;
  String token;
  UserData data;

  UserModel({
    required this.success,
    required this.message,
    required this.token,
    required this.data,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        success: json["success"],
        message: json["message"],
        token: json["token"],
        data: UserData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "token": token,
        "data": data.toJson(),
      };
}

class UserData {
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

  UserData({
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
  });

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
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
      };
}
