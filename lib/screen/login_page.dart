import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:llm_invest_frontend/screen/home_page.dart';
import 'package:llm_invest_frontend/screen/join_page.dart';
import '../model/auth_service.dart';



class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  // 텍스트필드 프라이빗 함수 설정
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  bool _hasIdText = false; // 아이디 존재 여부
  bool _obscurePwText = true; // 비밀번호 숨기기 상태
  bool _hasPwText = false; // 비밀번호 존재 여부

  // 텍스트필드 입력 상태 변화 감지
  @override
  void initState() {
    super.initState();
    _idController.addListener((){
      setState(() {
        _hasIdText = _idController.text.isNotEmpty;
      });
    });
    _pwController.addListener((){
      setState(() {
        _hasPwText = _pwController.text.isNotEmpty;
      });
    });
  }

  // 일반 로그인 객체
  Future<void> _login() async {
    final AuthService _authService = AuthService(); // AuthService 인스턴스 생성
    bool loginScuccess = await _authService.login(
      _idController.text, _pwController.text, context,
    );
    if (loginScuccess) {
      Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      Fluttertoast.showToast(
        msg: "아이디 혹은 비밀번호가 틀립니다.",
        backgroundColor: Colors.white,
        textColor: Colors.black,
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 2,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  // 구글 로그인 객체
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  get list => null;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          // 오류가 발생한다면 Expaned 부모위젯 추가
          child: ListView(
            padding: EdgeInsets.only(right: 12, left: 12),
            children: [
              Container(
                height: MediaQuery.of(context).size.height,
                alignment: Alignment.center,
                color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  // 앱 이름 로고
                  Text('개미의 꿈',
                    style: TextStyle(
                      color: Colors.blueAccent[700],
                      fontSize: MediaQuery.of(context).size.width * 0.12,
                      fontWeight: FontWeight.bold,),
                  ),
                  SizedBox(height: 30,),

                  // 아이디 입력
                  SizedBox(
                    child: TextField(
                      controller: _idController,
                      decoration: InputDecoration(
                        labelText: "아이디",
                        labelStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15),),
                        fillColor: Colors.white,
                        suffixIcon: _hasIdText ? IconButton(
                          onPressed: () {
                            _idController.clear(); // 입력문 삭제
                            }, icon: Icon(Icons.clear),
                        ) : null, // 입력없을 때는 아이콘 숨김
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),

                  // 비밀번호 입력
                  SizedBox(
                    child: TextField(
                      controller: _pwController,
                      obscureText: _obscurePwText, // 비밀번호 숨기기
                      decoration: InputDecoration(
                        labelText: "비밀번호",
                        labelStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15),),
                        fillColor: Colors.white,
                        suffixIcon: _hasPwText ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 비밀번호 보기/숨기기
                            IconButton(onPressed: (){
                              setState(() {
                                _obscurePwText = !_obscurePwText;
                              });
                            }, icon: Icon(
                              _obscurePwText ? Icons.visibility_off : Icons.visibility,
                            ),),
                            IconButton(
                                onPressed: (){
                                  _pwController.clear(); // 입력문 삭제
                                }, icon: Icon(Icons.clear))
                          ],
                        ) : null, // 입력 없을 때에는 아이콘 숨김
                      ),
                    ),
                  ),
                  SizedBox(height: 30,),

                  // 로그인 버튼
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: TextButton(onPressed: (){
                      // 개발용 임시 코드
                      // Navigator.pushReplacement(context,
                      //   MaterialPageRoute(builder: (context) => HomePage())
                      // );
                      // 버튼 클릭 시 로그인, 홈페이지로 이동
                      _login();
                    },  style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blueAccent[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ), child: const Text("로그인",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                    ),
                  ),
                  const SizedBox(height: 35,),

                  // 구분선
                  const Text("소셜 아이디로 간편 로그인",
                    style: TextStyle(color: Colors.grey),),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: const Divider(color: Colors.grey, thickness: 1, height: 20,),
                  ),
                  SizedBox(height: 3,),


                  // 구글 로그인 기능
                  IconButton(onPressed: () async {

                    try {
                      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
                      if (googleUser != null){
                        //로그인 성공
                        print('로그인 성공 : ${googleUser.email}');
                        print('이름 : ${googleUser.displayName}');
                        print('프로필 사진 : ${googleUser.photoUrl}');
                        Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => const HomePage(),),
                        );
                      }
                      else{
                        // 로그인 실패
                        print('로그인 취소 : 계정이 선택 되지 않았습니다.');
                      }
                    }
                    catch (error) {
                      //오류 발생
                      print('로그인 중 오류 발생 :$error');
                    }

                    // try {
                    //   final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
                    //   final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
                    //
                    //   if (googleAuth != null){
                    //     // 로그인 성공 시 처리할 내용
                    //     print('Acess Token: ${googleAuth.accessToken}');
                    //     print('ID Token : ${googleAuth.idToken}');
                    //   }
                    //   // 추가적으로 사용자 정보를 가져오는 작업을 할 수 있음
                    //   // 예시 - 이름, 이메일, 프로필 사진
                    //   if (googleUser != null){
                    //     print('이름 : ${googleUser.displayName}');
                    //     print('이메일 : ${googleUser.email}');
                    //     print('프로필 사진 : ${googleUser.photoUrl}');
                    //   }
                    // } catch (e) {
                    //   print('에러 발생 : $e');
                    // }

                  }, icon: Image.asset('assets/google_siginin.png'),),
                  SizedBox(height: 20,),

                  // 아이디/비밀번호 찾기, 회원가입 텍스트
                  DefaultTextStyle(
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("아이디 찾기"),
                        _buildSeparator(), // 구분선 함수
                        Text("비밀번호 찾기", ),
                        _buildSeparator(),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) => const JoinPage(),),
                            );
                          },
                            child: Text("회원가입"),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 구분선 | 프라이빗 함수
Widget _buildSeparator() {
  return const Padding(
    padding: EdgeInsets.symmetric(horizontal: 10.0), // 간격 추가
    child: Text('|', style: TextStyle(color: Colors.grey)),
  );
}

