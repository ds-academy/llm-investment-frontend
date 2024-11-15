import 'package:flutter/material.dart';

class CheckGamePopup {
  static Future<void> show(
      BuildContext context, {
        String content = "정말로 진행 하시겠습니까?",
        VoidCallback? onConfirm, // 확인
        VoidCallback? onCancel, // 취소
      }) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              padding: const EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blueAccent, width: 2)
              ),
              child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 40,),

                      // 컨텐츠
                      Expanded(
                        child: Text(
                          content,
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.04,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 10,),

                      // 버튼
                      Expanded(
                        child: Row(
                          children: [
                            // 취소버튼
                            Expanded(
                              child: ElevatedButton(onPressed: () {
                                Navigator.of(context).pop();
                                if (onCancel != null) {
                                  onCancel();
                                }
                              },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  backgroundColor: Colors.redAccent,
                                  // padding: const EdgeInsets.symmetric(vertical: 15),
                              ),
                                child: const Text(
                                  "취소",
                                  style: TextStyle(
                                    color: Colors.white
                                ),
                              ),),
                            ),
                            SizedBox(width: 10,),
                        
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
          );
        }
    );
  }
}