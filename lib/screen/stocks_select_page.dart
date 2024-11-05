import 'package:flutter/material.dart';
import 'package:llm_invest_frontend/screen/ingame/chart_page.dart';
import '../component/drawer_menu.dart';
import '../component/navigator_back_button.dart';

class StocksSelectPage extends StatefulWidget {
  const StocksSelectPage({super.key, required String sectorColumValue});

  @override
  State<StocksSelectPage> createState() => _StocksSelectPageState();
}

class _StocksSelectPageState extends State<StocksSelectPage> {
  // 메뉴바 scaffoldKey
  final navigatorObserver = MyNavigatorObserver().scaffoldKey;

  // 주식 종목 목록
  final List<Map<String, String>> stockContents = [
    {'title': '삼성 SDI1', 'subtitle': 'Samsung SDI1'},
    {'title': '삼성 SDI2', 'subtitle': 'Samsung SDI2'},
    {'title': '삼성 SDI3', 'subtitle': 'Samsung SDI3'}
  ];

  // 주식명 순서에 따른 알파벳
  final List<String> stockLabels = ['A', 'B', 'C'];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: navigatorObserver,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue,
          elevation: 15,
          leading: IconButton(
            onPressed: () {
              null;
            },
            icon: Image.asset('assets/chatbot_small.png'),
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

        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.blueAccent,
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
                  children: List.generate(stockContents.length, (index) {
                      return Padding(
                        // 마지막 막대에는 하단 간격을 추가하지 않음
                        padding: EdgeInsets.only(bottom: index == 2 ? 0 : 30),
                        child: Row(
                          children: [
                            const SizedBox(width: 40,), // 막대의 왼쪽 여백

                            Expanded(
                              child: Container(
                                height: 100, // 막대의 높이
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
                                              stockLabels[index],
                                              style: const TextStyle(
                                                color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold
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
                                            Text(
                                              "  ${stockContents[index]['title']!}", // 타이틀
                                              style: TextStyle(
                                                  color: Colors.blueAccent[700], fontSize: 18, fontWeight: FontWeight.bold
                                              ),
                                            ),
                                            const SizedBox(height: 4), // 타이틀과 서브타이틀 사이 간격
                                            Text(
                                              "  ${stockContents[index]['subtitle']!}",
                                              style: TextStyle(color: Colors.blueAccent[700], fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    Flexible(
                                      flex: 1,
                                      child: IconButton(
                                          onPressed: () {
                                            // 각 주식별 게임 화면으로 이동
                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => const ChartPage(),
                                              ), (route) => false,
                                            );
                                          },
                                          icon: Icon(
                                            Icons
                                                .keyboard_double_arrow_right_sharp,
                                            size: 30,
                                            color: Colors.blueAccent[700],
                                          )),
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
    );
  }
}
