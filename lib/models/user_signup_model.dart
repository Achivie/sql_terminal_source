// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

UserSignUpModel userSignUpModelFromJson(String str) =>
    UserSignUpModel.fromJson(json.decode(str));

String userSignUpModelToJson(UserSignUpModel data) =>
    json.encode(data.toJson());

class UserSignUpModel {
  bool success;
  String message;
  String token;
  List<UserSignUpData> data;
  String emailResId;
  int otp;

  UserSignUpModel({
    required this.success,
    required this.message,
    required this.token,
    required this.data,
    required this.emailResId,
    required this.otp,
  });

  factory UserSignUpModel.fromJson(Map<String, dynamic> json) =>
      UserSignUpModel(
        success: json["success"],
        message: json["message"],
        token: json["token"],
        data: List<UserSignUpData>.from(
            json["data"].map((x) => UserSignUpData.fromJson(x))),
        emailResId: json["emailResID"],
        otp: json["otp"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "token": token,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "emailResID": emailResId,
        "otp": otp,
      };
}

class UserSignUpData {
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

  UserSignUpData({
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

  factory UserSignUpData.fromJson(Map<String, dynamic> json) => UserSignUpData(
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
