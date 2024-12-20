import 'package:flutter/material.dart';

import '../../main.dart';
import 'package:intl/intl.dart';

class GameEndFail extends StatefulWidget {
  final int totalAssets;
  final double profitRate;

  const GameEndFail(this.totalAssets, this.profitRate, {Key? key}) : super(key: key);

  @override
  State<GameEndFail> createState() => _GameEndFailState();
}

class _GameEndFailState extends State<GameEndFail> {

  String formatNumber(int number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/lose_text.png"),
                  const SizedBox(height: 20),
                  Image.asset(
                    "assets/game_fail.png",
                    width: MediaQuery.of(context).size.width * 0.7,
                  ),
                  const SizedBox(height: 20),

                  // 총 자산 표시
                  Text(
                    "${formatNumber(widget.totalAssets)} 원",
                    style: TextStyle(
                      color: Colors.blueAccent[400],
                      fontSize: MediaQuery.of(context).size.width * 0.08,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "게임 결과 (Pt)",
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width * 0.045,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // 수익률과 점수 표시
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text("수익률"),
                                Text("점수"),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "${widget.profitRate.toStringAsFixed(2)}%",
                                  style: TextStyle(
                                    color: widget.profitRate > 0
                                        ? Colors.green
                                        : Colors.blueAccent[400],
                                  ),
                                ),
                                Text(
                                  "${(widget.profitRate * 100).toInt()}",
                                  style: TextStyle(
                                    color: widget.profitRate > 0
                                        ? Colors.green
                                        : Colors.blueAccent[400],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),

                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => MyApp()),
                                    (route) => false,
                              );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blueAccent[400],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: const Text(
                              "홈 화면으로",
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
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
