import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:sql_terminal/services/constants.dart';
import 'package:sql_terminal/services/encryption_service.dart';
import 'package:sql_terminal/services/styles.dart';

import '../services/keys.dart';
import '../utils/auth_custom_button.dart';
import 'auth_screen.dart';

class ForgotScreen extends StatefulWidget {
  const ForgotScreen({super.key});

  @override
  State<ForgotScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  late TextEditingController _newPassTextEditingController;
  late TextEditingController _newPassConfirmTextEditingController;
  bool passObscure = true, passConfirmObscure = true, isLoading = false;

  @override
  void initState() {
    _newPassConfirmTextEditingController = TextEditingController();
    _newPassTextEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _newPassConfirmTextEditingController.dispose();
    _newPassTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final params =
        GoRouter.of(context).routerDelegate.currentConfiguration.pathParameters;
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        centerTitle: true,
        title: Text(
          "Set New Password",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 15,
          right: 15,
          top: 15,
          bottom: 15,
        ),
        child: Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Row(
                children: [
                  Icon(
                    Icons.warning_rounded,
                    color: AppColors.yellow,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: Text(
                      "Don't close the tab directly. It will create malfunctioning for  your account. Just cancel it first then close.",
                      style: TextStyle(
                        color: AppColors.white.withOpacity(0.5),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            CustomTextFormField(
              hint: "New Password",
              textInputType: TextInputType.visiblePassword,
              textEditingController: _newPassTextEditingController,
              obscure: passObscure,
              suffix: InkWell(
                onTap: (() {
                  setState(() {
                    passObscure = !passObscure;
                  });
                }),
                child: Icon(
                  !passObscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            CustomTextFormField(
              hint: "Confirm New Password",
              textInputType: TextInputType.visiblePassword,
              textEditingController: _newPassConfirmTextEditingController,
              obscure: passConfirmObscure,
              suffix: InkWell(
                onTap: (() {
                  setState(() {
                    passConfirmObscure = !passConfirmObscure;
                  });
                }),
                child: Icon(
                  !passConfirmObscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            if (isLoading)
              SizedBox(
                width: 80,
                height: 80,
                child: Lottie.asset(
                  "assets/loading-animation.json",
                ),
              ),
            if (!isLoading)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomButton(
                    onTap: (() async {
                      setState(() {
                        isLoading = true;
                      });

                      await http.post(
                        Uri.parse(
                          "${AppKeys.apiUsersBaseUrl}/cancelResetPass/${params["token"]}/${params["id"]}",
                        ),
                        headers: {
                          "content-type": "application/json",
                        },
                      ).then((response) {
                        if (response.statusCode == 200) {
                          Map<String, dynamic> responseJson =
                              jsonDecode(response.body);
                          if (responseJson["success"]) {
                            context.go(
                                "${AppKeys.authRouteKey}${AppKeys.signInRouteKey}");
                          } else {
                            AppConstants.showSnackbar(
                              context,
                              responseJson["message"],
                            );
                          }
                        } else {
                          AppConstants.showSnackbar(
                            context,
                            "Something went wrong",
                          );
                        }
                      });

                      setState(() {
                        isLoading = false;
                      });
                    }),
                    head: "Cancel",
                  ),
                  CustomButton(
                    onTap: (() async {
                      setState(() {
                        isLoading = true;
                      });

                      if (params["email"] != null &&
                          params["id"] != null &&
                          params["token"] != null) {
                        if (_newPassTextEditingController.text
                                .trim()
                                .isNotEmpty &&
                            _newPassConfirmTextEditingController.text
                                .trim()
                                .isNotEmpty &&
                            _newPassTextEditingController.text.trim() ==
                                _newPassConfirmTextEditingController.text
                                    .trim()) {
                          await http
                              .post(
                            Uri.parse(
                              "${AppKeys.apiUsersBaseUrl}/updateUserPassword",
                            ),
                            headers: {
                              "content-type": "application/json",
                            },
                            body: jsonEncode({
                              "usrPassword":
                                  _newPassTextEditingController.text.trim(),
                              "resetToken":
                                  EncryptionService.decrypt(params["token"]!),
                              AppKeys.usrEmail:
                                  EncryptionService.decrypt(params["email"]!),
                              AppKeys.uid:
                                  EncryptionService.decrypt(params["id"]!),
                            }),
                          )
                              .then((response) {
                            if (response.statusCode == 200) {
                              Map<String, dynamic> responseJson =
                                  jsonDecode(response.body);
                              if (responseJson["success"]) {
                                context.go(AppKeys.authRouteKey +
                                    AppKeys.signInRouteKey);
                              }
                            }
                          });
                        } else {
                          AppConstants.showSnackbar(
                            context,
                            "Please fill the new password correctly",
                          );
                        }
                      } else {
                        AppConstants.showSnackbar(
                          context,
                          "Something went wrong",
                        );
                      }

                      setState(() {
                        isLoading = false;
                      });
                    }),
                    head: "Update",
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
