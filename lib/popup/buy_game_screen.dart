import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; // Intl 패키지를 사용하여 숫자 포맷팅
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:llm_invest_frontend/screen/ingame/game_main_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class BuyPage extends StatefulWidget {
  final dynamic currentPrice; // 현재가
  final dynamic availableAssets; // 가용 자산
  final int holdings; // 묶인 자산
  final VoidCallback onConfirm; // 콜백 함수 추가

  const BuyPage({
    Key? key,
    required this.currentPrice,
    required this.availableAssets,
    required this.holdings,
    required this.onConfirm,
  }) : super(key: key);

  @override
  _BuyPageState createState() => _BuyPageState();
}

class _BuyPageState extends State<BuyPage> {
  int quantity = 0; // 수량
  int total = 0; // 총액
  String selectedOption = '직접 입력'; // 기본 옵션 설정

  final FlutterSecureStorage storage = const FlutterSecureStorage();

  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final Dio _dio = Dio();
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://default-url.com';

  Future<void> sendPurchaseRequest() async {
    String? token = await storage.read(key: "token");

    if (token == null || token.isEmpty) {
      print("토큰이 없습니다.");
      return;
    }
    try {
      // 서버로 데이터 전송
      final response = await _dio.post(
        "$baseUrl/game/buy",
        data: {
          'token': token, // 사용자의 토큰
          'quantity': quantity,
          'total': total,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200 && response.data['success']) {
        print("매수 완료: ${response.data['message']}");
        widget.onConfirm(); // 매수 성공 시 콜백 호출
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => GameMainPage(),
          ),
              (route) => false,
        );
      } else {
        print("매수 실패: ${response.data['message']}");
      }
    } catch (error) {
      print("에러 발생: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    int currentPrice = widget.currentPrice;
    int availableAssets = widget.availableAssets;
    int holdings = widget.holdings;

    // 최대 구매 가능 수량 계산
    int maxPurchaseableQuantity = (availableAssets / currentPrice).floor(); // 가용자산에 맞는 최대 수량

    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width - 10, // 양쪽 5씩 여백
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.blue, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              "매수",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            // 자산 정보
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "가용자산:  ",
                      style: TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            NumberFormat("#,##0").format(availableAssets), // 천 단위 포맷
                            style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 5),
                          Text(
                            "Pt",
                            style: TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "현재가:  ",
                      style: TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            NumberFormat("#,##0").format(currentPrice), // 천 단위 포맷
                            style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 5),
                          Text(
                            "Pt",
                            style: TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "보유수:  ",
                      style: TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            NumberFormat("#,##0").format(holdings), // 천 단위 포맷
                            style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 5),
                          Text(
                            "주",
                            style: TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            // 수량 입력 및 드롭다운 버튼
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: "수량",
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        setState(() {
                          quantity = int.tryParse(value) ?? 0;
      
                          // 최대 허용된 수량을 초과하면 최대값으로 고정
                          if (quantity > maxPurchaseableQuantity) {
                            quantity = maxPurchaseableQuantity;
                            // 텍스트 필드에 최대값으로 고정된 값을 표시
                            _controller.text = quantity.toString();
                            _controller.selection = TextSelection.fromPosition(
                              TextPosition(offset: _controller.text.length),
                            );
                          }
                          // 총액 계산
                          total = quantity * currentPrice;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(width: 10),
                // 드롭다운 버튼
                DropdownButton<String>(
                  value: selectedOption,
                  icon: const Icon(Icons.arrow_drop_down),
                  style: TextStyle(color: Colors.black),
                  dropdownColor: Colors.white,
                  items: <String>['직접 입력', '10%', '25%', '50%', '75%', '최대']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedOption = newValue!;
                      if (selectedOption == '직접 입력') {
                        quantity = 0; // 수량을 0으로 설정
                      } else if (selectedOption == '10%') {
                        quantity = (maxPurchaseableQuantity * 0.1).floor(); // 10% 수량 설정
                      } else if (selectedOption == '25%') {
                        quantity = (maxPurchaseableQuantity * 0.25).floor(); // 25% 수량 설정
                      } else if (selectedOption == '50%') {
                        quantity = (maxPurchaseableQuantity * 0.5).floor(); // 50% 수량 설정
                      } else if (selectedOption == '75%') {
                        quantity = (maxPurchaseableQuantity * 0.75).floor(); // 75% 수량 설정
                      } else if (selectedOption == '최대') {
                        quantity = maxPurchaseableQuantity; // 최대 수량 설정
                      }
      
                      // 선택된 수량을 TextField에도 반영
                      _controller.text = quantity.toString();
                      _controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: _controller.text.length),
                      );
      
                      total = quantity * currentPrice; // 총액 재계산
                    });
                  },
                  // 드롭다운 모양 수정
                  underline: Container(),
                  borderRadius: BorderRadius.circular(10),
                ),
              ],
            ),
            SizedBox(height: 10),
            // 총액 표시
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("총액 :", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                Text("${NumberFormat("#,##0").format(total)} Pt", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), // 천 단위 포맷
              ],
            ),
            SizedBox(height: 10),
            Divider(),
            // 보유 자산 정보 표시
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "보유자산 (Pt)",
                  style: TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("자산가치", style: TextStyle(color: Colors.black)),
                Text(NumberFormat("#,##0").format(availableAssets + currentPrice*holdings), // 천 단위 포맷, 보유수 출력
                    style: TextStyle(color: Colors.black)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("수익률", style: TextStyle(color: Colors.black)),
                Text("${((((availableAssets + (currentPrice * holdings)) - 100000000) / 100000000) * 100).toStringAsFixed(1)}%", style: TextStyle(color: Colors.red)), // 수익률 출력
              ],
            ),
            SizedBox(height: 20),
            // 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await sendPurchaseRequest();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 30),
                  ),
                  child: Text("확인", style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 30),
                  ),
                  child: Text("취소", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}