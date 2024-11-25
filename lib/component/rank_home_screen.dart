import 'package:easy_rich_text/easy_rich_text.dart';
import 'package:flutter/material.dart';
import 'package:llm_invest_frontend/screen/rank_full_page.dart';
import '../model/rank_list_data.dart';

// 랭킹 리스트 출력 위젯
class RankListComponent extends StatefulWidget {
  const RankListComponent({Key? key}) : super(key: key);

  @override
  State<RankListComponent> createState() => _RankListComponentState();
}

class _RankListComponentState extends State<RankListComponent> {
  late Future<List<Map<String, dynamic>>> _getRankList; // 랭킹 리스트를 가져오는 Future
  late Future<String?> _getIdToken; // 사용자 ID 토큰을 가져오는 Future

  @override
  void initState() {
    super.initState();
    // rankListGet을 호출하여 Future로 반환되는 비동기적 데이터를 받아옴
    _getRankList = RankListData().rankListGet(context);
    _getIdToken = RankListData().checkUserId(context);
  }

  @override
  Widget build(BuildContext context) {
    // FutureBuilder를 사용하여 _getIdToken에서 비동기적으로 가져온 사용자 ID를 처리
    return FutureBuilder<String?>(
      future: _getIdToken,
      builder: (context, snapshot) {
        // 로딩 중일 때
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        // 에러가 발생했을 때
        else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        // 사용자 데이터가 없을 때
        else if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: Text('No user data available'));
        }

        // centerTitle에 사용자 ID 값 할당
        final centerTitle = snapshot.data;

        // 랭킹 리스트를 가져오는 FutureBuilder
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _getRankList,
          builder: (context, rankSnapshot) {
            // 랭킹 데이터를 기다리는 중일 때
            if (rankSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            // 랭킹 데이터에 에러가 있을 때
            else if (rankSnapshot.hasError) {
              return Center(child: Text('Error: ${rankSnapshot.error}'));
            }
            // 랭킹 데이터가 없거나 비어 있을 때
            else if (!rankSnapshot.hasData || rankSnapshot.data!.isEmpty) {
              return Center(child: Text('No ranking data available'));
            }

            // 랭킹 리스트 데이터를 가져옴
            final rankList = rankSnapshot.data!;
            // centerTitle을 기준으로 인덱스 찾기
            final int centerIndex =
            rankList.indexWhere((item) => item['USER_ID'] == centerTitle);

            // 중심 타이틀을 기준으로 위아래 두 개씩 항목을 가져오는 로직
            final List<Map<String, dynamic>> limitedItems = centerIndex != -1
                ? (() {
              // 중심 타이틀의 위쪽으로 2개, 아래쪽으로 2개 항목을 기본으로 가져오기
              final int start =
              (centerIndex - 2).clamp(0, rankList.length - 1);
              final int end = (centerIndex + 3).clamp(0, rankList.length);

              // 부분 리스트 추출
              List<Map<String, dynamic>> sublist =
              rankList.sublist(start, end);

              // 부족한 항목이 있으면 위 또는 아래에서 더 가져오기
              if (sublist.length < 5) {
                final int remaining = 5 - sublist.length;
                if (start > 0) {
                  sublist = rankList.sublist(start - remaining, end);
                } else if (end < rankList.length) {
                  sublist = rankList.sublist(start, end + remaining);
                } else if (sublist.length < 5) {
                  sublist = rankList.take(5).toList();
                }
              }
              return sublist;
            })()
                : rankList.take(5).toList();

            // 리스트를 출력하는 부분
            return ListView(
              children: [
                Column(
                  children: limitedItems.map((item) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RankFullPage()),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(top: 1.0, bottom: 1.0),
                        // 상하 여백
                        padding: const EdgeInsets.symmetric(
                            vertical: 1.0, horizontal: 30.0),
                        // 좌우 여백
                        decoration: item['USER_ID'] == centerTitle
                            ? BoxDecoration(
                          border:
                          Border.all(color: Colors.grey, width: 1.0),
                          borderRadius: BorderRadius.circular(12),
                        )
                            : null,
                        // 중심 타이틀(로그인 유저)에는 테두리 추가
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          // 항목들이 좌측 정렬되도록 설정
                          crossAxisAlignment: CrossAxisAlignment.center,
                          // 세로로 중앙 정렬
                          children: [
                            // 왼쪽 아바타와 텍스트 부분
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // CircleAvatar 이미지 불러오기
                                CircleAvatar(
                                  // 크기는 고정 값 혹은 MediaQuery 값으로
                                  radius:
                                  MediaQuery.of(context).size.height * 0.03,
                                  backgroundColor: Colors.grey,
                                  backgroundImage:
                                  item['USER_PROFILE'] != null &&
                                      item['USER_PROFILE'].isNotEmpty ? NetworkImage(item['USER_PROFILE'])
                                      : null,
                                  child: item['USER_PROFILE'] == null
                                      ? const Icon(Icons.person, color: Colors.white)
                                      : null,
                                ),
                                SizedBox(width: 20), // 아바타와 텍스트 간격

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    EasyRichText(
                                      'Na: ${item['USER_NICKNAME']}',
                                      defaultStyle: TextStyle(
                                        fontSize:
                                        MediaQuery.of(context).size.height * 0.02, // 텍스트 크기 설정
                                      ),
                                      patternList: const [
                                        EasyRichTextPattern(
                                          targetString: 'Na:',
                                          style: TextStyle(
                                              color: Colors
                                                  .blueAccent), // ID 부분 파란색
                                        ),
                                      ],
                                    ),
                                    EasyRichText(
                                      'Pt: ${item['USER_SCORE']}',
                                      defaultStyle: TextStyle(
                                        fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.02, // 텍스트 크기 설정
                                      ),
                                      patternList: const [
                                        EasyRichTextPattern(
                                          targetString: 'Pt:',
                                          style: TextStyle(
                                              color: Colors
                                                  .blueAccent), // Pt 부분 파란색
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Spacer(),

                            // 오른쪽 랭킹 번호 표시
                            RichText(
                              text: TextSpan(
                                children: [
                                  if (rankList.indexOf(item) == 0) // 1위 금메달
                                    WidgetSpan(
                                      child: Image.asset(
                                        'assets/medal_gold.png', // 금메달 이미지 경로
                                        width:
                                        MediaQuery.of(context).size.width *
                                            0.06,
                                        height:
                                        MediaQuery.of(context).size.height *
                                            0.06,
                                      ),
                                    )
                                  else if (rankList.indexOf(item) ==
                                      1) // 2위 은메달
                                    WidgetSpan(
                                      child: Image.asset(
                                        'assets/medal_sliver.png',
                                        // 은메달 이미지 경로
                                        width:
                                        MediaQuery.of(context).size.width *
                                            0.06,
                                        height:
                                        MediaQuery.of(context).size.height *
                                            0.06,
                                      ),
                                    )
                                  else if (rankList.indexOf(item) ==
                                        2) // 3위 동메달
                                      WidgetSpan(
                                        child: Image.asset(
                                          'assets/medal_bronze.png',
                                          // 동메달 이미지 경로
                                          width:
                                          MediaQuery.of(context).size.width *
                                              0.06,
                                          height:
                                          MediaQuery.of(context).size.height *
                                              0.06,
                                        ),
                                      )
                                    else
                                      TextSpan(
                                        text:
                                        '${rankList.indexOf(item) + 1} ', // 랭킹 번호 텍스트
                                        style: TextStyle(
                                          fontSize:
                                          MediaQuery.of(context).size.height *
                                              0.03,
                                          color: Colors.black, // 기본 텍스트 색상
                                        ),
                                      ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
