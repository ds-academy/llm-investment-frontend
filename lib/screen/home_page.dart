import 'package:easy_rich_text/easy_rich_text.dart';
import 'package:flutter/material.dart';
import 'package:llm_invest_frontend/component/drawer_menu.dart';
import 'package:llm_invest_frontend/component/navigator_back_button.dart';
import 'package:llm_invest_frontend/screen/section_select_page.dart';
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
  final PageController _tipPageController = PageController();

  // 서버로부터 받아올 데이터 리스트 (일단 로컬 데이터로 테스트)
  final List<String> _tipTitle = ['시가총액', '유동성', '배당수익률'];
  final List<String> _tipText = [
    '기업의 현재 주가에 발행 주식 수를 곱한 값으로, \n해당 기업의 시장 총 가치와 규모를 나타냅니다.',
    '자산과 부채를 빠르게 현금화할 수 있는 능력을 \n의미하며, 높을수록 시장에서 거래가 활발합니다.',
    '현재 주식 주가 대비 연간 배당금의 비율로, \n높을수록 안정적인 투자 수익을 기대할 수 있습니다.'
  ];

  // 랭킹 로컬 데이터 리스트
  final List<Map<String, dynamic >> items = [
    {'title': 'Title1', 'subtitle': 'Subtitle1', 'avatarColor': Colors.blue},
    {'title': 'Title2', 'subtitle': 'Subtitle2', 'avatarColor': Colors.green},
    {'title': 'Title3', 'subtitle': 'Subtitle3', 'avatarColor': Colors.orange},
    {'title': 'Title4', 'subtitle': 'Subtitle4', 'avatarColor': Colors.purple},
    {'title': 'Title5', 'subtitle': 'Subtitle5', 'avatarColor': Colors.red},
  ];

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
              onPressed: () {null;},
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
          endDrawer: menuBar(context,
            scaffoldKey: navigatorObserver,), // 메뉴바 열기

          body: Column(
            children: [
              Flexible(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.blueAccent, width: 3),
                        ),

                        // 금융단어 페이지뷰
                        child: PageView.builder(
                          controller: _tipPageController,
                          itemCount: 3, // 출력할 텍스트 개수
                          itemBuilder: (context, index) {
                            return Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // EasyRichText 패키지 사용
                                  EasyRichText(
                                    "오늘의 금융단어",
                                    defaultStyle: TextStyle(
                                      fontSize: MediaQuery.of(context).size.width * 0.05,
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
                                  SizedBox(height: 5,),

                                  ElevatedButton(
                                      onPressed: () {null;},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blueAccent[700],
                                      ),
                                      child: Text(
                                        _tipTitle[index],
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: MediaQuery.of(context).size.width * 0.04,
                                            fontWeight: FontWeight.bold),
                                      )),
                                  SizedBox(height: 5,),

                                  Text(
                                    _tipText[index],
                                    style: TextStyle(
                                        fontSize: MediaQuery.of(context).size.width * 0.04
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 10,
                        child: Center(
                          // SmoothPageIndicator 패키지 사용
                          child: SmoothPageIndicator(
                            controller: _tipPageController,
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
                            Navigator.push(context,
                              MaterialPageRoute(builder: (context) => const SectionSelectPage(),),
                            );
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
                            // 기존 게임 이어하기 버튼 기능
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
                  padding: EdgeInsets.fromLTRB(16, 4, 16, 2),
                  child: Container(
                    // width: MediaQuery.of(context).size.width,
                    // height: MediaQuery.of(context).size.height,
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
                            margin: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),

                            // 랭킹 리스트 출력
                            child: ListView(
                              shrinkWrap: true, // 리스트 크기를 컨테이너에 맞추기
                              children: items.map((item) {
                                return Container(
                                  color: Colors.white,
                                  // constraints: BoxConstraints(
                                  //   minHeight: 40, // 최소 높이 설정
                                  // ),
                                  margin: EdgeInsets.only(bottom: 2.0), // 아래쪽 여백
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 24.0), // 패딩 조정
                                    leading: CircleAvatar(
                                      backgroundColor: item['avatarColor'], // 원형 아바타 배경색
                                    ),
                                    trailing: Text('${items.indexOf(item) + 1}', style: TextStyle(fontSize: 20)), // 번호 추가
                                    title: Text('ID: ${item['title']}',), // 제목
                                    subtitle: Text('Pt: ${item['subtitle']}',), // 서브타이틀
                                    onLongPress: () {
                                      // 클릭 시 동작 코드

                                    },
                                  ),
                                );
                              },).toList(),
                            ),
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
}
