import 'package:flutter/material.dart';
import 'package:flutterwebapp_reload_detector/flutterwebapp_reload_detector.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sql_terminal/providers/playground_widget_provider.dart';
import 'package:sql_terminal/services/keys.dart';
import 'package:sql_terminal/services/routes.dart';
import 'package:sql_terminal/services/styles.dart';
import 'package:url_strategy/url_strategy.dart';

Future<void> main() async {
  // UserModel? user = await StorageServices().readUserData();
  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: const FirebaseOptions(
  //     apiKey: "AIzaSyDTNGiXeUCNmwMJjQA-dcYkc-cwbBR1GA8",
  //     appId: "1:249126883370:web:461c82f70c85b240fff353",
  //     messagingSenderId: "249126883370",
  //     projectId: "sql-terminal-e79c6",
  //   ),
  // );
  // FirebaseMessaging.instance.getToken().then(print);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlaygroundWidgetProvider()),
        // Provider<NavigationService>(create: (_) => NavigationService()),
      ],
      child: MyApp(
          // user: user,
          ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  // final UserModel? user;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // final routerDelegate = BeamerDelegate(
  //   locationBuilder: RoutesLocationBuilder(
  //     routes: {
  //       AppKeys.initialRouteKey: ((ctx, state, data) => const BeamPage(
  //             title: "Splash Screen",
  //             child: SplashScreen(),
  //           )),
  //       AppKeys.authRouteKey + AppKeys.signInRouteKey: ((ctx, state, data) =>
  //           const BeamPage(
  //             title: "Auth Screen",
  //             child: AuthScreen(
  //               mode: AppKeys.signInRouteKey,
  //             ),
  //           )),
  //       AppKeys.authRouteKey + AppKeys.signUpRouteKey: ((ctx, state, data) =>
  //           const BeamPage(
  //             title: "Auth Screen",
  //             child: AuthScreen(
  //               mode: AppKeys.signUpRouteKey,
  //             ),
  //           )),
  //     },
  //   ),
  // );

  // late MyAppRouter myAppRouter;

  @override
  void initState() {
    // myAppRouter = MyAppRouter(user: widget.user);
    MyAppRouter.setupRouter();
    WebAppReloadDetector.onReload(() {
      print('Web Page Reloaded');
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "SQL Terminal",
      initialRoute: AppKeys.initialRouteKey,
      onGenerateRoute: MyAppRouter.router.generator,
      navigatorKey: GlobalKey<NavigatorState>(),
      // builder: ((ctx, child) {
      //   log((child == null).toString());
      //   if (child != null) {
      //     return child;
      //   } else {
      //     return RouteErrorScreen();
      //   }
      // }),
      // home: SplashScreen(),
      // routeInformationParser: MyAppRouter.router.routeInformationParser,
      // routeInformationProvider: MyAppRouter.router.routeInformationProvider,
      // routerDelegate: MyAppRouter.router.routerDelegate,
      theme: ThemeData(
        textTheme: GoogleFonts.aBeeZeeTextTheme(),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: AppColors.white, // Set your desired cursor color here
        ),
      ),
    );
  }
}
