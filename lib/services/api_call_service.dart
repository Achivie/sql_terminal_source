import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'keys.dart';

class APICallServices {
  static Future<http.Response> getProfile({
    required BuildContext context,
    required String token,
    required String uid,
  }) async =>
      await http.get(
        Uri.parse("${AppKeys.apiSqlBaseUrl}/profile/$uid"),
        headers: {
          "content-type": "application/json",
          'Authorization': 'Bearer $token',
        },
      );

  static Future<http.Response> createDatabase({
    required BuildContext context,
    required String uid,
    required String database_usrName,
    required String database_pass,
    required String usrFirstName,
    required String usrLastName,
    required String token,
    required String usrEmail,
  }) async =>
      await http.post(
        Uri.parse("${AppKeys.apiSqlBaseUrl}/create/database"),
        headers: {
          "content-type": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          AppKeys.uid: uid,
          AppKeys.database_usrName: database_usrName,
          AppKeys.database_pass: database_pass,
          AppKeys.usrFirstName: usrFirstName,
          AppKeys.usrLastName: usrLastName,
          AppKeys.usrEmail: usrEmail,
        }),
      );

  static Future<http.Response> getPlaygrounds({
    required String uid,
    required int page,
    required String token,
    required int limit,
  }) async =>
      await http.get(
        Uri.parse(
            "${AppKeys.apiSqlBaseUrl}/playgrounds/$uid?page=$page&limit=$limit"),
        headers: {
          "content-type": "application/json",
          'Authorization': 'Bearer $token',
        },
      );

  static Future<http.Response> createPlayground({
    required String uid,
    required String p_name,
    required String did,
    required String database_pass,
    required String usrFirstName,
    required String usrLastName,
    required String token,
    required String usrEmail,
  }) async =>
      await http.post(
        Uri.parse("${AppKeys.apiSqlBaseUrl}/create/playground"),
        headers: {
          "content-type": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          AppKeys.uid: uid,
          AppKeys.did: did,
          AppKeys.p_name: p_name,
          AppKeys.database_pass: database_pass,
          AppKeys.usrFirstName: usrFirstName,
          AppKeys.usrLastName: usrLastName,
          AppKeys.usrEmail: usrEmail,
        }),
      );

  static Future<http.Response> getPlayground({
    required String uid,
    required String token,
    required String pid,
  }) async =>
      await http.get(
        Uri.parse("${AppKeys.apiSqlBaseUrl}/playground/$uid/$pid"),
        headers: {
          "content-type": "application/json",
          'Authorization': 'Bearer $token',
        },
      );

  static Future<http.Response> connectDatabase({
    required String uid,
    required String did,
    required String database_usrName,
    required String token,
    required String database_pass,
  }) async =>
      await http.post(
        Uri.parse("${AppKeys.apiSqlBaseUrl}/connect"),
        headers: {
          "content-type": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          AppKeys.uid: uid,
          AppKeys.did: did,
          AppKeys.database_usrName: database_usrName,
          AppKeys.database_pass: database_pass,
        }),
      );

  static Future<http.Response> execute({
    required String uid,
    required String did,
    required String pid,
    required String database_usrName,
    required String database_pass,
    required String token,
    required String command,
  }) async =>
      await http.post(
        Uri.parse("${AppKeys.apiSqlBaseUrl}/execute"),
        headers: {
          "content-type": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          AppKeys.uid: uid,
          AppKeys.pid: pid,
          AppKeys.did: did,
          AppKeys.database_usrName: database_usrName,
          AppKeys.database_pass: database_pass,
          AppKeys.command: command,
        }),
      );

  static Future<http.Response> updateLastEdited({
    required String uid,
    required String did,
    required String pid,
    required String token,
    required String commands,
  }) async =>
      await http.post(
        Uri.parse("${AppKeys.apiSqlBaseUrl}/update/playground/lastEdited"),
        headers: {
          "content-type": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          AppKeys.uid: uid,
          AppKeys.pid: pid,
          AppKeys.did: did,
          AppKeys.commands: commands,
        }),
      );

  static Future<http.Response> deletePlayground({
    required String uid,
    required String did,
    required String pid,
    required String p_name,
    required String database_pass,
    required String usrFirstName,
    required String usrLastName,
    required String usrEmail,
    required String token,
  }) async =>
      await http.delete(
        Uri.parse("${AppKeys.apiSqlBaseUrl}/delete/playground"),
        headers: {
          "content-type": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          AppKeys.uid: uid,
          AppKeys.did: did,
          AppKeys.pid: pid,
          AppKeys.p_name: p_name,
          AppKeys.database_pass: database_pass,
          AppKeys.usrFirstName: usrFirstName,
          AppKeys.usrLastName: usrLastName,
          AppKeys.usrEmail: usrEmail,
        }),
      );

  static Future<int> getCompletionRate(
      {required String uid, required String token}) async {
    // ((totalDone / (totalTasks - totalDelete)) * 100).round();

    // String uid = userLoginModel!.data.uid;
    // String token = userLoginModel!.token;

    http.Response response = await http.get(
        Uri.parse("${AppKeys.apiUsersBaseUrl}/completionRate/$uid"),
        headers: {
          "content-type": "application/json",
          'Authorization': 'Bearer $token',
        });

    if (response.statusCode == 200) {
      Map<String, dynamic> responseJson = jsonDecode(response.body);
      // log(responseJson.toString());
      if (responseJson["success"]) {
        return responseJson["completionRate"];
      }
    }

    return 0;
  }
}
