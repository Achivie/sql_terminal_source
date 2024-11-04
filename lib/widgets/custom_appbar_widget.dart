import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:sql_terminal/services/constants.dart';
import 'package:sql_terminal/services/storage_services.dart';

import '../models/user_model.dart';
import '../services/keys.dart';
import '../services/styles.dart';

class CustomAppBar extends StatefulWidget {
  const CustomAppBar({
    super.key,
    required this.user,
    this.head,
    this.onRefresh,
  });

  final UserModel user;
  final String? head;
  final VoidCallback? onRefresh;

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  bool isLoggingOut = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                TextButton(
                  onPressed: (() async {
                    setState(() {
                      isLoggingOut = true;
                    });
                    await StorageServices()
                        .deleteAllSharedPreferences()
                        .then((loggedOut) {
                      if (loggedOut) {
                        context
                            .go(AppKeys.authRouteKey + AppKeys.signInRouteKey);
                        AppConstants.showSnackbar(
                            context, "Successfully Logged Out");
                      } else {
                        AppConstants.showSnackbar(context, "Failed to logout");
                      }
                    });
                    setState(() {
                      isLoggingOut = false;
                    });
                  }),
                  child: Tooltip(
                    message: isLoggingOut ? "Logging out" : "Logout",
                    child: isLoggingOut
                        ? SizedBox(
                            width: 80,
                            height: 80,
                            child: Lottie.asset(
                              "assets/loading-animation.json",
                            ),
                          )
                        : Row(
                            children: [
                              Icon(
                                Icons.logout_rounded,
                                color: AppColors.white,
                              ),
                              if (MediaQuery.of(context).size.width < 450)
                                SizedBox(
                                  width: 5,
                                ),
                              if (MediaQuery.of(context).size.width < 450)
                                Text(
                                  "Logout",
                                  style: TextStyle(
                                    color: AppColors.white,
                                  ),
                                ),
                            ],
                          ),
                  ),
                ),
                if (MediaQuery.of(context).size.width > 450)
                  TextButton(
                    onPressed: widget.onRefresh,
                    child: Text(
                      widget.head ?? "Playgrounds",
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                  ),
              ],
            ),
            CustomAppBarProfileWidget(user: widget.user)
          ],
        ),
        if (MediaQuery.of(context).size.width < 700)
          SizedBox(
            height: 10,
          ),
        if (MediaQuery.of(context).size.width < 700)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Tooltip(
                message: "Your Name",
                child: Text(
                  "${widget.user.data.usrFirstName} ${widget.user.data.usrLastName}",
                  style: TextStyle(
                      color: AppColors.white, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 2,
              ),
              Tooltip(
                message: "Your Email",
                child: Text(
                  widget.user.data.usrEmail,
                  style: TextStyle(
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class CustomAppBarProfileWidget extends StatelessWidget {
  const CustomAppBarProfileWidget({
    super.key,
    required this.user,
  });

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (MediaQuery.of(context).size.width >= 700)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Tooltip(
                message: "Your Name",
                child: Text(
                  "${user.data.usrFirstName} ${user.data.usrLastName}",
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 2,
              ),
              Tooltip(
                message: "Your Email",
                child: Text(
                  user.data.usrEmail,
                  style: TextStyle(
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        if (MediaQuery.of(context).size.width >= 700)
          SizedBox(
            width: 10,
          ),
        TextButton(
          onPressed: (() {
            // context.go(AppKeys.profileWithoutUIDRouteKey);
            // DatabaseModel databaseModel = DatabaseModel(
            //     database_usrName: "achivie", database_pass: "hello");
          }),
          child: Stack(
            children: [
              Container(
                height: 55,
                width: 55,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.white,
                    width: 2,
                  ),
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(
                      user.data.usrProfilePic,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.backgroundColour,
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(
                        "https://achivie.com/img/logo.png",
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
