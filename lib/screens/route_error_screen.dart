import 'package:flutter/material.dart';
import 'package:sql_terminal/services/styles.dart';

class RouteErrorScreen extends StatelessWidget {
  const RouteErrorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Center(
        child: Text(
          "404 Not Found",
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
