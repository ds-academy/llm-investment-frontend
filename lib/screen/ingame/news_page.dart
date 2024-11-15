import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../popup/read_data_popup.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({Key? key}) : super(key: key);

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, String>> relatedNews = [];
  List<Map<String, String>> trendNews = [];
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://default-url.com';
  int? selectedRelatedIndex;
  int? selectedTrendIndex;
  bool isOutNewsRead = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchNews();
    checkOutNewsReadStatus();
  }

  // 아웃뉴스 읽음 상태 확인
  Future<void> checkOutNewsReadStatus() async {
    // 동향 뉴스 중 읽지 않은 항목이 있는지 확인
    bool hasUnreadOutNews = trendNews.any((news) => news['title']?.isNotEmpty ?? false);

    // 저장된 읽음 상태 가져오기
    String? readStatus = await storage.read(key: "outnews_read");
    setState(() {
      isOutNewsRead = readStatus == "true" || !hasUnreadOutNews;
    });
  }

  // 아웃뉴스 읽음 상태 저장
  Future<void> markOutNewsAsRead() async {
    await storage.write(key: "outnews_read", value: "true");
    setState(() {
      isOutNewsRead = true;
    });
  }

  Future<void> fetchNews() async {
    try {
      String? token = await storage.read(key: "token");

      if (token == null || token.isEmpty) {
        print("토큰이 없습니다.");
        return;
      }

      final response = await Dio().post(
        '$baseUrl/game/news',
        data: {'token': token},
      );

      if (response.statusCode == 200 && response.data['success']) {
        List<dynamic> newsList = response.data['news_list'];

        setState(() {
          relatedNews = newsList.map((item) {
            return {
              "type": "innews",
              "title": item['INNEWS_TITLE']?.toString() ?? '',
              "description": item['INNEWS_INFO']?.toString() ?? ''
            };
          }).toList();

          trendNews = List.generate(relatedNews.length, (index) {
            if (index > 0 && index - 1 < newsList.length) {
              return {
                "type": "outnews",
                "title": newsList[index - 1]['OUTNEWS_TITLE']?.toString() ?? '',
                "description": newsList[index - 1]['OUTNEWS_INFO']?.toString() ?? ''
              };
            } else {
              return {"type": "outnews", "title": "", "description": ""};
            }
          });
        });

        // 동향 뉴스 읽음 상태 확인
        await checkOutNewsReadStatus();
      }
    } catch (e) {
      print("Error fetching news: $e");
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300, width: 1.5),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.blueAccent,
            indicatorWeight: 3.0,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.blueAccent,
            unselectedLabelColor: Colors.black38,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            tabs: [
              const Tab(text: '관련 뉴스'),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('동향 뉴스'),
                    if (!isOutNewsRead)
                      const SizedBox(width: 8), // 텍스트와 아이콘 사이 간격 추가
                    if (!isOutNewsRead)
                      const Icon(Icons.fiber_new, color: Colors.redAccent, size: 18),
                  ],
                ),
              )
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildNewsList(relatedNews, isRelated: true),
              _buildNewsList(trendNews, isRelated: false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNewsList(List<Map<String, String>> newsList, {required bool isRelated}) {
    // 리스트를 역순으로 출력하기 위해 reversed를 사용
    final reversedNewsList = newsList.reversed.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: reversedNewsList.length,
      itemBuilder: (context, index) {
        final news = reversedNewsList[index];
        final isSelected = isRelated ? selectedRelatedIndex == index : selectedTrendIndex == index;

        // 필터링: title과 description이 모두 비어있다면 해당 항목을 건너뜁니다.
        if ((news['title'] ?? '').isEmpty && (news['description'] ?? '').isEmpty) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () async {
            setState(() {
              if (isRelated) {
                selectedRelatedIndex = index;
                selectedTrendIndex = null;
              } else {
                selectedTrendIndex = index;
                selectedRelatedIndex = null;
              }
            });

            if (!isRelated) {
              await markOutNewsAsRead();
            }

            await ReadDataPopup.show(
              context,
              title: news['title'] ?? '',
              content: news['description'] ?? '',
            );

            setState(() {
              if (isRelated) {
                selectedRelatedIndex = null;
              } else {
                selectedTrendIndex = null;
              }
            });
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6.0),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isRelated ? Colors.blueAccent : Colors.redAccent)
                  : Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              leading: Text(
                // 인덱스를 다르게 출력 (동향 뉴스만 1 밀려서 출력)
                isRelated
                    ? "${newsList.length - index}" // 관련 뉴스는 그대로
                    : "${newsList.length - index - 1}", // 동향 뉴스는 1 밀려서 출력
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
              title: Text(
                news['title'] ?? '',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
              subtitle: Text(
                news['description'] ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected ? Colors.white70 : Colors.black54,
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ),
        );
      },
    );
  }
}
