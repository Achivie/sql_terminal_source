import 'package:flutter/cupertino.dart';

class RouteProvider extends ChangeNotifier {
  Map<String, String> _params = {"": ""};

  Map<String, String> get params => _params;

  void getParams(Map<String, String> param) {
    _params = param;
    notifyListeners();
  }
}
