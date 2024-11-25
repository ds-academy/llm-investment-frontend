import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RankListData {
  final Dio dio = Dio();
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://default-url.com';

  Future<List<Map<String, dynamic>>> rankListGet(context) async {
    String url = '$baseUrl/members/rank_list';

    // 랭킹 데이터 저장할 변수
    List<Map<String, dynamic>> rankList = [];

    // 서버로 rank_list 요청
    final res = await dio.post(url);

    try {
      if (res.statusCode == 200) {
        final data = res.data;

        if (data['success'] == true) {
          rankList = List<Map<String, dynamic>>.from(data['rankList']);
          if (rankList.isNotEmpty) {
            // USER_PROFILE 경로를 서버 URL와 결합하여 절대 경로로 변환
            for (var item in rankList) {
              if (item['USER_PROFILE'] != null) {
                // 상대 경로가 있다면 절대 URL 형식으로 변환
                String relativePath = item['USER_PROFILE'];
                // 상대 경로가 이미 절대 경로 형태로 되어 있다면 변경하지 않음
                if (!relativePath.startsWith('http://') && !relativePath.startsWith('https://')) {
                  // 절대 경로 상태가 아니라면 결합
                  item['USER_PROFILE'] = '$baseUrl/$relativePath';
                }
              }
            }
            // print(rankList);
            return rankList; // 변환된 리스트 반환
          } else {
            print("No Ranking List Data");
          }
        } else {
          // 서버 오류 메시지 표시
          print("Server Error: ${data['error']}");
        }
      }
    } catch (error) {
      // 네트워크 오류 처리
      print('Network Error: ${error.toString()}');
    }
    // 오류 발생 시 빈 리스트 반환
    return [];
  }

  Future<String?> checkUserId(context) async {
    try {
      // Storage에서 아이디 토큰 조회
      final idToken = await storage.read(key: 'token');
      if (idToken == null) {
        print('error: 저장된 토큰이 없습니다. $context');
      } else {
        return idToken;
      }
    } catch (error) {
      // 네트워크 오류 처리
      print('Network Error: ${error.toString()}');
    }
    return null;
  }
}
