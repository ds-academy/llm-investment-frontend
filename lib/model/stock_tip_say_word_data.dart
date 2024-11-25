import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StockAndTipAndSayData {
  final Dio dio = Dio();
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://default-url.com';

  Future<List<Map<String, dynamic>>> stockTipWordSaysGet(context) async {
    String url = '$baseUrl/members/tip_stock_wise_words';
    print(url);

    // 팁 단어 리스트 저장할 변수
    List<Map<String, dynamic>> tipSayStockWords = [];

    // 서버로 tip_words 요청
    final res = await dio.post(url);

    try {
      if (res.statusCode == 200) {
        final data = res.data;

        if (data['success'] == true) {
          tipSayStockWords = List<Map<String, dynamic>>.from(
            data.entries
                .where((entry) => entry.key != 'success')  // 'success' 키를 제외한 항목만 필터링
                .map((entry) => Map<String, dynamic>.from({entry.key: entry.value}))
                .toList(),
          );
          if (tipSayStockWords.isNotEmpty) {
            // print(tipSayStockWords);
            return tipSayStockWords; // 리스트 반환
          } else {
            print("No tipSayStockWords List Data");
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
}