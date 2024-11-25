import 'package:easy_rich_text/easy_rich_text.dart';
import 'package:flutter/material.dart';
import 'package:llm_invest_frontend/component/drawer_menu.dart';
import 'package:llm_invest_frontend/component/navigator_back_button.dart';
import 'package:llm_invest_frontend/component/rank_home_screen.dart';
import 'package:llm_invest_frontend/model/check_save_service.dart';
import 'package:llm_invest_frontend/model/stock_tip_say_word_data.dart';
import 'package:llm_invest_frontend/screen/splash_page.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 메뉴바 scaffoldKey
  final navigatorObserver = MyNavigatorObserver().scaffoldKey;

  // 오늘의금융 페이지 컨트롤
  final PageController _randPageController = PageController(initialPage: 500);

  // 새 게임 여부 확인 팝업
  final CheckSaveService _checkSaveService = CheckSaveService();

  // 팁, 조언, 용어 리스트를 가져오는 Future
  late Future<List<Map<String, dynamic>>> _getStockWords;
  // 데이터 리스트를 초기화 (로컬 데이터 제거)
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    // 팁, 조언, 용어 데이터를 가져오는 Future
    _getStockWords = StockAndTipAndSayData().stockTipWordSaysGet(context);
  }

  @override
  void dispose() {
    _randPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
        future: _getStockWords,  // 실제 데이터 로딩
        builder: (context, snapshot)
    {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const  SplashPage(); // 데이터 로딩 중S
      }
      if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}')); // 에러 처리
      }
      // 데이터가 정상적으로 로드된 경우
      if (snapshot.hasData) {
        items = snapshot.data!; // 서버에서 가져온 데이터를 items 리스트에 할당
      }
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          key: navigatorObserver,
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: Colors.blueAccent,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                )),
            elevation: 15,
            leading: IconButton(
              onPressed: () {
                null;
              },
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
          ),
          // 메뉴바 열기

          body: Column(
            children: [
              Flexible(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.blueAccent,
                              width: 3),
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(left: 10, right: 10),
                          // color: Colors.grey,
                          child: PageView.builder(
                            controller: _randPageController,
                            itemCount: null,
                            itemBuilder: (context, index) {
                              // 페이지를 루프시키기 위해 index % 3 사용
                              int loopedIndex = index % 3;
                              final item = items[loopedIndex]; // 각 페이지에 해당하는 항목 가져오기

                              // 항목이 'stockWords'를 포함하면 해당 UI를 렌더링
                              if (item.containsKey('stockWords')) {
                                final stockWord = item['stockWords'][0]; // 'stockWords' 항목 가져오기
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    EasyRichText(
                                      "오늘의 금융단어",
                                      defaultStyle: TextStyle(
                                        fontSize: MediaQuery
                                            .of(context)
                                            .size
                                            .width * 0.05,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      patternList: [
                                        EasyRichTextPattern(
                                          targetString: "금융단어",
                                          style: TextStyle(
                                            color: Colors.blueAccent[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    ElevatedButton(
                                      onPressed: () {
                                        null;
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blueAccent[700],
                                      ),
                                      child: Text(
                                        stockWord['STOCK_WORD'],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: MediaQuery
                                              .of(context)
                                              .size
                                              .width * 0.04,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        softWrap: true,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      stockWord['STOCK_WORD_DESCRIPTION'],
                                      style: TextStyle(
                                        fontSize: MediaQuery
                                            .of(context)
                                            .size
                                            .width * 0.04,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                );
                              }
                              // 항목이 'stockTips'를 포함하면 해당 UI를 렌더링
                              else if (item.containsKey('stockTips')) {
                                final stockTip = item['stockTips'][0]; // 'stockTips' 항목 가져오기
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    EasyRichText(
                                      "오늘의 주식 팁",
                                      defaultStyle: TextStyle(
                                        fontSize: MediaQuery
                                            .of(context)
                                            .size
                                            .width * 0.05,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      patternList: [
                                        EasyRichTextPattern(
                                          targetString: "주식 팁",
                                          style: TextStyle(
                                            color: Colors.blueAccent[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 15),
                                    Text(
                                      stockTip['STOCK_TIP_DESCRIPTION'],
                                      style: TextStyle(
                                        fontSize: MediaQuery
                                            .of(context)
                                            .size
                                            .width * 0.04,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                );
                              }

                              // 항목이 'wiseSays'를 포함하면 해당 UI를 렌더링
                              else if (item.containsKey('wiseSays')) {
                                final wiseSay = item['wiseSays'][0]; // 'wiseSays' 항목 가져오기
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    EasyRichText(
                                      "오늘의 명언",
                                      defaultStyle: TextStyle(
                                        fontSize: MediaQuery
                                            .of(context)
                                            .size
                                            .width * 0.05,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      patternList: [
                                        EasyRichTextPattern(
                                          targetString: "명언",
                                          style: TextStyle(
                                            color: Colors.blueAccent[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    ElevatedButton(
                                      onPressed: () {
                                        null;
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blueAccent[700],
                                      ),
                                      child: Text(
                                        wiseSay['WISE_SAY'],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: MediaQuery
                                              .of(context)
                                              .size
                                              .width * 0.04,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        softWrap: true,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      wiseSay['WISE_SAY_DESCRIPTION'],
                                      style: TextStyle(
                                        fontSize: MediaQuery
                                            .of(context)
                                            .size
                                            .width * 0.04,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                );
                              } else {
                                // 예외처리 (데이터가 없거나 예상치 못한 형식의 데이터가 온 경우)
                                return const Center(
                                  child: Text(
                                    "ERROR",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),

                      // SmoothPageIndicator 패키지 사용
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 10,
                        child: Center(
                          child: SmoothPageIndicator(
                            controller: _randPageController,
                            count: 3,
                            effect: const ColorTransitionEffect(
                              dotHeight: 8,
                              dotWidth: 8,
                              activeDotColor: Colors.indigoAccent,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            // 뉴게임 시작 버튼 기능
                            _checkSaveService.gameIdxCheck(context);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "뉴 게임",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      SizedBox(width: 4,),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            // 뉴게임 시작 버튼 기능
                            _checkSaveService.gameSavedCheck(context);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.greenAccent[700],
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text(
                            "이어하기",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                flex: 4,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 4, 16, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.blueAccent[700],
                    ),

                    // 컨테이너 내부의 랭킹 리스트
                    child: Column(
                      children: [
                        Flexible(
                          flex: 1,
                          child: Container(
                            alignment: Alignment.centerLeft,
                            margin: const EdgeInsets.fromLTRB(24, 10, 24, 0),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.wb_iridescent_sharp,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 10,),

                                Text(
                                  "내 랭킹",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // 랭킹 리스트 칸
                        Flexible(
                          flex: 5,
                          child: Container(
                              height: MediaQuery
                                  .of(context)
                                  .size
                                  .height,
                              margin: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),

                              // 랭킹 리스트 출력
                              child: RankListComponent()
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    );
  }
}
