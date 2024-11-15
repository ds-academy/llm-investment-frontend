import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:llm_invest_frontend/popup/buy_game_screen.dart';
import '../model/game_service.dart';
import '../model/game_bottom_bar_data.dart';
import '../popup/check_game_popup.dart';
import '../popup/sell_game_screen.dart';
import '../screen/ingame/game_end_fail.dart';
import '../screen/ingame/game_end_success.dart';
import '../screen/ingame/game_main_page.dart';
import 'package:intl/intl.dart';


class GameBottomBar extends StatefulWidget {
  final VoidCallback onNextDetailTurn;
  final bool isNextTurnEnabled;
  final Function(String) onViewChange;
  final String selectedView;

  const GameBottomBar({
    Key? key,
    required this.onNextDetailTurn,
    required this.isNextTurnEnabled,
    required this.onViewChange,
    required this.selectedView,
  }) : super(key: key);

  @override
  State<GameBottomBar> createState() => _GameBottomBarState();
}

class _GameBottomBarState extends State<GameBottomBar> {
  final GameService _gameService = GameService();
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  late Future<GameBottomBarData> _bottomBarData;
  bool isGameEnd = false;

  @override
  void initState() {
    super.initState();
    _loadBottomBarData();
    _checkGameEndStatus(); // 게임 종료 상태 체크
  }

  Future<void> _checkGameEndStatus() async {
    final endStatus = await _storage.read(key: "isGameEnd");
    setState(() {
      isGameEnd = endStatus == "true";
    });
  }

  Future<void> _loadBottomBarData() async {
    final token = await _storage.read(key: "token");
    print("토큰 가져오기: $token");
    if (token != null && token.isNotEmpty) {
      setState(() {
        _bottomBarData = _gameService.fetchGameBottomBar(token);
      });
    }
  }

  Future<void> _handleNextDetailTurn() async {
    final token = await _storage.read(key: "token");
    if (token != null && token.isNotEmpty) {
      try {
        final response = await _gameService.nextDetailTurn(token);
        if (response['success']) {
          print("다음 상세 턴으로 성공적으로 진행되었습니다.");
          widget.onNextDetailTurn();
        } else {
          print("다음 상세 턴 진행 실패: ${response['message']}");
        }
      } catch (e) {
        print("Error: $e");
      }
    }
  }

  Future<void> _resetChartRange() async {
    await _storage.write(key: "currentChartRange", value: "1");
  }

  Future<void> _handleNextTurn(int currentMoney, int positionMoney) async {
    final token = await _storage.read(key: "token");
    if (token != null && token.isNotEmpty) {
      try {
        final response = await _gameService.nextTurn(token, currentMoney, positionMoney);
        if (response['success']) {
          final currentTurn = response['current_turn'];
          print("다음 턴으로 성공적으로 진행되었습니다.");

          // `currentChartRange`를 1로 초기화
          await _resetChartRange();
          // 현재 턴이 10이면 게임 종료 처리
          if (currentTurn >= 10) {
            setState(() {
              isGameEnd = true;
            });
            await _storage.write(key: "isGameEnd", value: "true");
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => GameMainPage(
                  warningNews: response['warning_news'],
                ),
              ),
                  (route) => false,
            );
          } else {
            // 메인 페이지로 이동하면서 현재 페이지를 제거
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => GameMainPage(
                  warningNews: response['warning_news'],
                ),
              ),
                  (route) => false,
            );
          }
        } else {
          print("다음 턴 진행 실패: ${response['message']}");
        }
      } catch (e) {
        print("Error: $e");
      }
    }
  }

  Future<void> _handleGameEnd(int totalAssets) async {
    print("게임 종료 중...");
    await _storage.delete(key: "isGameEnd"); // 게임 종료 시 상태 초기화
    await _resetChartRange(); // 차트 번호 초기화

    double profitRate = ((totalAssets - 100000000) / 100000000) * 100;
    print("최종 수익률: $profitRate%");

    final token = await _storage.read(key: "token");

    // 서버에 수익률 전송
    if (token != null) {
      try {
        await _gameService.fetchEndGame(token, profitRate);
        print("게임 점수 업데이트 성공");
      } catch (e) {
        print("게임점수 업데이트 실패: $e");
      }
    }

    if (profitRate > 0) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => GameEndSuccess(totalAssets, profitRate)),
            (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => GameEndFail(totalAssets, profitRate)),
            (route) => false,
      );
    }
  }

  String formatNumber(int number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GameBottomBarData>(
      future: _bottomBarData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text("Error loading data"));
        } else if (!snapshot.hasData) {
          return const Center(child: Text("No data available"));
        } else {
          final data = snapshot.data!;
          final totalAssets = data.currentMoney + (data.positionMoney*data.chartCurrent);
          final leftoverTurns = 4 - data.gameDetailTurn;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "남은횟수: $leftoverTurns",
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildButton("매수", Colors.red[300], Colors.red, data),
                      const SizedBox(width: 8),
                      _buildButton("매도", Colors.blue[300], Colors.blue, data),
                      const SizedBox(width: 8),
                      _buildButton(
                        "넘기기",
                        Colors.grey[400],
                        Colors.grey,
                        data,
                        onPressed: widget.isNextTurnEnabled ? widget.onNextDetailTurn : null,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.shade200,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      offset: const Offset(2, 2),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "자산가치: ${formatNumber(totalAssets)}",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              "가용자산: ${formatNumber(data.currentMoney)}",
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                            Text(
                              "현재 수익률: ${(((totalAssets - 100000000) / 100000000) * 100).toStringAsFixed(2)}%",
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12, bottom: 0),
                            child: TextButton(
                              onPressed: () async {
                                await CheckGamePopup.show(
                                  context,
                                  content: isGameEnd
                                      ? "게임 종료시 게임이 종료됩니다. 게임을 종료하시겠습니까?"
                                      : "정말로 다음 턴으로 진행하시겠습니까?",
                                  onConfirm: () async {
                                    final currentMoney = data.currentMoney;
                                    final positionMoney = data.positionMoney;

                                    if (isGameEnd) {
                                      // 게임 종료 버튼 클릭 시 게임 종료 함수 호출
                                      await _handleGameEnd(totalAssets);
                                    } else {
                                      // 다음 턴 진행
                                      await _handleNextTurn(currentMoney, positionMoney);
                                    }
                                  },
                                );
                              },
                              child: Text(
                                isGameEnd ? "게임 종료 →" : "턴 넘기기 →",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    // 두 번째 Divider 위젯 수정
                    const Divider(
                      color: Colors.white,
                      thickness: 1,
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildOutlinedButton("차트", "chart"),
                        _buildOutlinedButton("뉴스", "news"),
                        _buildOutlinedButton("리포트", "report"),
                        _buildOutlinedButton("재무제표", "financial"),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildButton(String text, Color? backgroundColor, Color? borderColor, GameBottomBarData data, {VoidCallback? onPressed}) {
    return OutlinedButton(
      onPressed: () async {
        if (text == "넘기기" && widget.isNextTurnEnabled) {
          // 넘기기 버튼 클릭 시 팝업 띄우기
          await CheckGamePopup.show(
            context,
            content: "정말로 넘기시겠습니까?",
            onConfirm: () async {
              await _handleNextDetailTurn(); // API 호출 함수
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => GameMainPage(),
                ),
                    (route) => false,
              );
            },
          );
        } else if (text == "매수" && widget.isNextTurnEnabled) {
          // 매수 버튼 클릭 시 BuyPage 팝업 띄우기
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                contentPadding: EdgeInsets.zero,
                content: BuyPage(
                  currentPrice: data.chartCurrent, //현재가
                  availableAssets: data.currentMoney, // 가용자산
                  holdings: data.positionMoney.toInt(), // 묶인 자산
                  onConfirm: () {
                    widget.onNextDetailTurn(); // 매수 완료 시 다음 턴으로 진행
                  }
                ), // 팝업으로 BuyPage 표시
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              );
            },
          );
        } else if (text == "매도" && widget.isNextTurnEnabled) {
          // 매수 버튼 클릭 시 BuyPage 팝업 띄우기
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                contentPadding: EdgeInsets.zero,
                content: SellPage(
                    currentPrice: data.chartCurrent, //현재가
                    availableAssets: data.currentMoney, // 가용자산
                    holdings: data.positionMoney.toInt(), // 묶인 자산
                    onConfirm: () {
                      widget.onNextDetailTurn(); // 매수 완료 시 다음 턴으로 진행
                    }
                ), // 팝업으로 BuyPage 표시
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              );
            },
          );
        } else {
          if (onPressed != null) onPressed();
        }
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        minimumSize: const Size(60, 20),
        side: BorderSide(color: borderColor ?? Colors.black),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildOutlinedButton(String text, String view) {
    final bool isSelected = widget.selectedView == view;

    return OutlinedButton(
      onPressed: () {
        widget.onViewChange(view);
      },
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(80, 35),
        side: const BorderSide(color: Colors.blueAccent),
        backgroundColor: isSelected ? Colors.white : Colors.transparent,
        foregroundColor: isSelected ? Colors.blue : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: isSelected ? Colors.blue : Colors.white,
        ),
      ),
    );
  }
}
