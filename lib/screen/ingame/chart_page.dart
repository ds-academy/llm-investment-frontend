import 'package:flutter/material.dart';
import 'package:llm_invest_frontend/component/game_in_menu.dart';
import '../../component/navigator_back_button.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {

  // 메뉴바 scaffoldKey
  final navigatorObserver = MyNavigatorObserver().scaffoldKey;

  // 하단 NavigationBar 컨트롤
  int _tabIndex = 0;
  late TabController _tabController;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: navigatorObserver,
        appBar: AppBar(
          backgroundColor: Colors.blueAccent[400],
          foregroundColor: Colors.white,
          elevation: 15,
          leading: Text("주식명"),
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
        endDrawer: gameMenuBar(
          context,
          scaffoldKey: navigatorObserver,
        ),
        // 메뉴바 열기

        body: Column(
          children: [
            Flexible(
              flex: 5,
              child: Container(
                color: Colors.orange
              )
            ),
            Flexible(
              flex: 1,
                child: Container(
                  color: Colors.green,
                )
            ),
            Flexible(
                flex: 1,
                child: Container(
                  color: Colors.blue,
                )
            ),
          ],
        ),

        // bottomNavigationBar 설정
        bottomNavigationBar: BottomNavigationBar(
            onTap: (int index) {
              _tabController.animateTo(index);
            },
            currentIndex: _tabIndex,

            showSelectedLabels: true,
            showUnselectedLabels: true,

            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.blueAccent[400],

            selectedItemColor: Colors.tealAccent[400],
            unselectedItemColor: Colors.white,
            selectedLabelStyle: TextStyle(color: Colors.tealAccent[400]),
            unselectedLabelStyle: TextStyle(color: Colors.white),

            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.insert_chart_outlined_outlined),
                label: '차트',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.newspaper_outlined),
                label: '뉴스',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.format_list_numbered_sharp),
                label: '리포트',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.view_list),
                label: '재무제표',
              ),
            ]
        ),
      ),
    );
  }
}
