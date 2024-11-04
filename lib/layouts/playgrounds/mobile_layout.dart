import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:sql_terminal/models/db_model.dart';
import 'package:sql_terminal/services/api_call_service.dart';
import 'package:sql_terminal/services/storage_services.dart';

import '../../models/all_playgrounds_model.dart';
import '../../models/profile_model.dart';
import '../../models/user_model.dart';
import '../../services/constants.dart';
import '../../services/styles.dart';
import '../../utils/auth_custom_button.dart';
import '../../widgets/custom_appbar_widget.dart';
import '../../widgets/custom_playground_widget.dart';

class MobileLayout extends StatefulWidget {
  const MobileLayout({super.key, required this.user});

  final UserModel user;

  @override
  State<MobileLayout> createState() => _MobileLayoutState();
}

class _MobileLayoutState extends State<MobileLayout> {
  bool isLoadingPlaygrounds = false, isLoadingDb = false, isLoadingMore = false;
  DbModel? database;
  int page = 1, limit = 12, maxPages = 0;
  List<Playground> playgrounds = [];
  late ScrollController scrollController;

  getData() async {
    // playgrounds =
    // playgrounds.sort((a, b) => b.lastEdited.compareTo(a.lastEdited));
    setState(() {
      isLoadingPlaygrounds = true;
      isLoadingDb = true;
    });

    database = await StorageServices().readDatabaseDetails();

    setState(() {
      isLoadingDb = false;
    });

    final newPlaygrounds =
        await getAllPlaygrounds(widget.user.data.uid, page, limit);

    if (newPlaygrounds != null) {
      // for (var playground in newPlaygrounds) {
      //   playgrounds.add(playground);
      // }
      playgrounds = newPlaygrounds;
      playgrounds.sort((a, b) => b.pLastEdited.compareTo(a.pLastEdited));
    }

    setState(() {
      isLoadingPlaygrounds = false;
    });
  }

  Future<void> fetchPlaygrounds() async {
    if (page <= maxPages) {
      page = page + 1;
      final res = await APICallServices.getPlaygrounds(
          token: widget.user.token,
          uid: widget.user.data.uid,
          page: page,
          limit: limit);

      Map<String, dynamic> resJson = jsonDecode(res.body);

      if (res.statusCode == 200) {
        if (resJson["success"]) {
          log("message");
          playgrounds.addAll(AllPlaygroundsModel.fromJson(resJson).playgrounds);
          playgrounds.sort((a, b) => b.pLastEdited.compareTo(a.pLastEdited));
          // Set<Playground> uniquePlaygrounds = playgrounds.toSet();
          // playgrounds = uniquePlaygrounds.toList();
          setState(() {
            // page++;
          });
        }
      }
    }
  }

  Future<List<Playground>?> getAllPlaygrounds(
      String uid, int selectedPage, int selectedLimit) async {
    final res = await APICallServices.getPlaygrounds(
        token: widget.user.token,
        uid: widget.user.data.uid,
        page: page,
        limit: limit);

    Map<String, dynamic> resJson = jsonDecode(res.body);

    if (res.statusCode == 200) {
      if (resJson["success"]) {
        setState(() {
          maxPages = resJson["totalPages"];
        });
        return AllPlaygroundsModel.fromJson(resJson).playgrounds;
      }
    }
    return null;
  }

  @override
  void initState() {
    scrollController = ScrollController();
    scrollController.addListener(_scrollListener);
    getData();
    super.initState();
  }

  Future<void> _scrollListener() async {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      setState(() {
        isLoadingMore = true;
      });
      // page++;
      await fetchPlaygrounds();

      setState(() {
        isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoadingDb) {
      return Scaffold(
        backgroundColor: AppColors.black,
        body: RefreshIndicator(
          onRefresh: (() async {
            await getData();
          }),
          child: Padding(
            padding: const EdgeInsets.only(
              top: 15,
              bottom: 15,
              left: 15,
              right: 15,
            ),
            child: CustomScrollView(
              controller: scrollController,
              physics: BouncingScrollPhysics(),
              slivers: [
                // SliverToBoxAdapter(
                //   child: Text(
                //     MediaQuery.of(context).size.width.toString(),
                //     style: TextStyle(
                //       color: AppColors.white,
                //     ),
                //   ),
                // ),
                SliverToBoxAdapter(
                  child: CustomAppBar(
                    user: widget.user,
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 15,
                  ),
                ),
                if (database == null && !isLoadingPlaygrounds)
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Text(
                          "You don't have any Database Created",
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        CustomButton(
                          onTap: (() async {
                            setState(() {
                              isLoadingDb = true;
                            });
                            final http.Response res =
                                await APICallServices.getProfile(
                                    token: widget.user.token,
                                    context: context,
                                    uid: widget.user.data.uid);

                            Map<String, dynamic> resJson = jsonDecode(res.body);

                            // print(profile.profile.usrEmail);

                            if (res.statusCode == 200) {
                              if (resJson["success"]) {
                                ProfileModel profile =
                                    ProfileModel.fromJson(resJson);

                                final db = DbModel(
                                  uid: profile.profile.uid,
                                  did: profile.profile.did,
                                  databaseUsrName:
                                      profile.profile.databaseUsrName,
                                  databasePass: profile.profile.databasePass,
                                  dbCreatedTime: profile.profile.dbCreatedTime,
                                  dbLastConnected:
                                      profile.profile.dbLastConnected,
                                );

                                StorageServices()
                                    .saveDatabaseDetails(db)
                                    .whenComplete(() {
                                  database = db;
                                });
                              } else {
                                AppConstants.showSnackbar(
                                    context, resJson["message"]);
                              }
                            } else if (res.statusCode == 404) {
                              http.Response createdDB =
                                  await APICallServices.createDatabase(
                                token: widget.user.token,
                                context: context,
                                uid: widget.user.data.uid,
                                database_usrName:
                                    "db_achivie_${widget.user.data.uid}",
                                database_pass:
                                    "India_Achivie_${DateTime.now().year}",
                                usrFirstName: widget.user.data.usrFirstName,
                                usrLastName: widget.user.data.usrLastName,
                                usrEmail: widget.user.data.usrEmail,
                              );

                              Map<String, dynamic> createdDBJson =
                                  jsonDecode(createdDB.body);

                              if (createdDB.statusCode == 200) {
                                if (createdDBJson["success"]) {
                                  final db = DbModel.fromJson(
                                      createdDBJson["database"]);
                                  StorageServices()
                                      .saveDatabaseDetails(db)
                                      .whenComplete(() {
                                    database = db;
                                  });
                                } else {
                                  AppConstants.showSnackbar(
                                      context, createdDBJson["message"]);
                                }
                              } else {
                                AppConstants.showSnackbar(
                                    context, createdDBJson["message"]);
                              }

                              // log(database.toString());
                            } else {
                              AppConstants.showSnackbar(
                                  context, resJson["message"]);
                            }

                            setState(() {
                              isLoadingDb = false;
                            });
                          }),
                          head: "Create",
                        ),
                      ],
                    ),
                  ),
                if ((database == null || database != null) &&
                    isLoadingPlaygrounds)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: Lottie.asset(
                        "assets/loading-animation.json",
                      ),
                    ),
                  ),
                if (database != null && playgrounds.isEmpty)
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Text(
                          "You don't have any Playgrounds",
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (database != null)
                  SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => CustomPlaygroundWidget(
                        user: widget.user,
                        playground: playgrounds[index],
                        onDeleteTap: () async {
                          setState(() {
                            isLoadingPlaygrounds = true;
                          });
                          http.Response res =
                              await APICallServices.deletePlayground(
                            token: widget.user.token,
                            uid: widget.user.data.uid,
                            did: playgrounds[index].did,
                            pid: playgrounds[index].pid,
                            p_name: playgrounds[index].pName,
                            database_pass: database!.databasePass,
                            usrFirstName: widget.user.data.usrFirstName,
                            usrLastName: widget.user.data.usrLastName,
                            usrEmail: widget.user.data.usrEmail,
                          );

                          Map<String, dynamic> resJson = jsonDecode(res.body);

                          if (res.statusCode == 200) {
                            if (resJson["success"]) {
                              page = 1;
                            } else {
                              AppConstants.showSnackbar(
                                  context, resJson["message"]);
                            }
                          } else {
                            AppConstants.showSnackbar(
                                context, resJson["message"]);
                          }
                          await getData();

                          setState(() {
                            isLoadingPlaygrounds = false;
                          });
                        },
                      ),
                      childCount: playgrounds.length,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          MediaQuery.of(context).size.width <= 430 ? 1 : 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                  ),
                if (isLoadingMore)
                  SliverToBoxAdapter(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.backgroundColour,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: AppColors.black,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: Lottie.asset(
                "assets/loading-animation.json",
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Center(
              child: Text(
                "Fetching your database details",
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
