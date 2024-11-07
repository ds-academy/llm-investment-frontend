import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import '../model/join_members.dart';

// Dio 전역 라이브러리
final dio = Dio();

class JoinPage extends StatefulWidget {
  const JoinPage({super.key});

  @override
  State<JoinPage> createState() => _JoinPageState();
}

class _JoinPageState extends State<JoinPage> {

  // 가입 날짜 변수
  final String _joinDatetime = DateFormat('yyyy-MM-dd').format(DateTime.now());

  // 텍스트필드 프라이빗 함수 설정
  final TextEditingController _joinIdController = TextEditingController();
  final TextEditingController _joinPw1Controller = TextEditingController();
  final TextEditingController _joinPw2Controller = TextEditingController();
  final TextEditingController _joinNameController = TextEditingController();
  final TextEditingController _joinNickController = TextEditingController();
  final TextEditingController _joinPhoneNumController = TextEditingController();
  final TextEditingController _joinEmailController = TextEditingController();

  // 텍스트 존재 여부
  bool _joinIdText = false;
  bool _joinPw1Text = false;
  bool _joinPw2Text = false;
  bool _joinNameText = false;
  bool _joinNickText = false;
  bool _joinPhoneNumText = false;
  bool _joinEmailText = false;

  // 비밀번호 pw1, pw2 숨기기 상태
  bool _obscureJoinPw1Text = true;
  bool _obscureJoinPw2Text = true;

  // 텍스트필드 입력 상태 변화 감지
  @override
  void initState() {
    super.initState();
    _joinIdController.addListener(() {
      setState(() {
        _joinIdText = _joinIdController.text.isNotEmpty;
      });
    });
    _joinPw1Controller.addListener(() {
      setState(() {
        _joinPw1Text = _joinPw1Controller.text.isNotEmpty;
      });
    });
    _joinPw2Controller.addListener(() {
      setState(() {
        _joinPw2Text = _joinPw2Controller.text.isNotEmpty;
      });
    });
    _joinNameController.addListener(() {
      setState(() {
        _joinNameText = _joinNameController.text.isNotEmpty;
      });
    });
    _joinNickController.addListener(() {
      setState(() {
        _joinNickText = _joinNickController.text.isNotEmpty;
      });
    });
    _joinPw1Controller.addListener(() {
      setState(() {
        _joinPw1Text = _joinPw1Controller.text.isNotEmpty;
      });
    });
    _joinPhoneNumController.addListener(() {
      setState(() {
        _joinPhoneNumText = _joinPhoneNumController.text.isNotEmpty;
      });
    });
    _joinEmailController.addListener(() {
      setState(() {
        _joinEmailText = _joinEmailController.text.isNotEmpty;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.blueAccent[700],
          leading: IconButton(
              onPressed: (){
                Navigator.pop(context);
              }, icon: const Icon(Icons.arrow_back_sharp),),
        ),

        body: ListView(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          children: [
            Text("회원님의 정보를 입력해주세요.",
              style: TextStyle(
                color: Colors.blueAccent[700],
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: 12,),

            // 아이디 입력 필드
            TextField(
              controller: _joinIdController,
              decoration: InputDecoration(
                labelText: '아이디 입력',
                labelStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15),),
                suffixIcon: _joinIdText ? IconButton(
                  onPressed: () {
                    _joinIdController.clear(); // 입력문 삭제
                  }, icon: const Icon(Icons.clear),
                ) : null,
              ),
            ),
            SizedBox(height: 12),

            // 비밀번호 입력 필드
            TextField(
              controller: _joinPw1Controller,
              obscureText: _obscureJoinPw1Text,
              decoration: InputDecoration(
                labelText: '비밀번호 입력',
                labelStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15),),
                suffixIcon: _joinPw1Text ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 비밀번호 보기/숨기기
                    IconButton(onPressed: (){
                      setState(() {
                        _obscureJoinPw1Text = !_obscureJoinPw1Text;
                      });
                    }, icon: Icon(
                      _obscureJoinPw1Text ? Icons.visibility_off : Icons.visibility,
                    ),),
                    IconButton(
                        onPressed: (){
                          _joinPw1Controller.clear(); // 입력문 삭제
                        }, icon: const Icon(Icons.clear))
                  ],
                ) : null,
              ),
            ),
            SizedBox(height: 12),

            // 비밀번호 확인 입력 필드
            TextField(
              controller: _joinPw2Controller,
              obscureText: _obscureJoinPw2Text,
              decoration: InputDecoration(
                labelText: '비밀번호 확인',
                labelStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15),),
                suffixIcon: _joinPw2Text ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 비밀번호 확인 보기/숨기기
                    IconButton(onPressed: (){
                      setState(() {
                        _obscureJoinPw2Text = !_obscureJoinPw2Text;
                      });
                    }, icon: Icon(
                      _obscureJoinPw2Text ? Icons.visibility_off : Icons.visibility,
                    ),),
                    IconButton(
                        onPressed: (){
                          _joinPw2Controller.clear(); // 입력문 삭제
                        }, icon: const Icon(Icons.clear))
                  ],
                ) : null,
              ),
            ),
            SizedBox(height: 12),

            // 이름 입력 필드
            TextField(
              controller: _joinNameController,
              decoration: InputDecoration(
                labelText: '이름 입력',
                labelStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15),),
                suffixIcon: _joinNameText ? IconButton(
                  onPressed: () {
                    _joinNameController.clear(); // 입력문 삭제
                  }, icon: const Icon(Icons.clear),
                ) : null,
              ),
            ),
            SizedBox(height: 12),

            // 닉네임 입력 필드
            TextField(
              controller: _joinNickController,
              decoration: InputDecoration(
                labelText: '닉네임 입력',
                labelStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15),),
                suffixIcon: _joinNickText ? IconButton(
                  onPressed: () {
                    _joinNickController.clear(); // 입력문 삭제
                  }, icon: const Icon(Icons.clear),
                ) : null,
              ),
            ),
            SizedBox(height: 12),

            // 전화번호 입력 필드
            TextField(
              controller: _joinPhoneNumController,
              decoration: InputDecoration(
                labelText: '전화번호 입력',
                labelStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15),),
                suffixIcon: _joinPhoneNumText ? IconButton(
                  onPressed: () {
                    _joinPhoneNumController.clear(); // 입력문 삭제
                  }, icon: const Icon(Icons.clear),
                ) : null,
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 12),

            // 이메일 주소 입력 필드
            TextField(
              controller: _joinEmailController,
              decoration: InputDecoration(
                labelText: '이메일 주소 입력',
                labelStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15),),
                suffixIcon: _joinEmailText ? IconButton(
                  onPressed: () {
                    _joinEmailController.clear(); // 입력문 삭제
                  }, icon: const Icon(Icons.clear),
                ) : null,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 15),

            // 회원 등록하기 버튼
            ElevatedButton(
              onPressed: () {
                // 회원 등록 로직 구현
                // 각 텍스트필드의 컨트롤러, 가입날짜 값 할당
                if (_joinPw1Controller.text == _joinPw2Controller.text) {
                  joinMember(
                      _joinIdController.text, _joinPw1Controller.text,
                      _joinNickController.text, _joinNameController.text,
                      _joinPhoneNumController.text, _joinEmailController.text,
                      _joinDatetime, context
                  );
                } else {
                  Fluttertoast.showToast(
                    msg: "비밀번호가 서로 다릅니다.",
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    toastLength: Toast.LENGTH_SHORT,
                    timeInSecForIosWeb: 2,
                    gravity: ToastGravity.BOTTOM,
                  );
                }
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                textStyle: const TextStyle(fontSize: 16,),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),),
              ),
              child: const Text('회원 등록하기'),
            ),
          ],
        ),
      ),
    );
  }
}
