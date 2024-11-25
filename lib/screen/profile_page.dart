import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  Map<String, dynamic> userInfo = {};
  bool isLoading = true;
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final Dio dio = Dio();
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:5000';

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  // 서버에서 유저 정보 가져오기
  Future<void> fetchUserProfile() async {
    try {
      String? token = await storage.read(key: 'token');

      if (token == null) {
        print("Token is missing");
        return;
      }

      final response = await dio.post(
        '$baseUrl/members/my_profile',
        data: {'token': token},
      );

      if (response.data['success']) {
        setState(() {
          userInfo = response.data['user_info'];
          userInfo['user_id'] = token; // user_id 추가
          isLoading = false;
        });
      } else {
        print('Error: ${response.data['message']}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  // 프로필 사진 변경
  Future<void> updateProfilePicture() async {
    final ImagePicker picker = ImagePicker();
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('프로필 사진 변경'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('갤러리에서 선택'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('카메라로 촬영'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      try {
        final XFile? image = await picker.pickImage(source: source);
        if (image != null) {
          // 프로필 업로드 전 로딩 표시
          setState(() {
            isLoading = true;
          });

          String? token = await storage.read(key: 'token');
          if (token != null) {
            FormData formData = FormData.fromMap({
              'token': token,
              'user_id': userInfo['user_id'],
              'profile_image': await MultipartFile.fromFile(image.path, filename: 'profile.jpg'),
            });

            final response = await dio.post(
              '$baseUrl/members/upload_profile_image',
              data: formData,
            );

            if (response.data['success']) {
              // 프로필 업로드 성공 후 데이터 새로고침
              await fetchUserProfile();
            } else {
              print("Failed to update profile: ${response.data['message']}");
            }
          }
        }
      } catch (e) {
        print("Exception: $e");
      } finally {
        // 로딩 상태 종료
        setState(() {
          isLoading = false;
        });
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        // backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.blueAccent[700],
          title: Text("프로필"),
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
        ),

        body: isLoading
            ? const Center(
          child: CircularProgressIndicator(), // 로딩 인디케이터
        )
        : Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Column(
            children: [
              Flexible(
                flex: 5,
                // 게임 플레이 통계
                child: Column(
                  children: [
                    // 대표 프로필
                    Expanded(
                      flex: 3,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 20.0
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          border: Border.all(
                              color: Colors.grey.shade300, width: 1
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: updateProfilePicture, // 프로필 사진 클릭 시 변경
                              child: CircleAvatar(
                                radius: MediaQuery.of(context).size.height * 0.045,
                                backgroundColor: Colors.grey,
                                backgroundImage: userInfo['profile'] != null && userInfo['profile'].isNotEmpty
                                    ? NetworkImage(userInfo['profile'])
                                    : null,
                                child: userInfo['profile'] == null
                                    ? const Icon(Icons.person, size: 30, color: Colors.white)
                                    : null,
                              ),
                            ),
                            SizedBox(width: 15.0,),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userInfo['nickname'] ?? '닉네임 없음',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  userInfo['email'] ?? '이메일 없음',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            // 순위
                            Text(
                              "${userInfo['rank'] ?? 'N/A'}위",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),

                    // 보유 포인트
                    Expanded(
                      flex: 2,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 20.0
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: Colors.grey.shade300, width: 1
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "MY POINT",
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              "${userInfo['points'] ?? 0}",
                              style: const TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 3),

                    // 승패률
                    Expanded(
                      flex: 2,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // WIN
                            Flexible(
                              child: Container(
                                height: MediaQuery.of(context).size.width * 0.1,
                                width: MediaQuery.of(context).size.width * 0.45,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300, width: 1),
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.blueAccent,
                                ),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      const Text(
                                        "WIN",
                                        style: TextStyle(color: Colors.green, fontSize: 18),
                                      ),
                                      Text(
                                        "${userInfo['win_count'] ?? 0}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // LOSE
                            Flexible(
                              child: Container(
                                height: MediaQuery.of(context).size.width * 0.1,
                                width: MediaQuery.of(context).size.width * 0.45,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.grey.shade300, width: 1
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.redAccent
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      "LOSE",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    Text(
                                      "${userInfo['lose_count'] ?? 0}",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 3),

                    // 플레이 통계
                    Expanded(
                      flex: 3,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 플레이 횟수
                            Flexible(
                              child: Container(
                                height: MediaQuery.of(context).size.width * 0.2,
                                width: MediaQuery.of(context).size.width * 0.5,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                      color: Colors.grey.shade300, width: 1
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${(userInfo['win_count'] + userInfo['lose_count'])}",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "플레이 횟수",
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // 최고 수익
                            Flexible(
                              child: Container(
                                height: MediaQuery.of(context).size.width * 0.2,
                                width: MediaQuery.of(context).size.width * 0.45,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                      color: Colors.grey.shade300, width: 1
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${((userInfo['win_count'] ?? 0) / ((userInfo['win_count'] ?? 0) + (userInfo['lose_count'] ?? 0)) * 100).toStringAsFixed(0)}%",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "게임 승률",
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12,),

              // 유저 개인정보
              Flexible(
                flex: 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 12),
                    child: Column(
                      children: [
                        const Expanded(
                            child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "개인정보",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18
                            ),
                          ),
                        ),),
                        SizedBox(height: 3),

                        // 개인정보 테이블
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  // 닉네임
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.15,
                                    child: const Text(
                                      "닉네임",
                                      style: TextStyle(
                                        color: Colors.blueAccent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "${userInfo['nickname'] ?? 0}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () {
                                      // 닉네임 수정 팝업
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size(0, 0), // 버튼 크기 최소화
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap, // 버튼 터치 크기 축소
                                    ),
                                    child: const Text(
                                      "수정",
                                      style:
                                          TextStyle(color: Colors.blueAccent),
                                    ),
                                  ),
                                ],
                              ),
                              // Divider(color: Colors.grey[200], thickness: 1.0),
                            ],
                          ),
                        ),

                        // 이메일
                        Expanded(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.15,
                                    child: const Text(
                                      "이메일",
                                      style: TextStyle(
                                        color: Colors.blueAccent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "${userInfo['email'] ?? 0}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // 아이디
                        Expanded(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.15,
                                    child: const Text(
                                      "ID",
                                      style: TextStyle(
                                        color: Colors.blueAccent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "${userInfo['user_id'] ?? 0}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // 비밀번호
                        Expanded(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.15,
                                    child: const Text(
                                      "PW",
                                      style: TextStyle(
                                        color: Colors.blueAccent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  // const Text(
                                  //   "비밀번호 값",
                                  //   style: TextStyle(
                                  //     fontWeight: FontWeight.bold,
                                  //   ),
                                  // ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () {
                                      // 비밀번호 수정 팝업
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size(0, 0), // 버튼 크기 최소화
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap, // 버튼 터치 크기 축소
                                    ),
                                    child: const Text(
                                      "수정",
                                      style:
                                      TextStyle(color: Colors.blueAccent),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // 이름
                        Expanded(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.15,
                                    child: const Text(
                                      "이름",
                                      style: TextStyle(
                                        color: Colors.blueAccent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "${userInfo['name'] ?? 0}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),

              // 회원 탈퇴 버튼
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                    onPressed: () {
                      // 회원 탈퇴 확인 팝업 띄우기
                    },
                    child: const Text(
                      "회원 탈퇴하기 ",
                      style: TextStyle(
                          color: Colors.redAccent, fontWeight: FontWeight.bold),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
