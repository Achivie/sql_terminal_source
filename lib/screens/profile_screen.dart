import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:sql_terminal/models/db_model.dart';
import 'package:sql_terminal/models/user_model.dart';
import 'package:sql_terminal/services/api_call_service.dart';
import 'package:sql_terminal/services/storage_services.dart';
import 'package:sql_terminal/services/styles.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? user;
  DbModel? db;
  int usrCompletionRate = 0;
  bool isUserLoading = false, isDBLoading = false;
  ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    setState(() {
      isUserLoading = true;
      isDBLoading = true;
    });
    user = await StorageServices().readUserData();
    db = await StorageServices().readDatabaseDetails();
    if (user != null) {
      usrCompletionRate = await APICallServices.getCompletionRate(
          uid: user!.data.uid, token: user!.token);
    }
    setState(() {
      isUserLoading = false;
      isDBLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (user != null) {
      return Scaffold(
        backgroundColor: AppColors.black,
        appBar: AppBar(
          backgroundColor: AppColors.black,
          elevation: 0,
          centerTitle: true,
          title: Center(
            child: Text(
              "Profile",
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(maxWidth: 500),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Screenshot(
                      controller: screenshotController,
                      child: Container(
                        constraints: BoxConstraints(maxWidth: 450),

                        padding: const EdgeInsets.only(
                          top: 20,
                          bottom: 20,
                        ),
                        margin: const EdgeInsets.only(
                          right: 10,
                          left: 10,
                        ),
                        // width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.white,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (user!.data.usrProfilePic.isNotEmpty)
                              Column(
                                children: [
                                  CircleAvatar(
                                    foregroundImage: NetworkImage(
                                      user!.data.usrProfilePic,
                                    ),
                                    backgroundColor: AppColors.backgroundColour,
                                    radius: 50,
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  if (usrCompletionRate <= 25)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 15,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.red,
                                            AppColors.orange,
                                          ],
                                        ),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          "Silver",
                                          style: TextStyle(
                                            color: AppColors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (usrCompletionRate > 25 &&
                                      usrCompletionRate <= 50)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 15,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.goldDark,
                                            AppColors.gold,
                                          ],
                                        ),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          "Gold",
                                          style: TextStyle(
                                            color: AppColors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (usrCompletionRate > 50 &&
                                      usrCompletionRate <= 100)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 15,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        gradient: const LinearGradient(
                                          colors: [
                                            AppColors.diamondDark,
                                            AppColors.diamond,
                                          ],
                                        ),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          "Diamond",
                                          style: TextStyle(
                                            color: AppColors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            if (user!.data.usrProfilePic.isEmpty)
                              Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.backgroundColour,
                                ),
                              ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${user!.data.usrFirstName} ${user!.data.usrLastName}",
                                  style: TextStyle(
                                    color: AppColors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  user!.data.usrDescription,
                                  style: TextStyle(
                                    overflow: TextOverflow.clip,
                                    color: AppColors.black.withOpacity(0.7),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    if (user!.data.usrEmail.length >
                                        (MediaQuery.of(context).size.height /
                                                25)
                                            .round())
                                      Icon(
                                        Icons.email,
                                        color: AppColors.black,
                                        size: 20,
                                      ),
                                    if (user!.data.usrEmail.length >
                                        (MediaQuery.of(context).size.height /
                                                25)
                                            .round())
                                      const SizedBox(
                                        width: 5,
                                      ),
                                    SizedBox(
                                      width: (user!.data.usrEmail.length >
                                              (MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                      20)
                                                  .round())
                                          ? MediaQuery.of(context).size.width /
                                              2.5
                                          : null,
                                      child: Text(
                                        user!.data.usrEmail,
                                        style: TextStyle(
                                          fontSize: 12,
                                          overflow: TextOverflow.clip,
                                          color:
                                              AppColors.black.withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  user!.data.usrProfession,
                                  style: TextStyle(
                                    overflow: TextOverflow.clip,
                                    color: AppColors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Completion rate: ",
                                      style: TextStyle(
                                        color: AppColors.black.withOpacity(0.6),
                                      ),
                                    ),
                                    if (usrCompletionRate <= 25)
                                      Text(
                                        "${usrCompletionRate.toString()}%",
                                        style: const TextStyle(
                                          color: AppColors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    if (usrCompletionRate > 25 &&
                                        usrCompletionRate <= 50)
                                      Text(
                                        "${usrCompletionRate.toString()}%",
                                        style: TextStyle(
                                          color: AppColors.orange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    if (usrCompletionRate > 50 &&
                                        usrCompletionRate <= 100)
                                      Text(
                                        "${usrCompletionRate.toString()}%",
                                        style: TextStyle(
                                          color: AppColors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 10,
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                        "https://achivie.com/img/logo.png",
                                      ),
                                    ),
                                    SizedBox(
                                      width: 7,
                                    ),
                                    Center(
                                      child: Text(
                                        "achivie.com",
                                        style: TextStyle(
                                          color: AppColors.black,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    if (db != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              "Database Details",
                              style: TextStyle(color: AppColors.white),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } else if (!isUserLoading && !isDBLoading) {
      return const Scaffold(
        backgroundColor: AppColors.black,
      );
    } else {
      return const Scaffold(
        backgroundColor: AppColors.black,
      );
    }
  }
}
