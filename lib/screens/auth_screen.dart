import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:regexed_validator/regexed_validator.dart';
import 'package:sql_terminal/models/user_model.dart';
import 'package:sql_terminal/services/constants.dart';
import 'package:sql_terminal/services/encryption_service.dart';
import 'package:sql_terminal/services/keys.dart';
import 'package:sql_terminal/services/styles.dart';

import '../models/user_signup_model.dart';
import '../services/storage_services.dart';
import '../utils/auth_custom_button.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key, required this.mode, this.otp, this.token})
      : super(key: key);

  final String mode;
  final String? otp, token;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late TextEditingController _firstNameTextController,
      _lastNameTextController,
      _passTextController,
      _passConfirmTextController,
      _emailTextController,
      _desTextController;
  bool passObscure = true;
  bool passConfirmObscure = true;
  File? profileImage;
  bool isHovering = false, isLoading = false, isForgotPassLoading = false;

  Uint8List? webImage;

  @override
  void initState() {
    _firstNameTextController = TextEditingController();
    _lastNameTextController = TextEditingController();
    _passConfirmTextController = TextEditingController();
    _passTextController = TextEditingController();
    _emailTextController = TextEditingController();
    _desTextController = TextEditingController();
    _desTextController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _firstNameTextController.dispose();
    _lastNameTextController.dispose();
    _passConfirmTextController.dispose();
    _passTextController.dispose();
    _emailTextController.dispose();
    _desTextController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (!kIsWeb) {
      final picker = ImagePicker();
      XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        var selected = File(image.path);
        profileImage = selected;
      } else {
        log("No image picked");
      }
    } else if (kIsWeb) {
      final picker = ImagePicker();
      XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        var f = await image.readAsBytes();
        webImage = f;
        profileImage = File("a");
      } else {
        log("No image picked");
      }
    } else {
      log("Error");
    }
    setState(() {});
  }

  Future<http.Response> signUp(
      {File? profile,
      Uint8List? webProfile,
      required String firstName,
      required String lastName,
      required String pass,
      required String des,
      required String email}) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("${AppKeys.apiUsersBaseUrl}/create"),
    );

    if (kIsWeb && webProfile != null) {
      // log("web image");
      request.files.add(http.MultipartFile.fromBytes(
        AppKeys.usrProfilePic,
        webProfile,
        filename: 'profile_${DateTime.now().toIso8601String()}.jpg',
      ));
      request.headers["content-type"] = "multipart/form-data";
      request.fields[AppKeys.usrFirstName] = firstName;
      request.fields[AppKeys.notificationToken] = "NA";
      // log(firstName);
      request.fields[AppKeys.usrLastName] = lastName.isEmpty ? "" : lastName;
      request.fields[AppKeys.usrPassword] = pass;
      request.fields[AppKeys.usrEmail] = email;
      request.fields[AppKeys.uid] = email.split('@')[0];
      request.fields[AppKeys.usrDescription] = des.isEmpty ? "" : des;
      request.fields[AppKeys.usrProfession] = "Student";
      // log(request.fields.toString());
      // request.fields[AppKeys.notificationToken] = "NA";
      // (await FirebaseMessaging.instance.getToken())!;

      // return await http.Response.fromStream(await request.send());
      log(request.fields.toString());
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Successful sign-up
      return response;
    } else if (!kIsWeb && profile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        AppKeys.usrProfilePic,
        profile.path,
      ));
      request.headers["content-type"] = "multipart/form-data";

      request.fields[AppKeys.usrFirstName] = firstName;
      request.fields[AppKeys.notificationToken] = "NA";
      // log(firstName);
      request.fields[AppKeys.usrLastName] = lastName.isEmpty ? "" : lastName;
      request.fields[AppKeys.usrPassword] = pass;
      request.fields[AppKeys.usrEmail] = email;
      request.fields[AppKeys.uid] = email.split('@')[0];
      request.fields[AppKeys.usrDescription] = des.isEmpty ? "" : des;
      request.fields[AppKeys.usrProfession] = "Student";
      // log(request.fields.toString());
      // request.fields[AppKeys.notificationToken] = "NA";
      // (await FirebaseMessaging.instance.getToken())!;

      // return await http.Response.fromStream(await request.send());
      log(request.fields.toString());
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return response;
    } else {
      // log("Error");
      // request.fields[AppKeys.usrProfilePic] = "";
      //
      // request.headers["content-type"] = "application/json";

      return await http.post(
        Uri.parse("${AppKeys.apiUsersBaseUrl}/create"),
        headers: {
          "content-type": "application/json",
        },
        body: jsonEncode({
          AppKeys.uid: email.split('@')[0],
          AppKeys.notificationToken: "NA",
          AppKeys.usrLastName: lastName.isEmpty ? "" : lastName,
          AppKeys.usrFirstName: firstName,
          AppKeys.usrEmail: email,
          AppKeys.usrDescription: des.isEmpty ? "" : des,
          AppKeys.usrProfession: "Student",
          AppKeys.usrPassword: pass,
        }),
      );
    }
  }

  bool isValidName(String name) {
    if (name.isEmpty) {
      return false;
    } else {
      RegExp regex = RegExp(r'^[a-zA-Z]+$');
      return regex.hasMatch(name);
    }
    // Regular expression to match only letters
  }

  @override
  Widget build(BuildContext context) {
    // final uri = FluroRouter.appRouter.toString();
    // log(uri);
    // final routeInformationParser = GoRouter.of(context).routeInformationParser;
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        leading: SizedBox(),
        title: Text(
          widget.mode == AppKeys.otpRouteKey
              ? "OTP Verification"
              : AppConstants.routeToText(widget.mode),
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        // actions: [
        //   Text(
        //     ,
        //     style: TextStyle(
        //       color: AppColors.white,
        //     ),
        //   ),
        // ],
      ),
      bottomNavigationBar: Container(
        height: 60,
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 25,
              foregroundImage: NetworkImage("https://achivie.com/img/logo.png"),
            ),
            SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Powered By",
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
                SizedBox(
                  height: 3,
                ),
                Text(
                  "Achivie",
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    letterSpacing: 2,
                  ),
                )
              ],
            )
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 10),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 15,
                right: 15,
              ),
              child: Builder(builder: (ctx) {
                if (widget.mode == AppKeys.signUpRouteKey) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          Column(
                            children: [
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                onEnter: ((event) {
                                  setState(() {
                                    isHovering = true;
                                  });
                                }),
                                onExit: ((event) {
                                  setState(() {
                                    isHovering = false;
                                  });
                                }),
                                child: GestureDetector(
                                  onTap: (() {
                                    _pickImage();
                                  }),
                                  child: AnimatedContainer(
                                    constraints:
                                        BoxConstraints(maxWidth: 500.0),
                                    height: (webImage != null ||
                                            profileImage != null)
                                        ? 150
                                        : 55,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: (webImage != null ||
                                              profileImage != null)
                                          ? 15
                                          : 10,
                                      vertical: 15,
                                    ),
                                    decoration: BoxDecoration(
                                      image: (kIsWeb && webImage != null)
                                          ? DecorationImage(
                                              fit: BoxFit.cover,
                                              opacity: 0.5,
                                              image: MemoryImage(webImage!),
                                            )
                                          : (!kIsWeb && profileImage != null)
                                              ? DecorationImage(
                                                  fit: BoxFit.cover,
                                                  opacity: 0.5,
                                                  image:
                                                      FileImage(profileImage!),
                                                )
                                              : null,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: AppColors.white.withOpacity(
                                            isHovering ? 0.1 : 0.5),
                                      ),
                                    ),
                                    duration: Duration(milliseconds: 200),
                                    child: (webImage != null ||
                                            profileImage != null)
                                        ? Align(
                                            alignment: Alignment.bottomRight,
                                            child: Container(
                                              height: 35,
                                              width: 35,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppColors.grey
                                                    .withOpacity(0.5),
                                              ),
                                              child: Center(
                                                child: IconButton(
                                                  onPressed: (() {
                                                    _pickImage();
                                                  }),
                                                  icon: Icon(
                                                    Icons.edit,
                                                    color: AppColors.white,
                                                    size: 20,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              "Choose Profile Picture",
                                              style: TextStyle(
                                                color: AppColors.white
                                                    .withOpacity(0.5),
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              CustomTextFormField(
                                hint: "First Name",
                                textInputType: TextInputType.name,
                                textEditingController: _firstNameTextController,
                                obscure: false,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              CustomTextFormField(
                                textInputType: TextInputType.name,
                                hint: "Last Name",
                                obscure: false,
                                textEditingController: _lastNameTextController,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              CustomTextFormField(
                                obscure: false,
                                textInputType: TextInputType.multiline,
                                hint: "Short Description",
                                textEditingController: _desTextController,
                                maxLength: 80,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              CustomTextFormField(
                                obscure: false,
                                textInputType: TextInputType.emailAddress,
                                hint: "Email",
                                textEditingController: _emailTextController,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              CustomTextFormField(
                                hint: "Password",
                                textInputType: TextInputType.visiblePassword,
                                textEditingController: _passTextController,
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
                                hint: "Retype Password",
                                textInputType: TextInputType.visiblePassword,
                                textEditingController:
                                    _passConfirmTextController,
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
                            ],
                          ),
                        ],
                      ),
                      if (isLoading)
                        SizedBox(
                          height: 15,
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
                          head: "Sign Up",
                          onTap: (() async {
                            if (isValidName(
                                _firstNameTextController.text.trim())) {
                              if (validator
                                  .email(_emailTextController.text.trim())) {
                                if (validator.password(
                                    _passTextController.text.trim())) {
                                  if (_passTextController.text.trim() ==
                                      _passConfirmTextController.text.trim()) {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    http.Response res = await signUp(
                                      profile: profileImage,
                                      webProfile: webImage,
                                      firstName:
                                          _firstNameTextController.text.trim(),
                                      lastName:
                                          _lastNameTextController.text.trim(),
                                      pass: _passTextController.text.trim(),
                                      des: _desTextController.text.trim(),
                                      email: _emailTextController.text.trim(),
                                    );

                                    Map<String, dynamic> result =
                                        json.decode(res.body);

                                    log(result.toString());

                                    if (res.statusCode == 200) {
                                      if (result["success"]) {
                                        final userSignUpModel =
                                            UserSignUpModel.fromJson(result);

                                        Navigator.pushReplacementNamed(context,
                                            "${AppKeys.authRouteKey}${AppKeys.otpWithoutQRouteKey}/${EncryptionService.encrypt(userSignUpModel.data[0].uid)}/${userSignUpModel.token}/${EncryptionService.encrypt(userSignUpModel.otp.toString())}");
                                      } else {
                                        AppConstants.showSnackbar(
                                          context,
                                          result["message"],
                                        );
                                      }
                                    } else {
                                      AppConstants.showSnackbar(
                                        context,
                                        result["message"],
                                      );
                                    }
                                    setState(() {
                                      isLoading = false;
                                    });
                                  } else {
                                    AppConstants.showSnackbar(
                                      context,
                                      "Please check the passwords.",
                                    );
                                  }
                                } else {
                                  AppConstants.showSnackbar(
                                    context,
                                    AppConstants.validatePassword(
                                        _passTextController.text.trim()),
                                  );
                                }
                              } else {
                                AppConstants.showSnackbar(
                                  context,
                                  "Please give a valid email.",
                                );
                              }
                            } else {
                              AppConstants.showSnackbar(
                                context,
                                "Please give valid name",
                              );
                            }
                            // context.go(
                            //   AppKeys.authRouteKey + AppKeys.signInRouteKey,
                            // );
                          }),
                        ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account?",
                            style: TextStyle(
                              color: AppColors.white,
                            ),
                          ),
                          TextButton(
                            onPressed: (() {
                              // Beamer.of(context).beamToReplacementNamed(
                              //     AppKeys.authRouteKey + AppKeys.signInRouteKey);
                              // context.go(AppKeys.authRouteKey +
                              //     AppKeys.signInRouteKey);
                              Navigator.pushReplacementNamed(
                                  context,
                                  AppKeys.authRouteKey +
                                      AppKeys.signInRouteKey);
                            }),
                            child: Text(
                              "Sign In",
                              style: TextStyle(
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                } else if (widget.mode == AppKeys.signInRouteKey) {
                  return Column(
                    children: [
                      CustomTextFormField(
                        obscure: false,
                        textInputType: TextInputType.emailAddress,
                        hint: "Email",
                        textEditingController: _emailTextController,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      CustomTextFormField(
                        hint: "Password",
                        textInputType: TextInputType.visiblePassword,
                        textEditingController: _passTextController,
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
                      if (isForgotPassLoading)
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: Lottie.asset(
                            "assets/loading-animation.json",
                          ),
                        ),
                      if (!isForgotPassLoading)
                        Container(
                          constraints: BoxConstraints(maxWidth: 500.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: (() async {
                                  if (_emailTextController.text
                                          .trim()
                                          .isNotEmpty &&
                                      validator.email(
                                          _emailTextController.text.trim())) {
                                    setState(() {
                                      isForgotPassLoading = true;
                                    });
                                    http.Response response = await http.post(
                                      Uri.parse(
                                        "${AppKeys.apiUsersBaseUrl}/forgotPass/${_emailTextController.text.trim()}",
                                      ),
                                      headers: {
                                        "content-type": "application/json",
                                      },
                                    );

                                    if (response.statusCode == 200) {
                                      Map<String, dynamic> responseJson =
                                          jsonDecode(response.body);
                                      if (responseJson["success"]) {
                                        // context.go(
                                        //     "${AppKeys.authRouteKey}${AppKeys.forgotPassWithoutCondRouteKey}/${EncryptionService.encrypt(_emailTextController.text.trim())}/${EncryptionService.encrypt(responseJson["uid"])}/${EncryptionService.encrypt(responseJson["token"])}");
                                        Navigator.pushReplacementNamed(context,
                                            "${AppKeys.authRouteKey}${AppKeys.forgotPassWithoutCondRouteKey}/${EncryptionService.encrypt(_emailTextController.text.trim())}/${EncryptionService.encrypt(responseJson["uid"])}/${EncryptionService.encrypt(responseJson["token"])}");
                                      } else {
                                        AppConstants.showSnackbar(
                                          context,
                                          responseJson["message"],
                                        );
                                      }
                                    } else {
                                      AppConstants.showSnackbar(
                                        context,
                                        "Error: Status Code = ${response.statusCode}",
                                      );
                                    }
                                    setState(() {
                                      isForgotPassLoading = false;
                                    });
                                  } else {
                                    AppConstants.showSnackbar(
                                      context,
                                      "Please give your registered email",
                                    );
                                  }
                                }),
                                child: Text(
                                  "Forgot Password",
                                  style: TextStyle(
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (isLoading)
                        SizedBox(
                          height: 15,
                        ),
                      if (isLoading)
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: Lottie.asset(
                            "assets/loading-animation.json",
                          ),
                        ),
                      SizedBox(
                        height: 10,
                      ),
                      if (!isLoading)
                        CustomButton(
                          head: "Sign In",
                          onTap: (() async {
                            // API CALL

                            if (_emailTextController.text.trim().isNotEmpty &&
                                _passTextController.text.trim().isNotEmpty) {
                              setState(() {
                                isLoading = true;
                              });

                              await http
                                  .post(
                                Uri.parse("${AppKeys.apiUsersBaseUrl}/login"),
                                headers: {
                                  "content-type": "application/json",
                                  // 'Authorization':
                                  //     'Bearer $token',
                                },
                                body: jsonEncode({
                                  AppKeys.uid: _emailTextController.text
                                      .trim()
                                      .split('@')[0],
                                  AppKeys.usrPassword:
                                      _passTextController.text.trim(),
                                  AppKeys.usrEmail:
                                      _emailTextController.text.trim(),
                                  AppKeys.notificationToken: "NA",
                                }),
                              )
                                  .then((response) async {
                                if (response.statusCode == 200) {
                                  Map<String, dynamic> responseJson =
                                      jsonDecode(response.body);

                                  if (responseJson["success"]) {
                                    UserModel user =
                                        userModelFromJson(response.body);

                                    await StorageServices()
                                        .saveUserData(user)
                                        .whenComplete(() {
                                      Navigator.pushReplacementNamed(context,
                                          "/${user.data.uid}${AppKeys.playgroundsWithoutIDRouteKey}");
                                    });
                                  } else {
                                    AppConstants.showSnackbar(
                                      context,
                                      responseJson["message"],
                                    );
                                  }
                                } else {
                                  AppConstants.showSnackbar(
                                    context,
                                    "Error: Status Code = ${response.statusCode}",
                                  );
                                }
                              });

                              setState(() {
                                isLoading = false;
                              });
                            } else {
                              AppConstants.showSnackbar(
                                context,
                                "Please fill the Registered Email and Password.",
                              );
                            }
                          }),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: TextStyle(
                              color: AppColors.white,
                            ),
                          ),
                          TextButton(
                            onPressed: (() {
                              // Beamer.of(context).beamToReplacementNamed(
                              //     AppKeys.authRouteKey + AppKeys.signUpRouteKey);
                              Navigator.pushReplacementNamed(
                                  context,
                                  AppKeys.authRouteKey +
                                      AppKeys.signUpRouteKey);
                            }),
                            child: Text(
                              "Sign Up",
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
                return Center(
                  child: Text(
                    "404",
                    style: TextStyle(color: AppColors.white),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

// void showSnackbar(BuildContext context, String message) {
//   ScaffoldMessenger.of(context).showSnackBar(
//     AppSnackbar().customizedAppSnackbar(
//       message: message,
//       context: context,
//     ),
//   );
// }
}

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    required this.hint,
    required this.textEditingController,
    required this.obscure,
    this.suffix,
    this.prefix,
    this.contentPadding,
    this.textInputType,
    this.maxLength,
    this.validator,
  });

  final String hint;
  final TextEditingController textEditingController;
  final bool obscure;
  final Widget? suffix;
  final Widget? prefix;
  final EdgeInsets? contentPadding;
  final TextInputType? textInputType;
  final int? maxLength;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: obscure,
      controller: textEditingController,
      keyboardType: textInputType,
      maxLength: maxLength,
      validator: validator,
      style: TextStyle(
        color: AppColors.white,
      ),
      decoration: InputDecoration(
        constraints: BoxConstraints(maxWidth: 500.0),
        contentPadding: contentPadding,
        hintText: hint,
        suffix: suffix,
        prefix: prefix,
        hintStyle: TextStyle(
          color: AppColors.white.withOpacity(0.5),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.white),
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.white),
          borderRadius: BorderRadius.circular(15),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.red),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}
