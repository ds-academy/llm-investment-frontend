import 'package:flutter/material.dart';

class MyNavigatorObserver extends NavigatorObserver {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // EndDrawer가 열려있으면 닫기
    if (scaffoldKey.currentState?.isEndDrawerOpen ?? false) {
      scaffoldKey.currentState?.closeEndDrawer();
    }
    super.didPop(route, previousRoute);
  }
}
