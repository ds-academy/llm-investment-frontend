import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserService {
  final Dio _dio = Dio();
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://default-url.com';

  Future<Map<String, dynamic>> fetchUserProfile(String token) async {
    try {
      // 서버 API URL (백엔드에서 제공하는 경로)
      final response = await _dio.post(
        '$baseUrl/members/my_profile',
        data: {
          'token': token
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        return response.data; // JSON 형태로 반환
      } else {
        throw Exception('Failed to load user profile');
      }
    } catch (e) {
      throw Exception('Error fetching user profile: $e');
    }
  }
}