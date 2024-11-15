import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../component/game_bottom_bar.dart';
import '../../popup/newsbreak_popup.dart';
import '/screen/ingame/chart_page.dart';
import '/screen/ingame/news_page.dart';
import '/screen/ingame/report_page.dart';
import '/screen/ingame/financial_page.dart';
import '../../component/game_app_bar.dart';

class GameMainPage extends StatefulWidget {
  final String? warningNews; // 경고 뉴스 데이터를 받음
  const GameMainPage({super.key, this.warningNews});

  @override
  State<GameMainPage> createState() => _GameMainPageState();
}

class _GameMainPageState extends State<GameMainPage> {
  final storage = const FlutterSecureStorage(); // Secure Storage 인스턴스 생성
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    int leftoverTurns = maxTurns - currentChartRange;

    return MaterialApp(
      home: Scaffold(
        appBar: GameAppBar(),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: _getCurrentPage(), // 현재 선택된 페이지 표시
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.3,
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
        ),
      ),
    );
  }
}
