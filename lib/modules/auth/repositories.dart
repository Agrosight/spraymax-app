import 'package:spraymax/modules/menu/entities.dart';
import 'package:hive/hive.dart';
import 'package:spraymax/modules/auth/entities.dart';
import 'package:spraymax/modules/common/consts.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthRepository {
  Future<Box<dynamic>> authDB;
  AuthRepository(this.authDB);

  Future<String> getToken() async {
    try {
      final Box<dynamic> db = await authDB;
      var res = db.get(DBEnum.token) ?? "";
      if (res.isNotEmpty) {
        Token token = Token.fromJson(jsonDecode(res));
        return token.token;
      }
    } catch (_) {}
    return '';
  }

  Future setToken(Token token) async {
    try {
      final Box<dynamic> db = await authDB;
      await db.put(DBEnum.token, jsonEncode(token));
    } catch (_) {}
    return;
  }

  Future clearToken() async {
    try {
      final Box<dynamic> db = await authDB;

      await db.delete(DBEnum.token);
    } catch (_) {}
    return;
  }

  Future<Token> verifyCredential(LoginCredentials loginCredentials) async {
    var url = Uri(
        scheme: httpSheme, host: urlSync, port: port, path: '/apiapp/login');
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        encoding: Encoding.getByName('utf-8'),
        body: loginCredentials.toMap(),
      );
      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        return Token()
          ..id = 1
          ..token = body['token'];
      }
    } catch (_) {
      return Token()
        ..id = -2
        ..token = '';
    }
    return Token()
      ..id = -1
      ..token = '';
  }

  Future<bool> logOut(String token) async {
    var url = Uri(
        scheme: httpSheme, host: urlSync, port: port, path: '/apiapp/logout');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          "Content-Type": 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return true;
      }
      if (response.statusCode == 401) {
        return true;
      }
    } catch (_) {}
    return false;
  }

  updateUser(String token, User user) {}
}
