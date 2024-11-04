import 'package:shared_preferences/shared_preferences.dart';
import 'package:sql_terminal/models/db_model.dart';
import 'package:sql_terminal/services/encryption_service.dart';
import 'package:sql_terminal/services/keys.dart';

import '../models/user_model.dart';

class StorageServices {
  Future<void> saveUserData(UserModel user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppKeys.userStorageKey,
        EncryptionService.encrypt(userModelToJson(user)));
  }

  Future<void> saveDatabaseDetails(DbModel db) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // final newDB = DatabaseModel(
    //     name: EncryptionService.encrypt(db.name),
    //     pass: EncryptionService.encrypt(db.pass));
    await prefs.setString(AppKeys.dbDetailsStorageKey,
        EncryptionService.encrypt(dbModelToJson(db)));
  }

  Future<DbModel?> readDatabaseDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final db = prefs.getString(AppKeys.dbDetailsStorageKey);
    if (db != null) {
      return dbModelFromJson(EncryptionService.decrypt(db));
    } else {
      return null;
    }
  }

  Future<UserModel?> readUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final user = prefs.getString(AppKeys.userStorageKey);

    if (user != null) {
      return userModelFromJson(EncryptionService.decrypt(user));
    } else {
      return null;
    }
  }

  Future<bool> deleteAllSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.clear();
  }
}
