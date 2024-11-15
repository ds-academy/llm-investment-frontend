import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'game_app_bar_data.dart';
import 'game_bottom_bar_data.dart';
import 'game_chart_data.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GameService {
  final Dio _dio = Dio();
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://default-url.com';

  Future<Map<String, dynamic>> fetchJoinGame(String token, String companyName) async {
    try{
      final response = await _dio.post(
        '$baseUrl/game/start',
        data: {
          'token': token,
          'companyName': companyName,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        print("응답 데이터 :  $response");
        return response.data;
      } else {
        throw Exception('Failed to load chart data');
      }

    } catch(e){
      throw Exception("Error fetching chart data: $e");
    }
  }

  Future<GameAppBarData> fetchGameAppBar(String token) async {
    print("fetchGameAppBar 호출됨, token: $token");
    try{
      final response = await _dio.post(
        '$baseUrl/game/app_bar',
        data: {
          'token': token,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        print("앱 바 데이터 :  $response");
        return GameAppBarData.fromJson(response.data);
      } else {
        throw Exception('Failed to load chart data');
      }

    } catch(e){
      throw Exception("Error fetching chart data: $e");
    }
  }

  Future<GameBottomBarData> fetchGameBottomBar(String token) async {
    print("fetchGameBottomBar 호출됨, token: $token");
    try{
      final response = await _dio.post(
        '$baseUrl/game/bottom_bar',
        data: {
          'token': token,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        print("하단 바 데이터 :  $response");
        return GameBottomBarData.fromJson(response.data);
      } else {
        throw Exception('Failed to load chart data');
      }

    } catch(e){
      throw Exception("Error fetching chart data: $e");
    }
  }

  Future<GameChartData> fetchChartData(String token) async {
    try {
      final response = await _dio.post(
        '$baseUrl/game/chart',
        data: {
          'token': token,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        print("응답 데이터 :  $response");
        return GameChartData.fromJson(response.data);
      } else {
        throw Exception('Failed to load chart data');
      }
    } catch (e) {
      throw Exception("Error fetching chart data: $e");
    }
  }

  Future<Map<String, dynamic>> nextDetailTurn(String token) async {
    final response = await _dio.post(
      '$baseUrl/game/next_detail_turn',
      data: {'token': token},
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> nextTurn(String token, int currentMoney, int positionMoney) async {
    final response = await _dio.post(
    '$baseUrl/game/next_turn',
    data: {
      'token': token,
      'currentMoney' : currentMoney,
      'positionMoney' : positionMoney
    },
    options: Options(headers: {'Content-Type': 'application/json'}),
    );
  return response.data;
  }

  Future<Map<String, dynamic>> fetchWarningNews(String token) async {
    try {
      final response = await _dio.post(
        '$baseUrl/game/warning',
        data: {'token': token},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception("Failed to fetch news");
      }
    } catch (e) {
      throw Exception("Error fetching news: $e");
    }
  }

  Future<Map<String, dynamic>> fetchEndGame(String token, double profitRate) async {
    try {
      final response = await _dio.post(
        '$baseUrl/game/game_end',
        data: {
          'token': token,
          'profitRate': profitRate
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception("Failed to fetch news");
      }
    } catch (e) {
      throw Exception("Error fetching news: $e");
    }
  }

}
