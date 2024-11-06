import 'package:flutter/material.dart';

class MyNavigatorObserver extends NavigatorObserver {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // EndDrawer가 열려있으면 닫기
    // 메뉴바가 열려 있을때 백버튼 터치 시, 메뉴만 닫히는 코드
    if (scaffoldKey.currentState?.isEndDrawerOpen ?? false) {
      scaffoldKey.currentState?.closeEndDrawer();
    }
    super.didPop(route, previousRoute);
  }
}
