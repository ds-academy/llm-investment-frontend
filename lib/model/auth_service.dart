import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  final Dio dio = Dio();
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://default-url.com';

  // 로그인 기능
  Future<bool> login(String id, String pw, context) async {

    String url = "$baseUrl/members/login";

    try {
      final res = await dio.post(
          url, data: {'id': id, 'pw': pw,});

      if (res.statusCode == 200 && res.data['success']) {
        // 로그인 성공 시 로그인 상태 유지
        await storage.write(key: 'token', value: res.data['token']);
        return true;
      } else {
        print('Failed to login request: ${res.statusCode}');
        return false;
      }
    } catch (error) {
      print("Error : $error");
      return false;
    }
  }

  // 로그인 상태 유지 여부 확인
  Future<bool> isLoggedIn() async {
    try {
      String? idToken = await storage.read(key: 'token');
      return idToken != null;
    } catch (error) {
      print("loggedIn Error: $error");
      return false;
    }
  }

  // 로그아웃 기능
  Future<void> logout(BuildContext context) async {
    try {
      await storage.delete(key: 'token');
    } catch (error) {
      print("logout Error: $error");
    }
  }
}