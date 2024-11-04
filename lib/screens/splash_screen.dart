import 'dart:async';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sql_terminal/services/keys.dart';
import 'package:sql_terminal/services/storage_services.dart';
import 'package:sql_terminal/services/styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // NavigationService? navigationService;

  @override
  void initState() {
    Timer(
      const Duration(seconds: 2),
      () {
        route();
        // Beamer.of(context).beamToReplacementNamed(
        //     AppKeys.authRouteKey + AppKeys.signInRouteKey);
      },
    );
    super.initState();
  }

  route() async {
    await StorageServices().readUserData().then((user) {
      if (user != null) {
        // GoRouter.of(context)
        //     .go("/${user.data.uid}${AppKeys.playgroundsWithoutIDRouteKey}");

        // navigationService!.pushReplacementNamed(
        //     "/${user.data.uid}${AppKeys.playgroundsWithoutIDRouteKey}");

        FluroRouter.appRouter.navigateTo(context,
            "/${user.data.uid}${AppKeys.playgroundsWithoutIDRouteKey}");

        // Navigator.pushReplacementNamed(context,
        //     "/${user.data.uid}${AppKeys.playgroundsWithoutIDRouteKey}");
        // context.go("/${user.data.uid}${AppKeys.playgroundsWithoutIDRouteKey}");
      } else {
        // FluroRouter.appRouter
        //     .navigateTo(context, AppKeys.authRouteKey + AppKeys.signInRouteKey);

        // navigationService!.pushReplacementNamed(
        //     AppKeys.authRouteKey + AppKeys.signInRouteKey);

        Navigator.pushReplacementNamed(
            context, AppKeys.authRouteKey + AppKeys.signInRouteKey);
        // GoRouter.of(context).go(AppKeys.authRouteKey + AppKeys.signInRouteKey);

        // context.go(AppKeys.authRouteKey + AppKeys.signInRouteKey);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // navigationService = Provider.of<NavigationService>(context, listen: false);
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: SizedBox(
              height: 300,
              width: 300,
              child: Lottie.asset(
                "assets/splash-screen-animation.json",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
