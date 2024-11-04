// import 'dart:developer' as dev;
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:sql_terminal/services/storage_services.dart';
import 'package:sql_terminal/services/styles.dart';

import '../models/playground_model.dart';
import '../models/user_model.dart';
import '../utils/snakbar_utils.dart';

class AppConstants {
  static List<String> keywords = [
    "select",
    "from",
    "where",
    "delete",
    "as",
    "create",
    "table",
    "join",
    "on",
    "and",
    "in",
    "like",
    "drop",
    "group",
    "by",
    "alter",
    "view",
    "desc",
    "add",
    "column",
    "union",
    "asc",
    "set",
    "distinct",
    "into",
    "insert",
    "values",
    "update",
    "set",
    "between",
    "then",
    "else",
    "not",
    "null",
    "having",
    "exists",
    "limit",
    "offset",
    "truncate",
    "view",
    "when",
    "end",
  ];

  static String routeToText(String route) {
    route = route.substring(1);
    List<String> words = route.split('-');
    return capitalizeFirstLetters(words.join(' '));
  }

  static String capitalizeFirstLetters(String input) {
    List<String> words = input.split(' ');
    words = words.map((word) => _capitalizeFirstLetter(word)).toList();
    return words.join(' ');
  }

  static String _capitalizeFirstLetter(String word) {
    if (word.isEmpty) return '';
    return word[0].toUpperCase() + word.substring(1);
  }

  static Future changeAppName(BuildContext context, String name) async {
    SystemChrome.setApplicationSwitcherDescription(
        ApplicationSwitcherDescription(
      label: name,
      primaryColor: Theme.of(context).primaryColor.value,
    ));
  }

  static String lastEditedString(DateTime lastEdited) {
    final now = DateTime.now();
    final difference = now.difference(lastEdited);

    if (difference.inMinutes <= 1) {
      return "now";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} minutes ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} hours ago";
    } else if (difference.inDays < 7) {
      return "${difference.inDays} days ago";
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return "$weeks weeks ago";
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return "$months months ago";
    } else {
      final years = (difference.inDays / 365).floor();
      return "$years years ago";
    }
  }

  static Future<List<PlaygroundModel>> getPlaygrounds(String userID) async {
    List<PlaygroundModel> playgrounds = [];

    // Generate 10 playgrounds with random data
    for (int i = 0; i < 10; i++) {
      // Generate random data for each playground
      String name = 'Playground $i';
      DateTime lastEdited =
          DateTime.now().subtract(Duration(days: Random().nextInt(30)));
      String commands = 'Commands for $name';
      String id = userID + i.toString();
      DateTime created =
          DateTime.now().subtract(Duration(days: Random().nextInt(365)));
      String databasePassword = "Database Password $i";
      String databaseUsername = "Database Username $i";

      // Create PlaygroundModel object and add it to the list
      PlaygroundModel playground = PlaygroundModel(
        name: name,
        lastEdited: lastEdited,
        commands: commands,
        id: id,
        created: created,
        databasePassword: databasePassword,
        databaseUsername: databaseUsername,
      );

      playgrounds.add(playground);
    }

    return playgrounds;
  }

  Color getRandomColor() {
    Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(51) + 204, // Red (204-255)
      random.nextInt(51) + 204, // Green (204-255)
      random.nextInt(51) + 204, // Blue (204-255)
    );
  }

  static Future<UserModel?> getUserData() async {
    return await StorageServices().readUserData();
  }

  static RichText formatText(String text, String prefix) {
    final parts = text.split(" ");
    final List<TextSpan> spans = [];
    // dev.log(parts.toString());
    // dev.log(prefix);

    for (var i = 0; i < parts.length; i++) {
      TextStyle style = TextStyle();
      // dev.log((parts[i] == prefix).toString());
      if (keywords.contains(parts[i].toLowerCase())) {
        parts[i] = parts[i].toUpperCase();
        style = TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.deepOrange,
        );
      } else if (parts[i] == prefix) {
        // Do nothing or apply a specific style for the prefix if needed
        style = TextStyle(
          color: AppColors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        );
      } else if (parts[i] == ";") {
        style = TextStyle(
          color: AppColors.white.withOpacity(0.7),
        );
      } else {
        style = TextStyle(
          color: AppColors.white,
        );
      }

      spans.add(TextSpan(
        text: parts[i],
        style: style,
      ));
      if (i < parts.length - 1) {
        // Add the space after each part except for the last one
        spans.add(const TextSpan(text: " "));
      }
    }

    return RichText(text: TextSpan(children: spans));
  }

  static String takeFirstWord(String sentence) {
    // Split the sentence by spaces
    List<String> words = sentence.split(' ');

    // Return the first word
    return words.isNotEmpty ? words[0] : '';
  }

  static String removeLastLetter(String input) {
    if (input.isNotEmpty && input[input.length - 1] != '>') {
      return input.substring(0, input.length - 1);
    } else {
      return input;
    }
  }

  static String getMostRecentCommand(
      List<String> commands, String userCommand) {
    // Ensure commands list is not null or empty
    if (commands.isEmpty) {
      throw ArgumentError('Commands list must not be null or empty.');
    }

    // Ensure userCommand is not null or empty
    if (userCommand.isEmpty) {
      throw ArgumentError('User command must not be null or empty.');
    }

    // Iterate over the commands list in reverse order
    for (int i = commands.length - 1; i >= 0; i--) {
      // Check if the current command starts with the user command
      if (commands[i].startsWith(userCommand)) {
        return commands[i]; // Return the first matching command found
      }
    }

    // If no matching command is found, return an empty string or handle error as needed
    throw ArgumentError('No command found starting with "$userCommand".');
  }

  static void copyTextToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  static Future<void> saveTextToFileAndDownload(
      String text, String fileName) async {
    // Save the text to a .txt file
    if (Platform.isAndroid ||
        Platform.isIOS ||
        Platform.isMacOS ||
        Platform.isWindows ||
        Platform.isLinux) {
      await _saveTextToFile(text, fileName);
    }
    // else {
    //   await _downloadTextAsFile(text, fileName);
    // }
  }

  // static void saveTextToFile(String textContent, String fileName) {
  //   // Create a Blob object containing the text content
  //   http.Blob blob = http.Blob([textContent], 'text/plain');
  //
  //   // Create an anchor element to trigger the download
  //   http.AnchorElement anchorElement =
  //       http.AnchorElement(href: Url.createObjectUrlFromBlob(blob))
  //         ..setAttribute('download', fileName)
  //         ..text = 'Download Text File';
  //
  //   // Append the anchor element to the body
  //   document.body?.append(anchorElement);
  //
  //   // Click the anchor element to trigger the download
  //   anchorElement.click();
  // }

  static Future<void> _saveTextToFile(String text, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName.txt');
    await file.writeAsString(text);
    print('Text saved to file: ${file.path}');
  }

// static Future<void> _downloadTextAsFile(String text, String fileName) async {
//   final bytes = utf8.encode(text);
//   final blob = Blob([bytes]);
//   final url =
//       Uri.dataFromBytes(bytes, mimeType: 'text/plain', encoding: utf8);
//   final anchor = AnchorElement(href: url.toString())
//     ..setAttribute('download', '$fileName.txt')
//     ..click();
// }

  static void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      AppSnackbar().customizedAppSnackbar(
        message: message,
        context: context,
      ),
    );
  }

  static Stream<int> uint8ListToStream(Uint8List uint8List) {
    return Stream.fromIterable(uint8List.map((byte) => byte.toInt()));
  }

  static String generateTable(List<dynamic> result, List<dynamic> fields) {
    // Generate table headers
    String header = '';
    for (var field in fields) {
      header += '${field['name']}\t';
    }

    // Generate separator
    String separator = '';
    for (var field in fields) {
      separator += '${'-' * field['name'].toString().length}\t';
    }

    // Generate table rows
    String table = '';
    table += header + '\n';
    table += separator + '\n';
    for (var row in result) {
      String rowStr = '';
      for (var field in fields) {
        rowStr += '${row[field['name']]}\t';
      }
      table += '$rowStr\n';
    }

    return table.trim();
  }

  static String constructErrorMessage(Map<String, dynamic> responseJson) {
    String errorMessage = responseJson["message"];
    Map<String, dynamic>? error = responseJson["error"];

    if (error != null) {
      if (error.containsKey("code")) {
        errorMessage += "\nCode: ${error["code"]}";
      }
      if (error.containsKey("errno")) {
        errorMessage += "\nError No: ${error["errno"]}";
      }
      if (error.containsKey("sqlmessage")) {
        errorMessage += "\nSQL Message: ${error["sqlmessage"]}";
      }
      if (error.containsKey("sqlstate")) {
        errorMessage += "\nSQL State: ${error["sqlstate"]}";
      }
      if (error.containsKey("sql")) {
        errorMessage += "\nSQL: ${error["sql"]}";
      }
    }

    return errorMessage;
  }

  static String formatString(http.Response response) {
    Map<String, dynamic> responseJson = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (responseJson["success"]) {
        var result = responseJson["result"];

        if (result is List<dynamic>) {
          // Handle the case when result is a List<dynamic>
          List<dynamic> resultList = responseJson["result"];
          if (resultList.isEmpty) {
            return "No rows found";
          } else {
            if (responseJson['result'] != null) {
              if (responseJson['field'] != null) {
                List<dynamic> result = responseJson['result'];
                List<dynamic> fields = responseJson['field'];

                return generateTable(result, fields);
              } else {
                return responseJson['result']["message"];
              }
            }
          }
        } else if (result is Map<String, dynamic>) {
          // Handle the case when result is a Map<String, dynamic>
          // print('result is a Map<String, dynamic>');
        }
      }
    } else if (response.statusCode == 400) {
      return responseJson["message"];
    } else if (response.statusCode == 401) {
      return responseJson["message"];
    } else if (response.statusCode == 403) {
      return constructErrorMessage(responseJson);
    } else if (response.statusCode == 405) {
      return responseJson["message"];
    }
    return "";
  }

  static bool hasCommand(String prefix, String command) {
    return !command.startsWith(prefix);
  }

  static List<String>? extractVariableNames(String insertStatement) {
    final List<String> variableNames = [];
    final pattern = RegExp(r'&(\w+)');
    final matches = pattern.allMatches(insertStatement);
    for (final match in matches) {
      variableNames.add(match.group(1)!);
    }
    return variableNames.isNotEmpty ? variableNames : null;
  }

  static String validatePassword(String password) {
    // Define regular expressions to match uppercase, lowercase, number, and special character
    RegExp uppercaseRegex = RegExp(r'[A-Z]');
    RegExp lowercaseRegex = RegExp(r'[a-z]');
    RegExp numberRegex = RegExp(r'[0-9]');
    RegExp specialCharRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

    // Check if the password contains at least one uppercase character
    bool hasUppercase = uppercaseRegex.hasMatch(password);

    // Check if the password contains at least one lowercase character
    bool hasLowercase = lowercaseRegex.hasMatch(password);

    // Check if the password contains at least one number
    bool hasNumber = numberRegex.hasMatch(password);

    // Check if the password contains at least one special character
    bool hasSpecialChar = specialCharRegex.hasMatch(password);

    // Construct the validation message based on the criteria
    String message = "Password must contain";

    if (!hasUppercase) message += " at least one uppercase character,";
    if (!hasLowercase) message += " at least one lowercase character,";
    if (!hasNumber) message += " at least one number,";
    if (!hasSpecialChar) message += " at least one special character,";

    // Remove the trailing comma and add a period at the end
    message = message.replaceAll(RegExp(r',+$'), '');
    message += ".\n";

    // Return the validation message
    return message;
  }
}
