import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class SelectSector {
  final Dio dio = Dio();

  Future<String?> sendToSector(sector) async {
    String url = "http://10.0.2.2:3309/members/selectStocks";

    try {
      Response res = await dio.post(
        url, data: {"sector": sector,});

      print(res.data);
      print(res.realUri);

      if(res.statusCode == 200 && res.data['success'] == true) {
        final resData = json.decode(res.data);
        return resData['data'][3]; // 4번째 섹터명 컬럼 값 반환
      } else {
        print("Error: ${res.statusCode}");
        return null;
      }

    } catch(error) {
      print("Send to Sector Error: $error");
      return null;
    }

  }

}