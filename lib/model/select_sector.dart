import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class SelectSector {
  final Dio dio = Dio();

  Future<List<String>?> sendToSector(sector) async {
    String url = "http://10.0.2.2:3309/members/selectstocks";

    try {
      Response res = await dio.post(
          url, data: {"sector": sector});

      print(res.data);
      print(res.realUri);

      if(res.statusCode == 200) {
        // 응답이 성공적인 경우
        final Map<String, dynamic> resData = res.data;

        // 응답받은 JSON 데이터 확인
        if (resData['success'] == true) {
          // 'alias' 필드에서 데이터 리스트 가져오기
          return List<String>.from(resData['alias']);

        } else {
          // success: False인 경우
          print(resData['error']);
          return null;
        }

      } else {
        throw Exception('Failed to load data, status code: ${res.statusCode}');
      }

    } catch(error) {
      print("Send to Sector Error: $error");
      return null;
    }

  }
}