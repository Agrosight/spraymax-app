import 'package:spraymax/modules/common/errors.dart';
import 'package:hive/hive.dart';
import 'package:spraymax/modules/menu/entities.dart';
import 'package:spraymax/modules/common/consts.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class MenuRepository {
  Future<Box<dynamic>> syncDB;
  MenuRepository(this.syncDB);

  Future<User> fetchUser(String token) async {
    var url = Uri(
        scheme: httpSheme,
        host: urlSync,
        port: port,
        path: '/apiapp/users/me/');
    try {
      var response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'content-type': 'application/json'
        },
      );
      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        return User.fromJson(body);
      }
      if (response.statusCode == 401) {
        return Future.error(InvalidUserError());
      }
    } catch (_) {}
    return User();
  }
}
