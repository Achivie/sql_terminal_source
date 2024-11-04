import 'package:universal_html/html.dart';

class EncryptionService {
  // static final key = encrypt.Key.fromLength(32);
  // static final iv = encrypt.IV.fromLength(16);
  // static final encrypter = encrypt.Encrypter(encrypt.AES(key));
  //
  // static String encryptAES(String text) {
  //   final encrypted = encrypter.encrypt(text, iv: iv);
  //   log(encrypted.bytes.toString());
  //   final base64Encoded = base64Url.encode(encrypted.bytes);
  //   return base64Encoded;
  // }
  //
  // static String decryptAES(String encryptedBase64) {
  //   // final encryptedBytes = base64Url.decode(encryptedBase64);
  //   // final encrypted = Encrypted(encryptedBytes);
  //   // log(encryptedBase64);
  //   final decrypted =
  //       encrypter.decrypt(Encrypted.fromBase64(encryptedBase64), iv: iv);
  //   log(decrypted.toString());
  //
  //   return decrypted;
  // }

  static String encrypt(String input) {
    return window.btoa(input);
  }

  static String decrypt(String input) {
    return window.atob(input);
  }
}
