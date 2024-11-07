import 'package:flutter/material.dart';
import 'package:llm_invest_frontend/screen/login_page.dart';
import 'package:llm_invest_frontend/screen/home_page.dart';
import 'package:llm_invest_frontend/screen/splash_page.dart';
import 'component/navigator_back_button.dart';
import 'model/auth_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // AuthService 인스턴스 생성
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(),
      home: FutureBuilder<bool>(
          future: _authService.isLoggedIn(), // 로그인 상태 확인
          builder: (context, snapshot) {
            // 로딩 상태일 때 로딩 페이지 표시
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SplashPage();
            } else {
              // 로그인 상태 확인
              if (snapshot.hasData) {
                bool loginCheck = snapshot.data!; // 로그인 상태 값
                // 로그인 상태에 따라 페이지를 결정
                return loginCheck ? const HomePage() : const LoginPage();
                // 로그인된 경우 홈 페이지, 비로그인 상태인 경우 로그인 페이지
              }
              // 에러 처리 또는 기본 로그인 페이지 반환
              return const LoginPage();
            }
          }),
      navigatorObservers: [MyNavigatorObserver()],
    );
  }
}
