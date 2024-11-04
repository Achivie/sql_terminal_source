import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:sql_terminal/models/all_playgrounds_model.dart';
import 'package:sql_terminal/models/db_model.dart';
import 'package:sql_terminal/models/profile_model.dart';
import 'package:sql_terminal/services/constants.dart';
import 'package:sql_terminal/services/keys.dart';

import '../../models/user_model.dart';
import '../../screens/auth_screen.dart';
import '../../services/api_call_service.dart';
import '../../services/storage_services.dart';
import '../../services/styles.dart';
import '../../utils/auth_custom_button.dart';
import '../../widgets/custom_appbar_widget.dart';
import '../../widgets/custom_playground_widget.dart';

class TabletLayout extends StatefulWidget {
  const TabletLayout({super.key, required this.user});

  final UserModel user;

  @override
  State<TabletLayout> createState() => _TabletLayoutState();
}

class _TabletLayoutState extends State<TabletLayout> {
  bool isLoadingPlaygrounds = false,
      isLoadingDb = false,
      isSubmitting = false,
      isLoadingMore = false,
      isRefreshWarn = true;
  DbModel? database;
  int page = 1, limit = 20, maxPages = 0;
  List<Playground> playgrounds = [];
  late ScrollController scrollController;

  getData() async {
    // playgrounds =
    // playgrounds.sort((a, b) => b.lastEdited.compareTo(a.lastEdited));
    setState(() {
      isLoadingPlaygrounds = true;
      isLoadingDb = true;
    });

    final newDB = await StorageServices().readDatabaseDetails();

    if (newDB != null) {
      database = newDB;
    }
    // log(database!.databasePass);

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
          // log("message");
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
        floatingActionButton: isSubmitting
            ? SizedBox(
                width: 50,
                height: 50,
                child: Lottie.asset(
                  "assets/loading-animation.json",
                ),
              )
            : FloatingActionButton(
                onPressed: (() {
                  setState(() {
                    isSubmitting = true;
                  });
                  TextEditingController _didController =
                      TextEditingController();

                  TextEditingController _databasePassController =
                      TextEditingController();
                  TextEditingController _playgroundNameController =
                      TextEditingController();
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: ((ctx) {
                      return CustomModalSheet(
                        didController: _didController,
                        playgroundNameController: _playgroundNameController,
                        databasePassController: _databasePassController,
                        ctx: ctx,
                        uid: widget.user.data.uid,
                        database_pass: database!.databasePass,
                        did: database!.did,
                        usrEmail: widget.user.data.usrEmail,
                        usrFirstName: widget.user.data.usrFirstName,
                        usrLastName: widget.user.data.usrLastName,
                      );
                    }),
                  ).then((valJson) async {
                    // log(val.toString());
                    if (valJson != null) {
                      // Map<String, dynamic> valJson = jsonDecode(val);
                      http.Response res =
                          await APICallServices.createPlayground(
                        token: widget.user.token,
                        uid: widget.user.data.uid,
                        p_name: valJson[AppKeys.p_name],
                        did: valJson[AppKeys.did],
                        database_pass: valJson[AppKeys.database_pass],
                        usrFirstName: widget.user.data.usrFirstName,
                        usrLastName: widget.user.data.usrLastName,
                        usrEmail: widget.user.data.usrEmail,
                      );
                      Map<String, dynamic> resJson = jsonDecode(res.body);

                      if (res.statusCode == 200) {
                        if (resJson["success"]) {
                          AppConstants.showSnackbar(
                              context, resJson["message"]);
                        } else {
                          AppConstants.showSnackbar(
                              context, resJson["message"]);
                        }
                      } else {
                        AppConstants.showSnackbar(context, resJson["message"]);
                      }
                    }

                    _didController.dispose();
                    _databasePassController.dispose();
                    _playgroundNameController.dispose();

                    setState(() {
                      isSubmitting = false;
                    });

                    await getData();
                  });
                }),
                backgroundColor: AppColors.backgroundColour,
                child: Center(
                  child: Icon(
                    Icons.add,
                    color: AppColors.white,
                    size: 25,
                  ),
                ),
              ),
        body: RefreshIndicator(
            onRefresh: (() async {
              await getData();
            }),
            child: Stack(
              children: [
                Padding(
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
                          onRefresh: (() async {
                            await getData();
                          }),
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

                                  Map<String, dynamic> resJson =
                                      jsonDecode(res.body);

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
                                        databasePass:
                                            profile.profile.databasePass,
                                        dbCreatedTime:
                                            profile.profile.dbCreatedTime,
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
                                      usrFirstName:
                                          widget.user.data.usrFirstName,
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
                        const SliverToBoxAdapter(
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

                                Map<String, dynamic> resJson =
                                    jsonDecode(res.body);

                                print(resJson.toString());

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
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                MediaQuery.of(context).size.width <= 640
                                    ? 2
                                    : MediaQuery.of(context).size.width >= 840
                                        ? 4
                                        : 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                        ),
                      if (isLoadingMore)
                        const SliverToBoxAdapter(
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.backgroundColour,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (isRefreshWarn)
                  Positioned(
                    top: 80,
                    left: 80,
                    child: Container(
                      width: MediaQuery.of(context).size.width / 2,
                      height: MediaQuery.of(context).size.height / 2,
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: AppColors.white, width: 1),
                          left: BorderSide(color: AppColors.white, width: 1),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.black.withOpacity(0.8),
                            AppColors.black.withOpacity(0.5),
                            AppColors.grey,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Lottie.asset("assets/warning-animation.json",
                                  width: MediaQuery.of(context).size.width / 4,
                                  height:
                                      MediaQuery.of(context).size.height / 4),
                              Text(
                                'Do not refresh the page\nJust tap the \"Playgrounds"',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 22,
                                ),
                              ),
                            ],
                          ),
                          Transform.rotate(
                            angle:
                                90 * (pi / 180), // Convert degrees to radians
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color: AppColors.white,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              // height: 45,
                              // width: 45,
                              padding: EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.black,
                              ),
                              child: Center(
                                child: IconButton(
                                  onPressed: (() {
                                    setState(() {
                                      isRefreshWarn = false;
                                    });
                                  }),
                                  icon: Icon(
                                    Icons.close,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            )),
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

class CustomModalSheet extends StatefulWidget {
  const CustomModalSheet({
    super.key,
    required TextEditingController didController,
    required TextEditingController playgroundNameController,
    required TextEditingController databasePassController,
    required this.ctx,
    required this.uid,
    required this.did,
    required this.database_pass,
    required this.usrFirstName,
    required this.usrLastName,
    required this.usrEmail,
  })  : _playgroundNameController = playgroundNameController,
        _databasePassController = databasePassController,
        _didController = didController;

  final TextEditingController _playgroundNameController;
  final TextEditingController _didController;
  final TextEditingController _databasePassController;
  final BuildContext ctx;
  final String uid, did, database_pass, usrFirstName, usrLastName, usrEmail;

  @override
  State<CustomModalSheet> createState() => _CustomModalSheetState();
}

class _CustomModalSheetState extends State<CustomModalSheet> {
  bool myDB = true, isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 1.5,
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
        top: 15,
        bottom: 15,
      ),
      decoration: BoxDecoration(
        color: AppColors.black,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: (() {
                  Navigator.pop(widget.ctx);
                }),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 30,
              bottom: 10,
              right: 15,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CupertinoSwitch(
                    value: myDB,
                    onChanged: ((val) {
                      setState(() {
                        myDB = val;
                      });
                    })),
                SizedBox(
                  width: 10,
                ),
                Text(
                  "My Database",
                  style: TextStyle(
                    color: myDB
                        ? AppColors.white
                        : AppColors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          CustomTextFormField(
            hint: "Playground Name",
            textEditingController: widget._playgroundNameController,
            obscure: false,
          ),
          if (!myDB)
            SizedBox(
              height: 10,
            ),
          if (!myDB)
            CustomTextFormField(
              hint: "Database ID",
              textEditingController: widget._didController,
              obscure: false,
            ),
          if (!myDB)
            SizedBox(
              height: 10,
            ),
          if (!myDB)
            CustomTextFormField(
              hint: "Database Password",
              textEditingController: widget._databasePassController,
              obscure: false,
            ),
          SizedBox(
            height: 10,
          ),
          CustomButton(
            onTap: (() {
              // log((!myDB && widget._didController.text.trim().isNotEmpty)
              //     .toString());
              if (widget._playgroundNameController.text.trim().isNotEmpty &&
                  ((!myDB &&
                          widget._databasePassController.text
                              .trim()
                              .isNotEmpty &&
                          widget._didController.text.trim().isNotEmpty) ||
                      myDB)) {
                Navigator.pop(context, {
                  AppKeys.p_name: widget._playgroundNameController.text.trim(),
                  AppKeys.did:
                      myDB ? widget.did : widget._didController.text.trim(),
                  AppKeys.database_pass: myDB
                      ? widget.database_pass
                      : widget._databasePassController.text.trim()
                });
              }
            }),
            head: "Connect",
          ),
        ],
      ),
    );
  }
}
