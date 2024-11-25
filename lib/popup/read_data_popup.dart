import 'package:flutter/material.dart';

class ReadDataPopup {
  static Future<void> show(
      BuildContext context, {
        String title = "제목",
        String content = """뉴스, 제목, 리포트 데이터 텍스트""",
        VoidCallback? onConfirm, // 확인
      }) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: IntrinsicHeight(
              // IntrinsicHeight 사용하여 높이를 동적으로 설정
              child: Container(
                padding: const EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.blueAccent, width: 2)
                ),
                child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 제목
                        Row(
                          children: [
                            Expanded(child: Divider(thickness: 2, color: Colors.grey)),
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal:0),
                                child: Text(
                                  title,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                  softWrap: true,
                                  maxLines: 2,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(thickness: 2, color: Colors.grey)),
                          ],
                        ),
                        SizedBox(height: 20,),
              
                        // 컨텐츠
                        Container(
                          child: ConstrainedBox(
                            // 최대/최소 높이 설정
                            constraints: BoxConstraints(
                              minHeight: MediaQuery.of(context).size.height * 0.03,
                              maxHeight: MediaQuery.of(context).size.height * 0.6,
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Text(
                                    content,
                                    style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.width * 0.04,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20,),
              
                        // 버튼
                        Expanded(
                          child: Row(
                            children: [
                              // 확인버튼
                              Expanded(
                                child: ElevatedButton(onPressed: () {
                                  Navigator.of(context).pop();
                                  if (onConfirm != null) {
                                    onConfirm();
                                  }
                                },
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    backgroundColor: Colors.blueAccent,
                                    // padding: const EdgeInsets.symmetric(vertical: 15),
                                  ),
                                  child: const Text(
                                    "확인",
                                    style: TextStyle(
                                        color: Colors.white
                                    ),
                                  ),),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                ),
              ),
            ),
          );
        }
    );
  }
}