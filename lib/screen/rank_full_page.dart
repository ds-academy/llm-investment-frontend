import 'package:easy_rich_text/easy_rich_text.dart';
import 'package:flutter/material.dart';
import '../component/drawer_menu.dart';
import '../component/navigator_back_button.dart';
import '../model/rank_list_data.dart';
import '../popup/user_profile_popup.dart';

class RankFullPage extends StatefulWidget {
  const RankFullPage({super.key});

  @override
  State<RankFullPage> createState() => _RankFullPageState();
}

class _RankFullPageState extends State<RankFullPage> {

  // 메뉴바 scaffoldKey
  final navigatorObserver = MyNavigatorObserver().scaffoldKey;

  late Future<List<Map<String, dynamic>>> _getRankList;  // 랭킹 리스트를 가져오는 Future
  // late Future<String?> _getIdToken;  // 사용자 ID 토큰을 가져오는 Future

  List<Map<String, dynamic>> items = [];  // 데이터 리스트를 초기화 (로컬 데이터 제거)

  final int itemsPerPage = 5; // 한 번에 로드할 항목 수
  int currentMaxItems = 5; // 초기 로드 항목 수

  // 스크롤 컨트롤러
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
    _getRankList = RankListData().rankListGet(context);  // 사용자 데이터를 가져오는 Future
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndLoadMoreItems();
    });
  }

  void _checkAndLoadMoreItems() {
    if (_scrollController.position.maxScrollExtent == 0 &&
        currentMaxItems < items.length) {
      setState(() {
        currentMaxItems = (currentMaxItems + itemsPerPage).clamp(0, items.length);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {  // 100픽셀 남았을 때
      if (currentMaxItems < items.length) {  // 현재 로드된 항목 수가 전체 데이터 길이 보다 적으면
        setState(() {
          currentMaxItems = (currentMaxItems + itemsPerPage).clamp(0, items.length);  // 5개씩 더 로드
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(  // 데이터를 가져올 FutureBuilder
      future: _getRankList,  // 실제 데이터 로딩
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(
            backgroundColor: Colors.white,
          ),);  // 데이터 로딩 중
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));  // 에러 처리
        }

        // 데이터가 정상적으로 로드된 경우
        if (snapshot.hasData) {
          items = snapshot.data!;  // 서버에서 가져온 데이터를 items 리스트에 할당
        }


        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: Colors.blueAccent,
            key: navigatorObserver,
            appBar: AppBar(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blueAccent[700],
              title: const Text("AntLAB 랭킹"),
              centerTitle: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              elevation: 15,
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back_sharp),
              ),
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
            endDrawer: menuBar(
              context,
              scaffoldKey: navigatorObserver,
            ), // 메뉴바 열기

            body: Column(
              children: [
                // 순위별 단상 이미지
                Expanded(
                    flex: 2,
                    child: Stack(
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(8, 16, 8, 0),
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/rank_top_three.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        // 랭킹 2위 원형 아바타
                        Positioned(
                          top: MediaQuery.of(context).size.height * 0.05, // 단상 이미지 위에서의 위치
                          left: MediaQuery.of(context).size.width * 0.24, // 왼쪽에서의 위치
                          child: Column(
                            children: [
                              Text(
                                items[1]['USER_NICKNAME'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(35),
                                  border: Border.all(color: Colors.grey.shade400, width: 2),
                                ),
                                child: CircleAvatar(
                                  radius: 30, // 아바타 크기 설정
                                  backgroundColor: Colors.grey,
                                  backgroundImage: items[1]['USER_PROFILE'] != null &&
                                      items[1]['USER_PROFILE'].isNotEmpty ? NetworkImage(items[1]['USER_PROFILE'])
                                      : null,
                                  child: items[1]['USER_PROFILE'] == null
                                      ? const Icon(Icons.person, color: Colors.white)
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 랭킹 1위 원형 아바타
                        Positioned(
                          top: MediaQuery.of(context).size.height * 0.007, // 단상 이미지 위에서의 위치
                          left: MediaQuery.of(context).size.width * 0.44, // 왼쪽에서의 위치
                          child: Column(
                            children: [
                              Text(
                                items[0]['USER_NICKNAME'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(40),
                                  border: Border.all(color: Colors.yellow.shade600, width: 2),
                                ),
                                child: CircleAvatar(
                                  radius: 35.0, // 아바타 크기
                                  backgroundColor: Colors.grey,
                                  backgroundImage: items[0]['USER_PROFILE'] != null &&
                                      items[0]['USER_PROFILE'].isNotEmpty ? NetworkImage(items[0]['USER_PROFILE'])
                                      : null,
                                  child: items[0]['USER_PROFILE'] == null
                                      ? const Icon(Icons.person, color: Colors.white)
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 랭킹 3위 원형 아바타
                        Positioned(
                          top: MediaQuery.of(context).size.height * 0.1, // 단상 이미지 위에서의 위치
                          left: MediaQuery.of(context).size.width * 0.64, // 왼쪽에서의 위치
                          child: Column(
                            children: [
                              Text(
                                items[2]['USER_NICKNAME'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: Colors.orange.shade700, width: 2),
                                ),
                                child: CircleAvatar(
                                  radius: 25.0, // 아바타 크기
                                  backgroundColor: Colors.grey,
                                  backgroundImage: items[2]['USER_PROFILE'] != null &&
                                      items[2]['USER_PROFILE'].isNotEmpty ? NetworkImage(items[2]['USER_PROFILE'])
                                      : null,
                                  child: items[2]['USER_PROFILE'] == null
                                      ? const Icon(Icons.person, color: Colors.white)
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                ),

                // 랭킹 전체 리스트
                Expanded(
                  flex: 3,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: currentMaxItems,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final int plays = item['WIN_COUNT'] + item['LOSE_COUNT'];
                      final int rate = plays > 0
                          ? ((item['WIN_COUNT'] / plays) * 100).round()
                          : 0; // 플레이 횟수가 0인 경우 승률을 0으로 설정
                      return GestureDetector(
                        onTap: () {
                          // 유저별 팝업 띄우기
                          UserProfilePopup.show(
                            context,
                            proFile: item['USER_PROFILE'], // 프로필 링크
                            nickName: item['USER_NICKNAME'], // 닉네임
                            rank: items.indexOf(item) + 1, // 순위
                            point: item['USER_SCORE'], // 보유 score 점수
                            plays: plays, // 플레이 횟수
                            rate: rate, // 승률
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 16.0
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 28.0
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24.0),
                            border:  Border.all(
                              color: items.indexOf(item) == 0
                                  ? Colors.yellow.shade600 // 금색 (1위)
                                  : items.indexOf(item) == 1
                                  ? Colors.grey.shade400 // 은색 (2위)
                                  : items.indexOf(item) == 2
                                  ? Colors.orange.shade700 // 동색 (3위)
                                  : Colors.grey.shade600, // 나머지 항목은 회색
                              width: 3.0, // 테두리의 두께
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: MediaQuery.of(context).size.height * 0.03,
                                    backgroundColor: Colors.grey,
                                    backgroundImage: item['USER_PROFILE'] != null &&
                                        item['USER_PROFILE'].isNotEmpty ? NetworkImage(item['USER_PROFILE'])
                                        : null,
                                    child: item['USER_PROFILE'] == null
                                        ? const Icon(Icons.person, color: Colors.white)
                                        : null,
                                  ),
                                  SizedBox(width: 20.0),

                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      EasyRichText(
                                        'Na: ${item['USER_NICKNAME']}',
                                        defaultStyle: TextStyle(
                                          fontSize: MediaQuery.of(context).size.height * 0.025,
                                        ),
                                        patternList: const [
                                          EasyRichTextPattern(
                                              targetString: 'Na:',
                                              style: TextStyle(
                                                  color: Colors.blueAccent
                                              )
                                          ),
                                        ],
                                      ),
                                      EasyRichText(
                                        'Pt: ${item['USER_SCORE']}',
                                        defaultStyle: TextStyle(
                                          fontSize: MediaQuery.of(context).size.height * 0.025,
                                        ),
                                        patternList: const [
                                          EasyRichTextPattern(
                                            targetString: 'Pt:',
                                            style: TextStyle(
                                              color: Colors.blueAccent,
                                            ),
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
                                    if (items.indexOf(item) == 0) // 1위 금메달
                                      WidgetSpan(
                                        child: Image.asset(
                                          'assets/medal_gold.png', // 금메달 이미지 경로
                                          width: MediaQuery.of(context).size.width * 0.08,
                                          height: MediaQuery.of(context).size.height * 0.08,
                                        ),
                                      )
                                    else if (items.indexOf(item) == 1) // 2위 은메달
                                      WidgetSpan(
                                        child: Image.asset(
                                          'assets/medal_sliver.png', // 은메달 이미지 경로
                                          width: MediaQuery.of(context).size.width * 0.08,
                                          height: MediaQuery.of(context).size.height * 0.08,
                                        ),
                                      )
                                    else if (items.indexOf(item) == 2) // 3위 동메달
                                        WidgetSpan(
                                          child: Image.asset(
                                            'assets/medal_bronze.png', // 동메달 이미지 경로
                                            width: MediaQuery.of(context).size.width * 0.08,
                                            height: MediaQuery.of(context).size.height * 0.08,
                                          ),
                                        )
                                      else
                                        TextSpan(
                                          text: '${items.indexOf(item) + 1}  ', // 랭킹 번호 텍스트
                                          style: TextStyle(
                                            fontSize: MediaQuery.of(context).size.height * 0.03,
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
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
