import 'package:flutter/material.dart';
import 'package:sql_terminal/services/constants.dart';

class PlaygroundWidgetProvider extends ChangeNotifier {
  String _lastEdited = "";

  String get lastEdited => _lastEdited;

  void getLastEdited(DateTime dateTime) {
    _lastEdited = AppConstants.lastEditedString(dateTime);
    notifyListeners();
  }
}
