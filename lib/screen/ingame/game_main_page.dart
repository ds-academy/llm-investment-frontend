import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../component/game_bottom_bar.dart';
import '../../component/game_in_menu.dart';
import '../../popup/newsbreak_popup.dart';
import '/screen/ingame/chart_page.dart';
import '/screen/ingame/news_page.dart';
import '/screen/ingame/report_page.dart';
import '/screen/ingame/financial_page.dart';
import '../../component/game_app_bar.dart';
import 'game_chat_bot.dart';

class GameMainPage extends StatefulWidget {
  final String? warningNews; // 경고 뉴스 데이터를 받음

  const GameMainPage({super.key, this.warningNews});

  @override
  State<GameMainPage> createState() => _GameMainPageState();
}

class _GameMainPageState extends State<GameMainPage> {
  final storage = const FlutterSecureStorage(); // Secure Storage 인스턴스 생성
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Scaffold Key

  String companyName = ""; // 불러온 회사명을 저장할 변수
  int currentChartRange = 1; // 초기 표시 범위
  final int maxTurns = 4; // 최대 턴 수 (4번만 넘기기 가능)
  String currentView = 'chart'; // 현재 보여줄 페이지 (기본값: 차트)

  @override
  void initState() {
    super.initState();
    _loadSelectedCompany(); // 저장된 회사명 불러오기
    _loadChartRange(); // 저장된 차트 범위를 불러오기

    if (widget.warningNews != null && widget.warningNews!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        NewsbreakPopup.show(
          context,
          title: "긴급 뉴스 특보!",
          content: widget.warningNews!,
          onConfirm: () {
            setState(() {
              currentView = 'news';
            });
          },
        );
      });
    }
  }

  Future<void> _loadSelectedCompany() async {
    String? savedCompany = await storage.read(key: "selectedCompany");
    setState(() {
      companyName = savedCompany ?? "회사명 없음";
    });
  }

  Future<void> _loadChartRange() async {
    String? savedRange = await storage.read(key: "currentChartRange");
    setState(() {
      currentChartRange = int.tryParse(savedRange ?? '1') ?? 1;
    });
  }

  Future<void> _saveChartRange() async {
    await storage.write(key: "currentChartRange", value: currentChartRange.toString());
  }

  void _handleNextDetailTurn() async {
    if (currentChartRange < maxTurns) {
      setState(() {
        currentChartRange++;
      });
      await _saveChartRange();
    }
  }

  void _changeView(String view) {
    setState(() {
      currentView = view;
    });
  }

  Widget _getCurrentPage() {
    switch (currentView) {
      case 'news':
        return NewsPage();
      case 'report':
        return ReportPage();
      case 'financial':
        return FinancialPage();
      case 'chart':
      default:
        return ChartPage(
          currentRange: currentChartRange,
        );
    }
  }

  void _showChatBotDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return const GameChatBot();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      key: _scaffoldKey,
      appBar: GameAppBar(scaffoldKey: _scaffoldKey),
      endDrawer: gameMenuBar(context, scaffoldKey: _scaffoldKey),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                child: Column(
                  children: [
                    SizedBox(
                      height: screenHeight * 0.6,
                      child: _getCurrentPage(), // 현재 선택된 페이지 표시
                    ),
                    SizedBox(
                      height: screenHeight * 0.3,
                      child: GameBottomBar(
                        isNextTurnEnabled: currentChartRange < maxTurns,
                        onViewChange: _changeView,
                        onNextDetailTurn: _handleNextDetailTurn,
                        selectedView: currentView,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: screenWidth * 0.03, // 화면 너비의 5%만큼 우측에 위치
              bottom: screenHeight * 0.16, // 화면 높이의 10%만큼 아래에 위치
              child: GestureDetector(
                onTap: () => _showChatBotDialog(context),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/chat_icon.png',
                    width: screenWidth * 0.22, // 화면 너비의 12% 크기로 설정
                    height: screenWidth * 0.22, // 화면 너비의 12% 크기로 설정
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
