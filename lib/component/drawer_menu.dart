import 'package:flutter/material.dart';
import 'package:llm_invest_frontend/screen/login_page.dart';
import 'package:llm_invest_frontend/screen/profile_page.dart';
import '../model/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../model/user_service.dart';

// 메뉴바(Drawer) 전역 함수
Widget menuBar (BuildContext context, {required GlobalKey<ScaffoldState> scaffoldKey}) {

  // AuthService 인스턴스 생성
  final AuthService _authService = AuthService();
  final UserService userService = UserService();
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  return FutureBuilder<String?>(
    future: storage.read(key: 'token'), // SecureStorage에서 토큰 읽기
    builder: (context, tokenSnapshot) {
      if (tokenSnapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (tokenSnapshot.hasError || !tokenSnapshot.hasData || tokenSnapshot.data == null) {
        return const Center(child: Text("Failed to load token"));
      }

      final String token = tokenSnapshot.data!;

      // 사용자 프로필 가져오기
      return FutureBuilder<Map<String, dynamic>>(
        future: userService.fetchUserProfile(token), // API 호출
        builder: (context, profileSnapshot) {
          if (profileSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (profileSnapshot.hasError || !profileSnapshot.hasData) {
            return const Center(child: Text("Failed to load profile"));
          }

          final userInfo = profileSnapshot.data!['user_info'];
          final String profileImageUrl = userInfo['profile']; // 프로필 이미지
          final String nickname = userInfo['nickname']; // 닉네임

          // 메뉴바 UI
          return Drawer(
            child: Column(
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blueAccent[400],
                  ),
                  padding: EdgeInsets.zero,
                  child: UserAccountsDrawerHeader(
                    decoration: const BoxDecoration(color: Colors.transparent),
                    currentAccountPicture: CircleAvatar(
                      backgroundImage: NetworkImage(profileImageUrl), // 프로필 이미지 URL 사용
                      backgroundColor: Colors.white,
                    ),
                    otherAccountsPictures: [
                      IconButton(
                        onPressed: () {
                          // 메뉴바 닫기 버튼
                          scaffoldKey.currentState?.closeEndDrawer();
                        },
                        icon: const Icon(
                          Icons.close_sharp,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ],
                    accountName: Text(
                      nickname, // 닉네임 표시
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    accountEmail: null,
                  ),
                ),
                ListTile(
                  trailing: const Icon(Icons.keyboard_arrow_right),
                  title: const Text("내 정보"),
                  onTap: () {
                    // 설정 페이지 이동 코드
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfilePage()),
                    );
                  },
                ),
                ListTile(
                  trailing: const Icon(Icons.keyboard_arrow_right),
                  title: const Text("문의함"),
                  onTap: () {
                    // 문의 페이지 이동 코드
                  },
                ),
                ListTile(
                  trailing: const Icon(Icons.keyboard_arrow_right),
                  title: const Text("공지사항"),
                  onTap: () {
                    // 공지사항 페이지 이동 코드
                  },
                ),
                Spacer(),
                ListTile(
                    trailing: const Icon(Icons.logout_outlined),
                    title: Text("로그아웃"),
                    onTap: () async {
                      _authService.logout(context);
                      Navigator.pushAndRemoveUntil(context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                            (Route<dynamic> route) => false,
                      );
                    }
                ),
              ],
            ),
          );
        },
      );
    },
  );
}