import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:download/download.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:screenshot/screenshot.dart';
import 'package:sql_terminal/models/db_model.dart';
import 'package:sql_terminal/services/api_call_service.dart';
import 'package:sql_terminal/services/constants.dart';
import 'package:sql_terminal/services/encryption_service.dart';
import 'package:sql_terminal/services/styles.dart';

import '../models/all_playgrounds_model.dart';
import '../models/user_model.dart';
import '../services/keys.dart';
import '../widgets/custom_appbar_widget.dart';
import '../widgets/custom_playgroun_screen_widgets.dart';

class PlaygroundScreen extends StatefulWidget {
  const PlaygroundScreen({super.key});

  @override
  State<PlaygroundScreen> createState() => _PlaygroundScreenState();
}

class _PlaygroundScreenState extends State<PlaygroundScreen> {
  UserModel? user;

  // String command = "";
  String prefix = "";
  String result = "";
  bool isExecuting = false,
      isConnected = false,
      isConnecting = false,
      isPlaygroundLoading = false,
      isOptionsVisible = false;
  List<String> commands = [];
  int commandIndex = 0;
  late FocusNode _focusNode;
  late ScrollController _scrollController;
  late TextEditingController _commandController;
  Playground? playground;
  Map<String, String> params = {"": ""};
  DbModel? db;
  double _previousScrollOffset = 0.0;
  late ScreenshotController screenshotController;

  // late PlaygroundModel playground;

  getData() async {
    user = await AppConstants.getUserData();
    prefix =
        "${AppConstants.takeFirstWord(user!.data.usrFirstName.toLowerCase())}@achivie:${db != null ? db!.databaseUsrName : ""}>";
    result = "";
    params =
        GoRouter.of(context).routerDelegate.currentConfiguration.pathParameters;
    setState(() {
      isPlaygroundLoading = true;
    });
    await getPlayground(EncryptionService.decrypt(params[AppKeys.uid]!),
        EncryptionService.decrypt(params[AppKeys.pid]!));
    if (playground != null) {
      result = playground!.commands;
    }
    setState(() {
      isPlaygroundLoading = false;
    });
    // log(params.toString());
    setState(() {});
  }

  String convertToMysql(String oracleSql) {
    // Replace Oracle-specific data types with MySQL equivalents
    String sql = oracleSql.replaceAll(
        RegExp(r"\bNUMBER\(\d+,\d+\)", caseSensitive: false),
        'DECIMAL'); // NUMBER -> DECIMAL
    sql = sql.replaceAll(RegExp(r"\bNUMBER", caseSensitive: false),
        'INT'); // NUMBER without precision -> INT

    sql = sql.replaceAllMapped(
        RegExp(r"\bNCHAR2\((\d+)\)", caseSensitive: false),
        (match) => 'varchar(${match.group(1)})');
    sql = sql.replaceAllMapped(
        RegExp(r"\bNVARCHAR2\((\d+)\)", caseSensitive: false),
        (match) => 'varchar(${match.group(1)})');
    sql = sql.replaceAllMapped(
        RegExp(r"\bVARCHAR2\((\d+)\)", caseSensitive: false),
        (match) => 'varchar(${match.group(1)})');
    sql = sql.replaceAllMapped(RegExp(r"\bRAW\((\d+)\)", caseSensitive: false),
        (match) => 'binary(${match.group(1)})');

    sql = sql.replaceAll(
        RegExp(r"\bCLOB", caseSensitive: false), 'text'); // CLOB -> TEXT
    sql = sql.replaceAll(
        RegExp(r"\bNCLOB", caseSensitive: false), 'text'); // NCLOB -> TEXT

    // sql = sql.replaceAll(RegExp(r"\bRAW\(\d+\)", caseSensitive: false),
    //     'binary'); // RAW -> BINARY
    sql = sql.replaceAll(RegExp(r"\bLONG RAW", caseSensitive: false),
        'blob'); // LONG RAW -> BLOB

    // Unsupported data types (consider manual conversion or omitting)
    // - ROWID (Oracle-specific for row identification)
    // - BFILE (Oracle-specific for external file references)
    // - User-defined data types (UDTs)

    return sql;
  }

  Future<void> execute(String userCommand) async {
    if (db != null) {
      if (userCommand.isNotEmpty) {
        isExecuting = true;
        setState(() {});
        userCommand = convertToMysql(userCommand).trim();
        commands.add(_commandController.text.trim());
        commandIndex = commands.length - 1;
        // EXECUTION DONE FROM API

        // log(db!.databasePass);

        http.Response res = await APICallServices.execute(
            token: user!.token,
            uid: EncryptionService.decrypt(params[AppKeys.uid]!),
            did: playground!.did,
            pid: playground!.pid,
            database_usrName: db!.databaseUsrName,
            database_pass: db!.databasePass,
            command: userCommand);

        // print(res.body);

        final String newResult = AppConstants.formatString(res);

        result =
            "${result.trim()}\n${prefix.trim()} ${_commandController.text.trim()}\n\n ${newResult.trim()}\n\n";

        http.Response lastEditedRes = await APICallServices.updateLastEdited(
            token: user!.token,
            uid: playground!.uid,
            did: playground!.did,
            pid: playground!.pid,
            commands: result);

        Map<String, dynamic> lastEditedResJson = jsonDecode(lastEditedRes.body);

        if (lastEditedRes.statusCode == 200) {
          if (lastEditedResJson["success"]) {
            result = lastEditedResJson["playground"]["commands"];
            playground = Playground.fromJson(lastEditedResJson["playground"]);
          } else {
            AppConstants.showSnackbar(context, lastEditedResJson["message"]);
          }
        } else {
          AppConstants.showSnackbar(context, lastEditedResJson["message"]);
        }

        _commandController.clear();
        isExecuting = false;
        setState(() {});
        // log(_scrollController.position.maxScrollExtent.toString());
        // log(_scrollController.position.toString());

        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );

        // if (_scrollController.position.pixels !=
        //     _scrollController.position.maxScrollExtent) {
        //   _scrollController.animateTo(
        //     _scrollController.position.maxScrollExtent + 50,
        //     duration: Duration(milliseconds: 500),
        //     curve: Curves.easeInOut,
        //   );
        // } else {
        //   _scrollController.animateTo(
        //     _scrollController.position.maxScrollExtent + 30,
        //     duration: Duration(milliseconds: 500),
        //     curve: Curves.easeInOut,
        //   );
        // }
      } else {
        AppConstants.showSnackbar(
          context,
          "Please give a command",
        );
      }
    } else {
      AppConstants.showSnackbar(
        context,
        "Please connect your database first",
      );
    }
  }

  Future<dynamic> getPlayground(String? uid, String? pid) async {
    if (playground == null && (uid != null && pid != null)) {
      http.Response res = await APICallServices.getPlayground(
        uid: uid,
        pid: pid,
        token: user!.token,
      );
      Map<String, dynamic> resJson = jsonDecode(res.body);
      if (res.statusCode == 200) {
        if (resJson["success"]) {
          playground = Playground.fromJson(resJson["playground"]);
        } else {
          AppConstants.showSnackbar(context, resJson["message"]);
        }
      } else {
        AppConstants.showSnackbar(context, resJson["message"]);
      }
    }
  }

  @override
  void initState() {
    getData();
    screenshotController = ScreenshotController();
    _focusNode = FocusNode();
    _scrollController = ScrollController();
    _commandController = TextEditingController();
    _commandController.addListener(() {
      setState(() {});
    });
    _scrollController.addListener(() {
      // log(_scrollController.offset.toString());
      if ((_scrollController.offset >= 10 && _scrollController.offset <= 200) &&
          (_scrollController.offset > _previousScrollOffset)) {
        // Scrolling down
        setState(() {
          isOptionsVisible = true;
        });
      } else if ((_scrollController.offset >= 10 &&
              _scrollController.offset <= 200) &&
          (_scrollController.offset < _previousScrollOffset)) {
        // Scrolling up
        setState(() {
          isOptionsVisible = false;
        });
      }

      _previousScrollOffset = _scrollController.offset;
      // log(_scrollController.position.pixels.toString());
    });
    super.initState();
  }

  @override
  void dispose() {
    commands.clear();
    _focusNode.dispose();
    _scrollController.dispose();
    _commandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final params =
    //     GoRouter.of(context).routerDelegate.currentConfiguration.pathParameters;
    // log(params.toString());
    if (user != null && playground != null) {
      return MouseRegion(
        // cursor: SystemMouseCursors.text,
        child: RawKeyboardListener(
          autofocus: true,
          focusNode: FocusNode(),
          onKey: ((event) {
            // if (event.i) {
            if (event is RawKeyDownEvent) {
              // if (event.isKeyPressed(LogicalKeyboardKey.backspace)) {
              //   command = AppConstants.removeLastLetter(command);
              // }

              // if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              // } else
              // if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              //   String newCommand =
              //       AppConstants.getMostRecentCommand(commands, command);
              //   command = "";
              //   command = newCommand;
              //   setState(() {});
              // } else
              if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                if (commandIndex > 0) {
                  _commandController.text = commands[
                      --commandIndex]; // Pre-decrement before accessing the element
                } else {
                  commandIndex = 0;
                  _commandController.text = commands[commandIndex];
                }
                log("$commandIndex up");
              } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                if (commandIndex < commands.length - 1) {
                  _commandController.text = commands[
                      ++commandIndex]; // Pre-increment before accessing the element
                } else {
                  commandIndex = commands.length - 1;
                  _commandController.text = commands[commandIndex];
                }
                log("$commandIndex down");
              }

              // if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
              //   if (hasCommand(prefix, _commandController.text.trim())) {
              //     execute(_commandController.text.trim());
              //     _scrollController.animateTo(
              //       _scrollController.position.maxScrollExtent,
              //       duration: Duration(milliseconds: 500),
              //       curve: Curves.easeOut,
              //     );
              //   }
              // }

              // String keyLabel = event.logicalKey.keyLabel;
              // if (keyLabel != null &&
              //     keyLabel.length == 1 &&
              //     !keyLabel.startsWith(new RegExp(r'[a-zA-Z0-9]'))) {
              //   _commandController.text += event.data.keyLabel.toString();
              // }

              // if ((event.logicalKey.keyId >= LogicalKeyboardKey.keyA.keyId &&
              //         event.logicalKey.keyId <=
              //             LogicalKeyboardKey.keyZ.keyId) ||
              //     (event.logicalKey.keyId >= LogicalKeyboardKey.digit1.keyId &&
              //         event.logicalKey.keyId <=
              //             LogicalKeyboardKey.digit9.keyId)) {
              //   command += event.data.keyLabel.toString();
              // }

              // log(event.data.keyLabel.toString());

              setState(() {});
            }
          }),
          child: Scaffold(
            backgroundColor: AppColors.black,
            body: Stack(
              children: [
                Screenshot(
                  controller: screenshotController,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 15,
                      left: 15,
                      right: 15,
                      bottom: 15,
                    ),
                    child: CustomScrollView(
                      controller: _scrollController,
                      physics: BouncingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Playground",
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                    ),
                                  ),
                                  CustomAppBarProfileWidget(user: user!),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    "Playground Name: ",
                                    style: TextStyle(
                                      color: AppColors.white.withOpacity(0.7),
                                    ),
                                  ),
                                  Expanded(
                                    child: SelectableText(
                                      playground?.pName ?? "playgroundName",
                                      style: TextStyle(
                                        overflow: TextOverflow.clip,
                                        color: AppColors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Container(
                            height: double.infinity,
                            width: double.infinity,
                            margin: EdgeInsets.only(top: 15),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DatabaseDetailsContainer(
                                  onImageTap: (() async {
                                    final image =
                                        await screenshotController.capture();
                                    if (image != null) {
                                      final stream =
                                          AppConstants.uint8ListToStream(image);
                                      download(stream,
                                              "${playground!.pName}-${db != null ? "${db!.databaseUsrName}-" : ""}${DateTime.now().millisecondsSinceEpoch}.png")
                                          .whenComplete(() {
                                        AppConstants.showSnackbar(context,
                                            "Image saved to your device");
                                      });
                                    }
                                    // log(image.toString());
                                  }),
                                  db: db,
                                  playground: playground!,
                                  isExecuting: isExecuting,
                                  isConnected: isConnected,
                                  text: result,
                                  isConnecting: isConnecting,
                                  onConnectTap: (() {
                                    setState(() {
                                      isConnecting = true;
                                    });
                                    TextEditingController
                                        _databaseNameController =
                                        TextEditingController();
                                    TextEditingController
                                        _databasePassController =
                                        TextEditingController();

                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: ((ctx) {
                                        return CustomDBConnectBottomSheet(
                                          databaseNameController:
                                              _databaseNameController,
                                          databasePassController:
                                              _databasePassController,
                                          ctx: ctx,
                                          playground: playground!,
                                        );
                                      }),
                                    ).then((val) async {
                                      // log(val.toString());
                                      if (val != null) {
                                        http.Response res =
                                            await APICallServices
                                                .connectDatabase(
                                                    token: user!.token,
                                                    uid: playground!.uid,
                                                    did: playground!.did,
                                                    database_usrName: val[
                                                        AppKeys
                                                            .database_usrName],
                                                    database_pass: val[
                                                        AppKeys.database_pass]);

                                        Map<String, dynamic> resJson =
                                            jsonDecode(res.body);

                                        print(resJson.toString());

                                        if (res.statusCode == 200) {
                                          if (resJson["success"]) {
                                            db = DbModel.fromJson(
                                                resJson["database"]);
                                            prefix =
                                                "${AppConstants.takeFirstWord(user!.data.usrFirstName.toLowerCase())}@achivie:${db != null ? db!.databaseUsrName : ""}>";
                                            setState(() {
                                              isConnected = true;
                                            });
                                            AppConstants.showSnackbar(
                                                context, resJson["message"]);
                                          } else {
                                            AppConstants.showSnackbar(
                                                context, resJson["message"]);
                                          }
                                        } else {
                                          AppConstants.showSnackbar(
                                              context, resJson["message"]);
                                        }
                                      }
                                      setState(() {
                                        isConnecting = false;
                                      });
                                      _databaseNameController.dispose();
                                      _databasePassController.dispose();
                                    });
                                  }),
                                ),
                                Expanded(
                                  child: Container(
                                    // width: double.infinity,
                                    padding: EdgeInsets.only(
                                      left: 10,
                                      right: 10,
                                      top: 10,
                                      bottom: 10,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // AppConstants.formatText(
                                        //     result.trim(), prefix),
                                        SelectableText(
                                          result.trim(),
                                          style: TextStyle(
                                            color: AppColors.white,
                                            fontSize: 15,
                                          ),
                                        ),
                                        if (MediaQuery.of(context).size.width >=
                                            500)
                                          Expanded(
                                            child: TextFormField(
                                              controller: _commandController,
                                              style: TextStyle(
                                                color: AppColors.white,
                                              ),
                                              autofocus: true,
                                              focusNode: _focusNode,
                                              onChanged: ((c) {
                                                // log(c);
                                                // setState(() {});
                                              }),
                                              onEditingComplete: (() async {
                                                await execute(_commandController
                                                    .text
                                                    .trim());
                                              }),
                                              inputFormatters: [
                                                CustomTextFormatter(
                                                    keywords:
                                                        AppConstants.keywords),
                                              ],
                                              decoration: InputDecoration(
                                                isDense: true,
                                                border: InputBorder.none,
                                                prefixStyle: TextStyle(
                                                  color: AppColors.white,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 1,
                                                ),
                                                prefixText: prefix,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (MediaQuery.of(context).size.width < 450)
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text(
                                        "You can not run query from mobile",
                                        style: TextStyle(
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedPositioned(
                  top: isOptionsVisible
                      ? 0
                      : (MediaQuery.of(context).size.width <= 590)
                          ? -246
                          : -150,
                  width: MediaQuery.of(context).size.width,
                  height:
                      (MediaQuery.of(context).size.width <= 590) ? 185 : 115,
                  duration: Duration(milliseconds: 200),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 15,
                      left: 15,
                      right: 15,
                      bottom: 15,
                    ),
                    child: DatabaseDetailsContainer(
                      onImageTap: (() async {
                        final image = await screenshotController.capture();
                        if (image != null) {
                          final stream = AppConstants.uint8ListToStream(image);
                          download(stream,
                                  "${playground!.pName}-${db != null ? "${db!.databaseUsrName}-" : ""}${DateTime.now().millisecondsSinceEpoch}.png")
                              .whenComplete(() {
                            AppConstants.showSnackbar(
                                context, "Image saved to your device");
                          });
                        }
                        // log(image.toString());
                      }),
                      color: AppColors.black,
                      isExecuting: isExecuting,
                      text: result,
                      borderRadius: BorderRadius.zero,
                      isConnected: isConnected,
                      isConnecting: isConnecting,
                      onConnectTap: (() {
                        setState(() {
                          isConnecting = true;
                        });
                        TextEditingController _databaseNameController =
                            TextEditingController();
                        TextEditingController _databasePassController =
                            TextEditingController();

                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: ((ctx) {
                            return CustomDBConnectBottomSheet(
                              databaseNameController: _databaseNameController,
                              databasePassController: _databasePassController,
                              ctx: ctx,
                              playground: playground!,
                            );
                          }),
                        ).then((val) async {
                          // log(val.toString());
                          if (val != null) {
                            http.Response res =
                                await APICallServices.connectDatabase(
                                    token: user!.token,
                                    uid: playground!.uid,
                                    did: playground!.did,
                                    database_usrName:
                                        val[AppKeys.database_usrName],
                                    database_pass: val[AppKeys.database_pass]);

                            Map<String, dynamic> resJson = jsonDecode(res.body);

                            print(resJson.toString());

                            if (res.statusCode == 200) {
                              if (resJson["success"]) {
                                db = DbModel.fromJson(resJson["database"]);
                                prefix =
                                    "${AppConstants.takeFirstWord(user!.data.usrFirstName.toLowerCase())}@achivie:${db != null ? db!.databaseUsrName : ""}>";
                                setState(() {
                                  isConnected = true;
                                });
                                AppConstants.showSnackbar(
                                    context, resJson["message"]);
                              } else {
                                AppConstants.showSnackbar(
                                    context, resJson["message"]);
                              }
                            } else {
                              AppConstants.showSnackbar(
                                  context, resJson["message"]);
                            }
                          }
                          setState(() {
                            isConnecting = false;
                          });
                          _databaseNameController.dispose();
                          _databasePassController.dispose();
                        });
                      }),
                      playground: playground!,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (isPlaygroundLoading) {
      return Scaffold(
        backgroundColor: AppColors.black,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: SizedBox(
                width: 80,
                height: 80,
                child: Lottie.asset(
                  "assets/loading-animation.json",
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Center(
              child: Text(
                "Fetching your profile details",
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
    } else {
      return Scaffold(
        backgroundColor: AppColors.black,
        body: Center(
          child: Text(
            "Error",
            style: TextStyle(
              color: AppColors.white,
            ),
          ),
        ),
      );
    }
  }
}
