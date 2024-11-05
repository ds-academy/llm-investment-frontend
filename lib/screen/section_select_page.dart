import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:llm_invest_frontend/model/select_sector.dart';
import 'package:llm_invest_frontend/screen/stocks_select_page.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../component/drawer_menu.dart';
import '../component/navigator_back_button.dart';

class SectionSelectPage extends StatefulWidget {
  const SectionSelectPage({super.key});

  @override
  State<SectionSelectPage> createState() => _SectionSelectPageState();
}

class _SectionSelectPageState extends State<SectionSelectPage> {

  // 메뉴바 scaffoldKey
  final navigatorObserver = MyNavigatorObserver().scaffoldKey;

  // 주식종목 섹션 페이지 컨트롤 (CarouselSlider, SmoothPageIndicator)
  final CarouselSliderController sectionPageController =
      CarouselSliderController();
  int _currentIndex = 0; // 섹션 페이지 인덱스 추적

  // 섹션 메뉴 이미지
  final List<Map<String, String>> sectionImgList = [
    {'imagePath': 'assets/sections/section_menu_1.png', 'sector': '생물공학'},
    {'imagePath': 'assets/sections/section_menu_2.png', 'sector': '제약'},
    {'imagePath': 'assets/sections/section_menu_3.png', 'sector': '게임엔터'},
    {'imagePath': 'assets/sections/section_menu_4.png', 'sector': '방송엔터'},
    {'imagePath': 'assets/sections/section_menu_5.png', 'sector': '항공사'},
    {'imagePath': 'assets/sections/section_menu_6.png', 'sector': '건설사'},
    {'imagePath': 'assets/sections/section_menu_7.png', 'sector': '전기제품'},
  ];

  // sector 텍스트 값 전송 객체
  Future<void> onImageTap(BuildContext context, String sector) async {
    final SelectSector _selectSector = SelectSector();
    final sectorColumValue = await _selectSector.sendToSector(sector);
    if (sectorColumValue != null) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => StocksSelectPage(sectorColumValue: sectorColumValue))
      );
    }

  }

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

        body: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.blueAccent,

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  " Select\nSection",
                  style: TextStyle(
                    fontFamily: 'Agro',
                    fontWeight: FontWeight.bold,
                    fontSize: 35,
                    height: 1,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15,),

                const Text(
                  "진행하고 싶은 섹션을 선택해 주세요.",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),

                // 주식종목 목록, CarouselSlider 패키지 사용
                CarouselSlider(
                  carouselController: sectionPageController,
                  items: sectionImgList.map(
                    (items) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Stack(
                            children: [
                              SizedBox(
                                // color: Colors.grey,
                                width: MediaQuery.of(context).size.width,
                                // margin: EdgeInsets.symmetric(horizontal: 5),
                                child: Image.asset(
                                  items['imagePath']!,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 10,
                                  // 주식 선택 페이지로 이동 버튼 영역
                                  child: GestureDetector(
                                    onTap: (){
                                      onImageTap(context, items['sector']!);
                                    },
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.transparent,
                                      ),
                                    ),
                                  ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ).toList(),
                  options: CarouselOptions(
                      height: 400,
                      // 세로 공간 조절
                      viewportFraction: 0.655,
                      // 가로 공간 조절
                      autoPlay: false,
                      enlargeCenterPage: true,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentIndex = index;
                        });
                      }),
                ),
                const SizedBox(height: 15,),

                Center(
                  child: SmoothPageIndicator(
                    controller: PageController(initialPage: _currentIndex),
                    count: sectionImgList.length,
                    effect: const ColorTransitionEffect(
                      dotHeight: 10,
                      dotWidth: 10,
                      activeDotColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
