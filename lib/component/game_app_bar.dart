import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../model/game_app_bar_data.dart';
import '../model/game_service.dart';

class GameAppBar extends StatefulWidget implements PreferredSizeWidget {
  const GameAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  State<GameAppBar> createState() => _GameAppBarState();
}

class _GameAppBarState extends State<GameAppBar> {
  final GameService _gameService = GameService();
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  late Future<GameAppBarData> _appBarData;

  @override
  void initState() {
    super.initState();
    _loadAppBarData();
  }

  Future<void> _loadAppBarData() async {
    final token = await _storage.read(key: "token");
    print("앱바에서 가져온 token: $token");

    if (token != null && token.isNotEmpty) {
      setState(() {
        _appBarData = _gameService.fetchGameAppBar(token);
      });
    } else {
      print("token이 존재하지 않습니다.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FutureBuilder<GameAppBarData>(
        future: _appBarData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return AppBar(
              title: const Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return AppBar(
              title: const Center(child: Text("Error loading data")),
            );
          } else if (!snapshot.hasData) {
            return AppBar(
              title: const Center(child: Text("No data available")),
            );
          } else {
            final data = snapshot.data!;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 회사 이름 표시
                  Text(
                    data.companyName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 현재 턴 표시
                      Text(
                        "${data.currentTurn+1}/10",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      // 차트 시간 표시
                      Text(
                        "${data.chartTime}",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.menu,
                    color: Colors.white,
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}