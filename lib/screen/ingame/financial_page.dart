import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../popup/read_data_popup.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FinancialPage extends StatefulWidget {
  const FinancialPage({Key? key}) : super(key: key);

  @override
  State<FinancialPage> createState() => _FinancialPageState();
}

class _FinancialPageState extends State<FinancialPage> {
  List<Map<String, String>> financialList = [];
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://default-url.com';
  int? selectedIndex; // 선택된 항목의 인덱스 저장

  @override
  void initState() {
    super.initState();
    fetchFinancialData();
  }

  Future<void> fetchFinancialData() async {
    try {
      // 스토리지에서 토큰 읽기
      String? token = await storage.read(key: "token");

      if (token == null || token.isEmpty) {
        print("토큰이 없습니다.");
        return;
      }

      // 서버에서 재무 데이터 가져오기
      final response = await Dio().post(
        '$baseUrl/game/financial',
        data: {'token': token},
      );

      if (response.statusCode == 200 && response.data['success']) {
        List<dynamic> financialData = response.data['financial'];

        setState(() {
          // 가져온 데이터를 리스트에 저장
          financialList = financialData.map((item) {
            return {
              "title": item['FINANCIAL_STATEMENTS_TITLE']?.toString() ?? '',
              "description": item['FINANCIAL_STATEMENTS_INFO']?.toString() ?? ''
            };
          }).toList();
        });
      }
    } catch (e) {
      print("Error fetching financial data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildFinancialList(),
    );
  }

  Widget _buildFinancialList() {
    // 리스트를 역순으로 변환
    final reversedFinancialList = financialList.reversed.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 1.0),
      itemCount: reversedFinancialList.length,
      itemBuilder: (context, index) {
        final financial = reversedFinancialList[index];
        final isSelected = selectedIndex == index;

        return GestureDetector(
          onTap: () async {
            setState(() {
              selectedIndex = index; // 클릭된 항목 인덱스 저장
            });

            // 팝업을 await로 기다림
            await ReadDataPopup.show(
              context,
              title: financial['title'] ?? '',
              content: financial['description'] ?? '',
            );

            // 팝업이 닫히면 선택 상태 초기화
            setState(() {
              selectedIndex = null;
            });
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6.0),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blueAccent : Colors.white, // 선택된 항목의 배경색 변경
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              leading: Text(
                "${reversedFinancialList.length - index}", // 인덱스를 역순으로 출력
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black, // 선택 시 글자 색상 변경
                ),
              ),
              title: Text(
                financial['title'] ?? '',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black, // 선택 시 글자 색상 변경
                ),
              ),
              subtitle: Text(
                financial['description'] ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected ? Colors.white70 : Colors.black54, // 선택 시 글자 색상 변경
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isSelected ? Colors.white : Colors.black, // 선택 시 아이콘 색상 변경
              ),
            ),
          ),
        );
      },
    );
  }
}
