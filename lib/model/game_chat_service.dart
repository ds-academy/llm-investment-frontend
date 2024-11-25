import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GameChatService {
  final Dio _dio = Dio();
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://default-url.com';

  /// 메시지 전송 (일반 대화)
  Future<Map<String, dynamic>> sendMessage(String userId, String message) async {
    final response = await _dio.post(
      '$baseUrl/game_chat/send',
      data: {
        "user_id": userId,
        "message": message,
        "sender": "user", // 기본값
      },
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    return response.data;
  }

  /// TIP 상세 항목 요청 (TIPS_DETAIL_NAME 목록 가져오기)
  Future<List<String>> fetchTipDetails(String userId, String tipName) async {
    final response = await _dio.post(
      '$baseUrl/game_chat/send',
      data: {
        "user_id": userId,
        "message": "Tip:$tipName", // TIP 요청 메시지
        "sender": "user",
      },
      options: Options(headers: {'Content-Type': 'application/json'}),
    );

    // 응답 데이터를 TIPS_DETAIL_NAME 목록으로 변환
    if (response.data['success'] == true) {
      return List<String>.from(response.data['response']); // TIPS_DETAIL_NAME 목록 반환
    } else {
      throw Exception(response.data['message'] ?? 'Failed to fetch tip details');
    }
  }

  /// TIP 상세 항목 클릭 시 답변 요청 (ANSWER 가져오기)
  Future<String> fetchAnswer(String userId, String tipName, String detailName) async {
    final response = await _dio.post(
      '$baseUrl/game_chat/send',
      data: {
        "user_id": userId,
        "message": "Tip:$tipName Detail:$detailName", // TIP 및 세부 항목 요청 메시지
        "sender": "user",
      },
      options: Options(headers: {'Content-Type': 'application/json'}),
    );

    // 응답 데이터에서 ANSWER 반환
    if (response.data['success'] == true) {
      return response.data['response'];
    } else {
      throw Exception(response.data['message'] ?? 'Failed to fetch tip answer');
    }
  }

  /// 대화 기록 불러오기
  Future<List<Map<String, dynamic>>> fetchConversationHistory(String userId) async {
    final response = await _dio.get(
      '$baseUrl/game_chat/history',
      queryParameters: {"user_id": userId},
      options: Options(headers: {'Content-Type': 'application/json'}),
    );

    if (response.data['success'] == true) {
      // 대화 기록을 반환
      return List<Map<String, dynamic>>.from(response.data['history']);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to fetch conversation history');
    }
  }
}