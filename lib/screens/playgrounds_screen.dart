import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sql_terminal/layouts/playgrounds/desktop_layout.dart';
import 'package:sql_terminal/services/constants.dart';
import 'package:sql_terminal/services/keys.dart';
import 'package:sql_terminal/services/styles.dart';
import 'package:sql_terminal/utils/auth_custom_button.dart';

import '../layouts/playgrounds/layout_builder.dart';
import '../layouts/playgrounds/mobile_layout.dart';
import '../layouts/playgrounds/tablet_layout.dart';
import '../models/user_model.dart';

class PlaygroundsScreen extends StatefulWidget {
  const PlaygroundsScreen({super.key});

  @override
  State<PlaygroundsScreen> createState() => _PlaygroundsScreenState();
}

class _PlaygroundsScreenState extends State<PlaygroundsScreen> {
  UserModel? user;

  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    user = await AppConstants.getUserData();
    if (user == null) {}
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (user != null) {
      return PlaygroundsResponsiveLayoutBuilder(
        mobileScaffold: MobileLayout(
          user: user!,
        ),
        tabletScaffold: TabletLayout(
          user: user!,
        ),
        desktopScaffold: DesktopLayout(
          user: user!,
        ),
      ).build(context);
    } else {
      return Scaffold(
        backgroundColor: AppColors.black,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Text(
                "You are not signed In",
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Center(
              child: CustomButton(
                onTap: (() {
                  GoRouter.of(context)
                      .go(AppKeys.authRouteKey + AppKeys.signInRouteKey);
                }),
                head: "Sign In",
              ),
            )
          ],
        ),
      );
    }
  }
}
