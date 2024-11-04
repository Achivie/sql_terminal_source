import 'package:fluro/fluro.dart';
import 'package:sql_terminal/screens/splash_screen.dart';
import 'package:sql_terminal/services/keys.dart';

import '../screens/auth_screen.dart';

class MyAppRouter {
  static final FluroRouter router = FluroRouter();

  static final Handler _splashHandler =
      Handler(handlerFunc: ((ctx, params) => SplashScreen()));
  static final Handler _signInHandler = Handler(handlerFunc: ((ctx, params) {
    // AppConstants.changeAppName(ctx, "Sign-In • SQL • Achivie");
    return const AuthScreen(mode: AppKeys.signInRouteKey);
  }));
  static final Handler _signUpHandler = Handler(handlerFunc: ((ctx, params) {
    // AppConstants.changeAppName(ctx, "Sign-In • SQL • Achivie");
    return const AuthScreen(mode: AppKeys.signUpRouteKey);
  }));

  static void setupRouter() {
    router.define(AppKeys.initialRouteKey, handler: _splashHandler);
    router.define(AppKeys.authRouteKey + AppKeys.signInRouteKey,
        handler: _signInHandler);
    router.define(AppKeys.authRouteKey + AppKeys.signUpRouteKey,
        handler: _signUpHandler);
  }
// late UserModel user;
// static GoRouter router = GoRouter(
//   routes: [
//     GoRoute(
//       name: "Splash",
//       path: AppKeys.initialRouteKey,
//       builder: (BuildContext context, GoRouterState state) {
//         AppConstants.changeAppName(context, "Welcome! • SQL • Achivie");
//         return const SplashScreen();
//       },
//     ),
//     GoRoute(
//       name: "Sign In",
//       path: AppKeys.authRouteKey + AppKeys.signInRouteKey,
//       builder: (BuildContext context, GoRouterState state) {
//         AppConstants.changeAppName(context, "Sign-In • SQL • Achivie");
//         return const AuthScreen(mode: AppKeys.signInRouteKey);
//       },
//     ),
//     GoRoute(
//       name: "Sign Up",
//       path: AppKeys.authRouteKey + AppKeys.signUpRouteKey,
//       builder: (BuildContext context, GoRouterState state) {
//         AppConstants.changeAppName(context, "Sign-Up • SQL • Achivie");
//         return const AuthScreen(mode: AppKeys.signUpRouteKey);
//       },
//     ),
//     GoRoute(
//       name: "OTP Verification",
//       path: AppKeys.authRouteKey + AppKeys.otpRouteKey,
//       builder: (BuildContext context, GoRouterState state) {
//         final params = state.pathParameters;
//         // log(params["otp"].toString());
//         if (params["token"] != null && params["otp"] != null) {
//           AppConstants.changeAppName(context, "OTP • SQL • Achivie");
//           return OTPVerificationScreen(
//               // token: params["token"],
//               // otp: EncryptionService.decryptAES(
//               //   params["otp"]!,
//               // ),
//               );
//         } else {
//           AppConstants.changeAppName(context, "Error");
//           return RouteErrorScreen();
//         }
//       },
//     ),
//     GoRoute(
//       path: AppKeys.authRouteKey + AppKeys.forgotPassRouteKey,
//       builder: (BuildContext context, GoRouterState state) {
//         AppConstants.changeAppName(context, "Forgot Password");
//         return const ForgotScreen();
//       },
//     ),
//     GoRoute(
//       path: AppKeys.homeRouteKey,
//       builder: (BuildContext context, GoRouterState state) {
//         AppConstants.changeAppName(context, "Home");
//         return const HomeScreen();
//       },
//     ),
//     GoRoute(
//       path: AppKeys.dashboardRouteKey,
//       builder: (BuildContext context, GoRouterState state) {
//         AppConstants.changeAppName(context, "Dashboard");
//         return const DashboardScreen();
//       },
//     ),
//     GoRoute(
//         path: AppKeys.playgroundsRouteKey,
//         builder: (BuildContext context, GoRouterState state) {
//           // final extra = state.extra;
//           // final user = extra as UserModel;
//           final params = state.pathParameters;
//           // final storageUser = await StorageServices().readUserData();
//           // log(params.toString());
//           // log(user.toString());
//
//           if (params[AppKeys.uid] != null) {
//             AppConstants.changeAppName(
//                 context, "Playgrounds | ${params[AppKeys.uid]}");
//             return PlaygroundsScreen(
//                 // user: UserModel(
//                 //   name: "Rupam Karmakar",
//                 //   id: params["userID"]!,
//                 //   email: "rupamkarmakar1238@gmail.com",
//                 //   profile:
//                 //       "https://images.pexels.com/photos/771742/pexels-photo-771742.jpeg?auto=compress&cs=tinysrgb&w=1200",
//                 // ),
//                 );
//           } else {
//             AppConstants.changeAppName(context, "Error");
//             return RouteErrorScreen();
//           }
//         },
//         routes: [
//           GoRoute(
//               path: "playground/:pid/:p_name",
//               builder: (BuildContext context, GoRouterState state) {
//                 // final extra = state.extra;
//                 // final user = extra as UserModel;
//                 final params = state.pathParameters;
//                 // final storageUser = await StorageServices().readUserData();
//                 // log(params.toString());
//                 // log(user.toString());
//
//                 if (params[AppKeys.uid] != null &&
//                     params[AppKeys.pid] != null &&
//                     params[AppKeys.p_name] != null) {
//                   AppConstants.changeAppName(
//                       context, "Playground | ${params[AppKeys.p_name]}");
//                   return PlaygroundScreen(
//                       // user: UserModel(
//                       //   name: "Rupam Karmakar",
//                       //   id: params["userID"]!,
//                       //   email: "rupamkarmakar1238@gmail.com",
//                       //   profile:
//                       //       "https://images.pexels.com/photos/771742/pexels-photo-771742.jpeg?auto=compress&cs=tinysrgb&w=1200",
//                       // ),
//                       );
//                 } else {
//                   AppConstants.changeAppName(context, "Error");
//                   return RouteErrorScreen();
//                 }
//               }),
//         ]),
//     GoRoute(
//         path: AppKeys.playgroundRouteKey,
//         builder: (BuildContext context, GoRouterState state) {
//           // final extra = state.extra;
//           // final user = extra as UserModel;
//           final params = state.pathParameters;
//           // final storageUser = await StorageServices().readUserData();
//           // log(params.toString());
//           // log(user.toString());
//
//           if (params[AppKeys.uid] != null &&
//               params[AppKeys.pid] != null &&
//               params[AppKeys.p_name] != null) {
//             AppConstants.changeAppName(
//                 context, "Playground | ${params[AppKeys.p_name]}");
//             return PlaygroundScreen(
//                 // user: UserModel(
//                 //   name: "Rupam Karmakar",
//                 //   id: params["userID"]!,
//                 //   email: "rupamkarmakar1238@gmail.com",
//                 //   profile:
//                 //       "https://images.pexels.com/photos/771742/pexels-photo-771742.jpeg?auto=compress&cs=tinysrgb&w=1200",
//                 // ),
//                 );
//           } else {
//             AppConstants.changeAppName(context, "Error");
//             return RouteErrorScreen();
//           }
//         }),
//     // GoRoute(
//     //   path: AppKeys.profileWithoutUIDRouteKey,
//     //   builder: (BuildContext context, GoRouterState state) {
//     //     AppConstants.changeAppName(context, "Profile");
//     //     return ProfileScreen();
//     //   },
//     // ),
//   ],
// );

// Future<UserModel?> getUserData()async{
//   return await ;
// }
}
