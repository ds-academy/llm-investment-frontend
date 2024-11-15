import 'package:flutter/material.dart';
import '../screen/home_page.dart';

// 메뉴바(Drawer) 전역 함수
Widget gameMenuBar (BuildContext context, {required GlobalKey<ScaffoldState> scaffoldKey}) {

  return Drawer(
    child: Column(
      children: <Widget>[
        DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.blueAccent[400],),
          padding: EdgeInsets.zero,
          child: UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.transparent),
            currentAccountPicture: const CircleAvatar(
              backgroundImage: NetworkImage('https://github.com/identicons/lirc572.png'),
              backgroundColor: Colors.white,
            ),
            otherAccountsPictures: [
              IconButton(onPressed: (){
                // 메뉴바 닫기 버튼
                scaffoldKey.currentState?.closeEndDrawer();
              }, icon: const Icon(Icons.close_sharp,
                color: Colors.white,
                size: 32,
              ),),
            ],
            accountName: const Text("닉네임 (${null})",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: null,
          ),
        ),

        ListTile(
          trailing: const Icon(Icons.keyboard_arrow_right),
          title: const Text("설정"),
          onTap: () {
            // 설정 페이지 이동 코드
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
        // 게임종료 타일을 맨 하단으로 위치
        Spacer(),
        ListTile(
            trailing: const Icon(Icons.logout_outlined),
            title: Text("게임종료"),
            onTap: () async {
              // 게임종료 시 유저 데이터 저장 코드 추가 필요
              Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (context) => const HomePage()),
                    (Route<dynamic> route) => false,
              );
            }
        ),
      ],
    ),
  );
}