import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:llm_invest_frontend/screen/login_page.dart';
import '../screen/join_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> joinMember(id, pw, nickName, name, phoneNumber, email, joinDate,
    context) async {
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://default-url.com';
  // flask 서버로 전송하는 코드
  // 1. 서버 url 작성, 매일 변경되는 ip주소 확인 필요
  // localhost 접속을 위한 안드로이드 에뮬 ip주소 : 10.0.2.2
  String url = "$baseUrl/members/join";

  // 와이파이 주소가 안될 경우, 로컬호스트 주소로 바꿀 것!
  // 안드로이드 에뮬 ip주소 : 10.0.2.2

  try {
    // 2. 통신 진행 >> dio queryParameters 데이터 전송
    Response res = await dio.post(
        url, data: {
      "id": id,
      "pw": pw,
      "nickName": nickName,
      "name": name,
      "phoneNumber": phoneNumber,
      "email": email,
      "joinDate": joinDate,
    }
    );

    // print(res.data);
    // print(res.realUri);

    if (res.statusCode == 200 && res.data['success']) {
      Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else {
      print('Failed to send request: ${res.statusCode}');
    }
  } catch (error) {
    print("Error: $error");
  }

}