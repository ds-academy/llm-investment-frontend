import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../model/game_chat_service.dart';

class GameChatBot extends StatefulWidget {
  const GameChatBot({super.key});

  @override
  State<GameChatBot> createState() => _GameChatBotState();
}

class _GameChatBotState extends State<GameChatBot> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final storage = const FlutterSecureStorage();
  List<Map<String, dynamic>> messages = [];
  String userId = "";
  String selectedTip = '';
  List<String> detailNames = []; // TIPS_DETAIL_NAME 목록

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _loadConversationHistory();
    _scrollToBottomAfterLayout(); // 추가: 초기 메시지 로드 후 스크롤
  }

  // 초기 메시지 로드 후 스크롤 위치를 맨 아래로 설정
  void _scrollToBottomAfterLayout() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  // 사용자 ID를 로드하고 환영 메시지 추가
  Future<void> _loadUserId() async {
    String? token = await storage.read(key: 'token');
    if (token != null) {
      setState(() {
        userId = token;
        messages.add({
          'sender': 'bot',
          'text': "$userId님, 반갑습니다!\n무엇이 궁금하시나요?",
          'isRichText': true,
        });
        _addTipButtons();
      });
      _scrollToBottom(); // 추가: 메시지 추가 후 스크롤
    }
  }

  Future<void> _loadConversationHistory() async {
    try {
      String? token = await storage.read(key: 'token');
      if (token != null) {
        final history = await GameChatService().fetchConversationHistory(token);

        setState(() {
          // 과거 대화 내역 추가
          messages = history.map((item) {
            return {
              "sender": item["SENDER"] == "user" ? "user" : "bot",
              "text": item["MESSAGE"],
            };
          }).toList();

          // 환영 메시지와 TIP 버튼 추가
          messages.insert(0, {
            'sender': 'bot',
            'text': "$userId님, 반갑습니다!\n무엇이 궁금하시나요?",
            'isRichText': true,
          });
          messages.add({
            'sender': 'bot',
            'isTip': true,
            'text': '',
          });
        });
      }
    } catch (e) {
      setState(() {
        messages.add({"sender": "bot", "text": "오류 발생: $e"});
      });
    } finally {
      _scrollToBottom();
    }
  }

  // 팁 버튼을 메시지로 추가
  void _addTipButtons() {
    setState(() {
      messages.add({
        'sender': 'bot',
        'isTip': true,
        'text': '',
      });
    });
  }

  // TIP 버튼 클릭 시 호출
  void _onTipSelected(String tip) async {
    String? token = await storage.read(key: 'token');
    setState(() {
      // 이전에 선택된 Tip을 초기화
      selectedTip = tip;
      detailNames = []; // 세부 항목 초기화
      messages.add({
        "sender": "bot",
        "text": "$tip 관련 정보를 가져오는 중입니다...",
      });
      _scrollToBottom();
    });

    try {
      final response = await GameChatService().fetchTipDetails(token!, tip); // TIPS_DETAIL_NAME 가져오기
      setState(() {
        detailNames = response;
        messages.add({
          'sender': 'bot',
          'isDetail': true, // 세부 팁 버튼 메시지로 표시
          'text': '아래 세부 항목을 선택하세요:',
          'details': detailNames,
        });
        _scrollToBottom();
      });
    } catch (e) {
      setState(() {
        messages.add({"sender": "bot", "text": "오류 발생: $e"});
      });
    } finally {
      _scrollToBottom(); // 스크롤 위치를 맨 아래로 설정
    }
  }

  // TIPS_DETAIL_NAME 버튼 클릭 시 호출
  void _onDetailSelected(String detailName) async {
    String? token = await storage.read(key: 'token');
    setState(() {
      // 선택된 세부 항목 초기화
      messages.add({"sender": "user", "text": detailName});
      detailNames = []; // 세부 항목 초기화
      _scrollToBottom(); // 메시지 추가 후 스크롤
    });

    try {
      final response = await GameChatService().fetchAnswer(token! ,selectedTip, detailName); // ANSWER 요청
      setState(() {
        messages.add({"sender": "bot", "text": response});
        selectedTip = ''; // Tip 초기화
        _addTipButtons(); // Tip 버튼을 다시 추가
        _scrollToBottom();
      });
    } catch (e) {
      setState(() {
        messages.add({"sender": "bot", "text": "오류 발생: $e"});
        _scrollToBottom();
      });
    } finally {
      _scrollToBottom(); // 스크롤 위치를 맨 아래로 설정
    }
  }


  void _sendMessage(String text) async {
    if (text.isEmpty) return;

    setState(() {
      messages.add({"sender": "user", "text": text});
      _scrollToBottom();
    });

    try {
      final response = await GameChatService().sendMessage(userId, text);
      setState(() {
        messages.add({"sender": "bot", "text": response['response']});
        _scrollToBottom();
      });
    } catch (e) {
      setState(() {
        messages.add({"sender": "bot", "text": "오류 발생: $e"});
        _scrollToBottom();
      });
    }

    _messageController.clear();
  }

  // 대화창을 부드럽게 맨 아래로 스크롤
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500), // 애니메이션 지속 시간
          curve: Curves.easeInOut,
        );
      }
    });
  }

  // 버튼 스타일 정의
  Widget _buildButton(String text, bool isSelected, Function onTap) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        padding: const EdgeInsets.symmetric(vertical: 6),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: isSelected
              ? const LinearGradient(
            colors: [Color(0xFF00B4FF), Color(0xFF5079FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,
          color: isSelected ? null : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.blue,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.blueAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // TIP 버튼 목록 생성
  Widget _buildTipButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildButton('차트분석 Tip', selectedTip == '차트분석 Tip', () => _onTipSelected('차트분석 Tip')),
        _buildButton('뉴스분석 Tip', selectedTip == '뉴스분석 Tip', () => _onTipSelected('뉴스분석 Tip')),
        _buildButton('리포트분석 Tip', selectedTip == '리포트분석 Tip', () => _onTipSelected('리포트분석 Tip')),
        _buildButton('재무제표분석 Tip', selectedTip == '재무제표분석 Tip', () => _onTipSelected('재무제표분석 Tip')),
      ],
    );
  }

  // TIPS_DETAIL_NAME 버튼 목록 생성
  Widget _buildDetailButtons(List<String> details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: details.map((detailName) {
        return _buildButton(detailName, false, () => _onDetailSelected(detailName));
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(12, 40, 12, 12),
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: messages.map((message) {
                          bool isUser = message['sender'] == 'user';
                          bool isBot = message['sender'] == 'bot';
                          bool isRichText = message['isRichText'] == true;
                          bool isTip = message['isTip'] == true;
                          bool isDetail = message['isDetail'] == true;
                      
                          if (isRichText) {
                            return Padding(
                              padding: const EdgeInsets.all(10),
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '$userId님, ',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const TextSpan(
                                      text: '반갑습니다!\n무엇이 궁금하시나요?',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                      
                          if (isTip) {
                            return Padding(
                              padding: const EdgeInsets.all(10),
                              child: _buildTipButtons(),
                            );
                          }
                      
                          if (isDetail) {
                            return Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message['text'],
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                  _buildDetailButtons(message['details']),
                                ],
                              ),
                            );
                          }
                      
                          if (isUser) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width * 0.5,
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    message['text'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                      
                          if (isBot) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width * 0.5,
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.blueAccent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    message['text'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        focusNode: _focusNode,
                        decoration: const InputDecoration(
                          hintText: "메시지를 입력하세요...",
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () {
                        if (_messageController.text.isNotEmpty) {
                          _sendMessage(_messageController.text);
                          _messageController.clear();
                        }
                      },
                      color: Colors.blue,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "ANT LAB 연구원 : 엔미",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
