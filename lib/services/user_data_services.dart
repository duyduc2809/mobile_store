import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_store/cubit/app_cubits.dart';
import 'package:mobile_store/models/api_user.dart';
import 'package:mobile_store/services/hive_helpers.dart';

import '../models/user.dart';

class UserDataServices {
  static const urlGetUserByID = 'http://45.117.170.206:60/apis/user/';
  static const urlCreate = 'http://45.117.170.206:60/apis/user/';
  static const urlLogin = 'http://45.117.170.206:60/apis/login';

  //create new user account
  static Future<bool> createUser(User user) async {
    final uri = Uri.parse(urlCreate);
    final body = jsonEncode({
      'fullName': user.fullName.toString(),
      'userName': user.userName.toString(),
      'email': user.email.toString(),
      'password': user.password.toString(),
    });

    final response = await http.post(
      uri,
      body: body,
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 201) {
      print('create successfully');
      final jsonResponse = json.decode(response.body);
      print(jsonResponse);
      return true;
    } else {
      final jsonResponse = json.decode(response.body);
      print(jsonResponse);
      return false;
    }
  }

  //login user
  static Future<bool> loginUser(User user, bool rememberMe) async {
    final uri = Uri.parse(urlLogin);
    print(user.email);
    print(user.password);
    final body = json.encode({'email': user.email, 'password': user.password});

    final response = await http.post(
      uri,
      body: body,
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 201) {
      print('login successfully');
      final jsonResponse = json.decode(response.body);
      // print(jsonResponse);
      print('asdassd $rememberMe');

      final apiUser = APIUser.fromJson(jsonResponse);
      HiveHelper.saveData(apiUser, rememberMe);

      return true;
    } else {
      final jsonResponse = json.decode(response.body);
      print(jsonResponse);
      return false;
    }
  }
  //(hàm được gọi từ hàm login của AppCubits, dùng để lấy về thông tin của user đã đăng nhập)
  Future<User> getUser() async {
    final APIUser user = await HiveHelper.loadUserData();
    final url = '$urlGetUserByID${user.idUser}';
    final uri = Uri.parse(url);

    try {
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer ${user.token}'},
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        print('getuser successfully');
        return User.fromJson(json.decode(response.body));
      } else {
        print('get failed');
        throw Exception();
      }
    } catch (e) {
      print(e);
      throw Exception();
    }
  }
}