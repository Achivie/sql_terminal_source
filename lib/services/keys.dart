class AppKeys {
  static const String initialRouteKey = "/";
  static const String authRouteKey = "/auth";
  static const String signInRouteKey = "/sign-in";
  static const String signUpRouteKey = "/sign-up";
  static const String otpRouteKey = "/otp/:id/:token/:otp";
  static const String forgotPassRouteKey = "/forgot-pass/:email/:id/:token";
  static const String forgotPassWithoutCondRouteKey = "/forgot-pass";
  static const String otpWithoutQRouteKey = "/otp";
  static const String homeRouteKey = "/home/:id";
  static const String playgroundsRouteKey = "/:$uid/playgrounds";
  static const String playgroundRouteKey = "/:$uid/playground/:$pid/:$p_name";
  static const String playgroundsWithoutIDRouteKey = "/playgrounds";
  static const String playgroundWithoutIDRouteKey = "/playground";
  static const String dashboardRouteKey = "/dashboard/:id";
  static const String profileRouteKey = "/profile/:uid";
  static const String profileWithoutUIDRouteKey = "/profile";
  static const String userStorageKey = "userStorageKey";
  static const String dbDetailsStorageKey = "dbDetailsStorageKey";
  static const String apiBaseUrl =
      "https://backend-api.achivie.com/v1/production";
  static const String apiUsersBaseUrl = "$apiBaseUrl/api/users";
  static const String apiSqlBaseUrl = "$apiBaseUrl/api/sql";
  static const String usrProfilePic = "usrProfilePic";
  static const String usrFirstName = "usrFirstName";
  static const String usrLastName = "usrLastName";
  static const String usrPassword = "usrPassword";
  static const String usrEmail = "usrEmail";
  static const String uid = "uid";
  static const String usrDescription = "usrDescription";
  static const String usrProfession = "usrProfession";
  static const String notificationToken = "notificationToken";
  static const String database_usrName = "database_usrName";
  static const String database_pass = "database_pass";
  static const String command = "command";
  static const String commands = "commands";
  static const String did = "did";
  static const String pid = "pid";
  static const String p_name = "p_name";
  static const String p_lastEdited = "p_lastEdited";
  static const String p_createTimestamp = "p_createTimestamp";
}
