import 'package:flutter/material.dart';

class AlertUtils {
  static Future<void> showAlert(BuildContext context, String message) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // 확인 버튼을 눌러야만 닫히도록 설정 (선택 사항)
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: null,
          content: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "확인",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF007AFF),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static Future<void> showError(BuildContext context, String message) {
    return showAlert(context, message);
  }
}
