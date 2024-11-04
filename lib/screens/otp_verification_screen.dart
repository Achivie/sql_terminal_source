import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:sql_terminal/services/encryption_service.dart';
import 'package:sql_terminal/services/keys.dart';

import '../services/constants.dart';
import '../services/styles.dart';
import '../utils/auth_custom_button.dart';
import 'auth_screen.dart';

class OTPVerificationScreen extends StatefulWidget {
  const OTPVerificationScreen({super.key});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  late TextEditingController _otpTextController;
  bool isLoading = false;

  @override
  void initState() {
    _otpTextController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _otpTextController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final params =
        GoRouter.of(context).routerDelegate.currentConfiguration.pathParameters;
    // log(params.toString());
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.black,
        title: Text(
          "OTP Verification",
          style: TextStyle(
            fontSize: 25,
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
            CustomTextFormField(
              obscure: false,
              textInputType: TextInputType.number,
              hint: "OTP",
              textEditingController: _otpTextController,
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.warning,
                  color: AppColors.white,
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  "Do not refresh",
                  style: TextStyle(
                    color: AppColors.white,
                  ),
                )
              ],
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
              CustomButton(
                head: "Verify",
                onTap: (() async {
                  if (params["id"] != null &&
                      params["token"] != null &&
                      params["otp"] != null) {
                    if (_otpTextController.text.trim().isNotEmpty) {
                      if (_otpTextController.text.trim() ==
                          EncryptionService.decrypt(params["otp"]!)) {
                        setState(() {
                          isLoading = true;
                        });
                        http.Response response = await http.post(
                          Uri.parse(
                              "${AppKeys.apiUsersBaseUrl}/verification/${EncryptionService.decrypt(params["id"]!)}/${params["token"]}/${_otpTextController.text.trim()}"),
                          headers: {
                            "content-type": "application/json",
                            // 'Authorization':
                            //     'Bearer $token',
                          },
                        );
                        if (response.statusCode == 200) {
                          Map<String, dynamic> responseJson =
                              jsonDecode(response.body);
                          AppConstants.showSnackbar(
                            context,
                            responseJson["message"],
                          );
                          if (responseJson["success"]) {
                            context.go(
                                AppKeys.authRouteKey + AppKeys.signInRouteKey);
                          }
                        }
                      } else {
                        AppConstants.showSnackbar(
                            context, "Please fill the OTP correctly.");
                      }
                    } else {
                      AppConstants.showSnackbar(context,
                          "Please give the OTP sent to your given email.");
                    }
                  } else {
                    AppConstants.showSnackbar(context, "Something went wrong.");
                  }

                  // if (params["otp"] != null) {
                  //   log(params["otp"] ?? "Null");
                  //   final otp = EncryptionService.decryptAES(params["otp"]!);
                  //   log(otp);
                  // }
                  setState(() {
                    isLoading = false;
                  });
                }),
              ),
          ],
        ),
      ),
    );
  }
}
