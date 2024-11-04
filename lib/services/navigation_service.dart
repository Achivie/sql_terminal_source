// navigation_service.dart
import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<void> pushNamed(String routeName, {arguments}) async {
    await navigatorKey.currentState!.pushNamed(routeName, arguments: arguments);
  }

  Future<void> pushReplacementNamed(String routeName, {arguments}) async {
    await navigatorKey.currentState!.pushReplacementNamed(routeName);
  }

  void pop() {
    navigatorKey.currentState!.pop();
  }
}
