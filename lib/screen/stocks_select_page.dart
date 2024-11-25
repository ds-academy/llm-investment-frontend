import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:llm_invest_frontend/screen/ingame/game_main_page.dart';
import '../component/drawer_menu.dart';
import '../component/navigator_back_button.dart';
import '../model/game_service.dart';

class StocksSelectPage extends StatefulWidget {
  const StocksSelectPage({super.key, required this.alias});

  // 전달 받은 comapny alias 데이터
  final List<String> alias;

  @override
  State<StocksSelectPage> createState() => _StocksSelectPageState();
}

class _StocksSelectPageState extends State<StocksSelectPage> {

  final _storage = FlutterSecureStorage(); // Secure Storage 인스턴스 생성

  Future<void> _saveSelectedCompany(String companyName) async {
    await _storage.write(key: "selectedCompany", value: companyName); // 선택된 회사명 저장
  }

  Future<void> _resetChartRange() async {
    await _storage.write(key: "currentChartRange", value: "1");
  }

  // 메뉴바 scaffoldKey
  final navigatorObserver = MyNavigatorObserver().scaffoldKey;

  // 주식명 순서에 따른 알파벳
  final List<String> stockLabels = ['A', 'B', 'C'];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.blueAccent,
        key: navigatorObserver,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.blueAccent,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20),
              )
          ),
          elevation: 15,
          leading: IconButton(
            onPressed: () {null;},
            icon: Image.asset('assets/antlab_logo_small.png'),
          ),
          actions: [
            Builder(
              builder: (context) {
                return IconButton(
                  onPressed: () {
                    // 메뉴바 오픈
                    navigatorObserver.currentState?.openEndDrawer();
                  },
                  icon: const Icon(Icons.menu),
                );
              },
            ),
          ],
        ),
        endDrawer: menuBar(
          context,
          scaffoldKey: navigatorObserver,
        ), // 메뉴바 열기

        body: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Stocks\nSelect",
                  style: TextStyle(
                    fontFamily: 'Agro',
                    fontWeight: FontWeight.bold,
                    fontSize: 35,
                    height: 1,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  "플레이를 원하는 종목을 선택해 주세요.",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),

                Padding(
                  padding: EdgeInsets.zero, // 전체 padding을 추가할 수 있습니다
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // 세로 가운데 정렬
                    children: List.generate(widget.alias.length, (index) {
                      return Padding(
                        // 마지막 막대에는 하단 간격을 추가하지 않음
                        padding: EdgeInsets.only(bottom: index == 2 ? 0 : 30),
                        child: Row(
                          children: [
                            const SizedBox(width: 30), // 막대의 왼쪽 여백

                            Expanded(
                              child: Container(
                                height: MediaQuery.of(context).size.width * 0.25, // 막대의 높이
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border(
                                      left: BorderSide(color: Colors.blueAccent.shade400, width: 3),
                                      top: BorderSide(color: Colors.blueAccent.shade400, width: 3),
                                      bottom: BorderSide(color: Colors.blueAccent.shade400, width: 3),
                                    ),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      bottomLeft: Radius.circular(10),
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.white12,
                                        offset: Offset(0, 5),
                                        blurRadius: 5,
                                        spreadRadius: 2,
                                      )
                                    ]
                                ),

                                child: Row(
                                  children: [
                                    Flexible(
                                      flex: 1,
                                      child: Container(
                                        color: Colors.blueAccent[400],
                                        child: Center(
                                          child: Text(
                                            // 알파벳 라벨
                                            stockLabels[index],
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 30,
                                                fontWeight: FontWeight.bold
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5,),

                                    Flexible(
                                      flex: 4,
                                      child: Container(
                                        width: MediaQuery.of(context).size.width,
                                        height: MediaQuery.of(context).size.height,
                                        decoration: const BoxDecoration(
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            // company alias 텍스트
                                            Text(
                                              "  ${widget.alias[index]}", // 타이틀
                                              style: TextStyle(
                                                  color: Colors.blueAccent[700],
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    Flexible(
                                        flex: 1,
                                        // 인게임 페이지로 이동
                                        child: IconButton(
                                          onPressed: () async {
                                            // 선택한 회사 정보를 저장
                                            await _saveSelectedCompany(widget.alias[index]);

                                            // 게임 서비스 인스턴스 생성
                                            GameService gameService = GameService();

                                            try {
                                              String tokenId = "testid";
                                              String companyName = widget.alias[index];
                                              await gameService.fetchJoinGame(tokenId, companyName);

                                              // `currentChartRange`를 1로 초기화
                                              await _resetChartRange();
                                              await _storage.delete(key: "isGameEnd");
                                              await _storage.delete(key: "outnews_read");

                                              // fetchJoinGame이 성공적으로 완료되면 페이지 이동
                                              Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => GameMainPage(),
                                                ),
                                                    (route) => false,
                                              );
                                            } catch (e) {
                                              print("Error: $e");
                                              // 에러 처리 (예: 알림 창을 띄우기)
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Text("Error"),
                                                    content: Text("Failed to start game: $e"),
                                                    actions: [
                                                      TextButton(
                                                        child: Text("OK"),
                                                        onPressed: () {
                                                          Navigator.of(context).pop();
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            }
                                          },
                                          icon: Icon(
                                            Icons.keyboard_double_arrow_right_sharp,
                                            size: 30,
                                            color: Colors.blueAccent[700],
                                          ),
                                        )
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    ),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: TextButton(
                        onPressed: () {
                          // 주식 섹션 다시 고르게 뒤로가기
                          Navigator.pop(context);
                        },

                        child: RichText(
                          text: const TextSpan(
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                                WidgetSpan(
                                  child: Icon(
                                    Icons.keyboard_backspace_sharp,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                                TextSpan(text: " 섹션 다시 고르기"),
                              ]),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}