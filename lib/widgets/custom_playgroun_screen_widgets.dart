import 'package:download/download.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

import '../models/all_playgrounds_model.dart';
import '../models/db_model.dart';
import '../screens/auth_screen.dart';
import '../services/constants.dart';
import '../services/keys.dart';
import '../services/storage_services.dart';
import '../services/styles.dart';
import '../utils/auth_custom_button.dart' as auth;
import '../utils/playground_custom_button.dart';

class CustomDBConnectBottomSheet extends StatefulWidget {
  const CustomDBConnectBottomSheet({
    super.key,
    required TextEditingController databaseNameController,
    required TextEditingController databasePassController,
    required this.ctx,
    required this.playground,
  })  : _databaseNameController = databaseNameController,
        _databasePassController = databasePassController;

  final TextEditingController _databaseNameController;
  final TextEditingController _databasePassController;
  final BuildContext ctx;
  final Playground playground;

  @override
  State<CustomDBConnectBottomSheet> createState() =>
      _CustomDBConnectBottomSheetState();
}

class _CustomDBConnectBottomSheetState
    extends State<CustomDBConnectBottomSheet> {
  bool myDB = false;
  DbModel? db;

  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    db = await StorageServices().readDatabaseDetails();
    if (db != null) {
      if (widget.playground.did == db!.did) {
        myDB = true;
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
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
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CupertinoSwitch(
                        value: myDB,
                        onChanged: ((val) {
                          myDB = val;
                          setState(() {});
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
            if (!myDB)
              CustomTextFormField(
                hint: "Database Name",
                textEditingController: widget._databaseNameController,
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
                obscure: true,
              ),
            if (!myDB)
              SizedBox(
                height: 10,
              ),
            auth.CustomButton(
              onTap: (() {
                // log(db!.did);
                if (myDB ||
                    (!myDB &&
                        widget._databaseNameController.text.trim().isNotEmpty &&
                        widget._databasePassController.text
                            .trim()
                            .isNotEmpty)) {
                  Navigator.pop(context, {
                    AppKeys.database_usrName: myDB
                        ? db!.databaseUsrName
                        : widget._databaseNameController.text.trim(),
                    AppKeys.database_pass: myDB
                        ? db!.databasePass
                        : widget._databasePassController.text.trim()
                  });
                }
              }),
              head: "Connect",
            ),
          ],
        ),
      ),
    );
  }
}

class DatabaseDetailsContainer extends StatelessWidget {
  const DatabaseDetailsContainer({
    super.key,
    required this.isExecuting,
    required this.text,
    required this.isConnected,
    required this.isConnecting,
    required this.onConnectTap,
    required this.playground,
    this.db,
    this.color,
    required this.onImageTap,
    this.borderRadius,
  });

  final bool isExecuting, isConnected, isConnecting;
  final String text;
  final VoidCallback onConnectTap;
  final Playground playground;
  final DbModel? db;
  final Color? color;
  final VoidCallback onImageTap;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 5,
        bottom: 5,
        left: 10,
        right: 10,
      ),
      width: double.infinity,
      decoration: BoxDecoration(
        color: color ?? AppColors.grey,
        borderRadius: borderRadius ??
            BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
      ),
      child: DatabaseDetailsWidget(
        isConnected: isConnected,
        isExecuting: isExecuting,
        text: text,
        isConnecting: isConnecting,
        onConnectTap: onConnectTap,
        playground: playground,
        db: db,
        onImageTap: onImageTap,
      ),
    );
  }
}

class DatabaseDetailsWidget extends StatelessWidget {
  const DatabaseDetailsWidget({
    super.key,
    required this.isExecuting,
    required this.text,
    required this.isConnected,
    required this.isConnecting,
    required this.onConnectTap,
    required this.playground,
    this.db,
    required this.onImageTap,
  });

  final bool isExecuting, isConnected, isConnecting;
  final String text;
  final VoidCallback onConnectTap;
  final Playground playground;
  final DbModel? db;
  final VoidCallback onImageTap;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width > 590) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      "Database Username:",
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        color: AppColors.white.withOpacity(0.7),
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: db != null
                          ? SelectableText(
                              db!.databaseUsrName,
                              style: TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : SizedBox(),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  if (isExecuting)
                    CupertinoActivityIndicator(
                      color: AppColors.white.withOpacity(0.6),
                    ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Last Edited: ${AppConstants.lastEditedString(playground.pLastEdited)}",
                    style: TextStyle(
                      color: AppColors.white.withOpacity(0.6),
                      fontWeight: FontWeight.w100,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (!isConnected)
                Row(
                  children: [
                    Text(
                      "Not Connected",
                      style: TextStyle(
                        color: AppColors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    if (isConnecting)
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: Lottie.asset(
                          "assets/loading-animation.json",
                        ),
                      ),
                    if (!isConnecting)
                      Container(
                        width: 30,
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                        ),
                        child: InkWell(
                          onTap: onConnectTap,
                          child: Icon(
                            Icons.check,
                            color: AppColors.black,
                            size: 25,
                          ),
                        ),
                      )
                  ],
                ),
              if (isConnected)
                Text(
                  "Connected",
                  style: TextStyle(
                    color: AppColors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomButton(
                      onPressed: (() {
                        if (text.isNotEmpty) {
                          AppConstants.copyTextToClipboard(text);
                          AppConstants.showSnackbar(
                              context, "Text copied to clipboard");
                        } else {
                          AppConstants.showSnackbar(
                              context, "Please connect your db first");
                        }
                      }),
                      icon: Icons.copy_rounded,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    CustomButton(
                      onPressed: (() {
                        if (text.isNotEmpty) {
                          final stream = Stream.fromIterable(text.codeUnits);
                          download(stream,
                                  "${playground.pName}-${db != null ? "${db!.databaseUsrName}-" : ""}${DateTime.now().millisecondsSinceEpoch}.txt")
                              .whenComplete(() {
                            AppConstants.showSnackbar(
                                context, "File saved to your device");
                          });
                        } else {
                          AppConstants.showSnackbar(
                              context, "Please connect your database first");
                        }
                      }),
                      icon: Icons.file_download_outlined,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    CustomButton(
                      onPressed: onImageTap,
                      icon: Icons.image_rounded,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (db != null)
            Text(
              "Database Username: ${db!.databaseUsrName}",
              style: TextStyle(
                color: AppColors.white,
              ),
            ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Text(
                "Last Edited: ${AppConstants.lastEditedString(playground.pLastEdited)}",
                style: TextStyle(
                  color: AppColors.white.withOpacity(0.6),
                  fontWeight: FontWeight.w100,
                  fontSize: 12,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              if (isExecuting)
                CupertinoActivityIndicator(
                  color: AppColors.white.withOpacity(0.6),
                ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!isConnected)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isConnecting)
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: Lottie.asset(
                          "assets/loading-animation.json",
                        ),
                      ),
                    if (!isConnecting)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: InkWell(
                          onTap: onConnectTap,
                          child: Text(
                            "Connect",
                            style: TextStyle(
                              color: AppColors.black,
                            ),
                          ),
                        ),
                      )
                  ],
                ),
              if (isConnected)
                Text(
                  "Connected",
                  style: TextStyle(
                    color: AppColors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isExecuting)
                CupertinoActivityIndicator(
                  color: AppColors.white.withOpacity(0.6),
                ),
              SizedBox(
                width: 10,
              ),
              CustomButton(
                onPressed: (() {
                  if (text.isNotEmpty) {
                    AppConstants.copyTextToClipboard(text);
                    AppConstants.showSnackbar(
                        context, "Text copied to clipboard");
                  } else {
                    AppConstants.showSnackbar(
                        context, "Please connect your db first");
                  }
                }),
                icon: Icons.copy_rounded,
              ),
              SizedBox(
                width: 10,
              ),
              CustomButton(
                onPressed: (() {
                  if (text.isNotEmpty) {
                    final stream = Stream.fromIterable(text.codeUnits);
                    download(stream,
                            "${playground.pName}-${db != null ? "${db!.databaseUsrName}-" : ""}${DateTime.now().millisecondsSinceEpoch}.txt")
                        .whenComplete(() {
                      AppConstants.showSnackbar(
                          context, "File saved to your device");
                    });
                  } else {
                    AppConstants.showSnackbar(
                        context, "Please connect your database first");
                  }
                }),
                icon: Icons.file_download_outlined,
              ),
              SizedBox(
                width: 10,
              ),
              CustomButton(
                onPressed: onImageTap,
                icon: Icons.image_rounded,
              ),
            ],
          )
        ],
      );
    }
  }
}

class CustomTextFormatter extends TextInputFormatter {
  final List<String> keywords;

  CustomTextFormatter({required this.keywords});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final formattedText = formatText(newValue.text, keywords);
    return TextEditingValue(
      text: formattedText,
      selection: newValue.selection,
    );
  }

  static String formatText(String text, List<String> keywords) {
    final parts = text.split(" ");
    final List<String> formattedParts = [];

    for (var part in parts) {
      String formattedPart = part;
      if (keywords.contains(part.toLowerCase())) {
        formattedPart = part.toUpperCase();
      }
      formattedParts.add(formattedPart);
    }

    return formattedParts.join(" ");
  }
}
