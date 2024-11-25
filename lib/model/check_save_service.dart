import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:llm_invest_frontend/popup/check_continue_popup.dart';
import 'package:llm_invest_frontend/screen/ingame/game_main_page.dart';
import 'package:llm_invest_frontend/screen/section_select_page.dart';

import '../popup/check_saved_popup.dart';

class CheckSaveService {
  final Dio dio = Dio();
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://default-url.com';

  // 버튼 클릭 시 호출되는 메서드
  Future<void> gameIdxCheck(context) async {

    String url = '$baseUrl/game/save_check';

    try {
      // Storage에서 아이디 토큰 조회
      final token = await storage.read(key: 'token');
      if (token == null) {
        print('error: 저장된 토큰이 없습니다. $context');
        return;
      }

      // 서버로 game_idx 요청
      final res = await dio.post(
        url,
        data: {'token': token},
      );

      // 3. 서버 응답 확인 및 UI 처리
      if (res.statusCode == 200) {
        final data = res.data;

        if (data['success'] == true) {
          final gameIdx = data['idx'];
          if (gameIdx == 0) {
            // 다음 페이지로 이동
            Navigator.push(context,
              MaterialPageRoute(
                  builder: (context) => const SectionSelectPage()),
            );
          } else {
            // 세이브 체크 팝업 표시
            CheckContinuePopup.show(context);
          }
        } else {
          // 서버 오류 메시지 표시
          print("Server Error: ${data['error']}");
        }
      } else {
        print('Response: ${res.statusCode}');
      }
    } catch (error) {
      // 네트워크 오류 처리
      print('Network Error: ${error.toString()}');
    }
  }

  // 버튼 클릭 시 호출되는 메서드
  Future<void> gameSavedCheck(context) async {

    String url = '$baseUrl/game/save_check';

    try {
      // Storage에서 아이디 토큰 조회
      final token = await storage.read(key: 'token');
      if (token == null) {
        print('error: 저장된 토큰이 없습니다. $context');
        return;
      }

      // 서버로 game_idx 요청
      final res = await dio.post(
        url,
        data: {'token': token},
      );

      // 3. 서버 응답 확인 및 UI 처리
      if (res.statusCode == 200) {
        final data = res.data;

        if (data['success'] == true) {
          final gameIdx = data['idx'];
          if (gameIdx != 0) {
            // 다음 페이지로 이동
            Navigator.push(context,
              MaterialPageRoute(
                  builder: (context) => const GameMainPage()),
            );
          } else {
            CheckSavedPopup.show(context);
          }
        } else {
          // 서버 오류 메시지 표시
          print("Server Error: ${data['error']}");
        }
      } else {
        print('Response: ${res.statusCode}');
      }
    } catch (error) {
      // 네트워크 오류 처리
      print('Network Error: ${error.toString()}');
    }
  }
}