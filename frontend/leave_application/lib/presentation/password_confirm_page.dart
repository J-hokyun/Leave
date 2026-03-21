import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:leave_application/data/api/user_api.dart';
import 'package:leave_application/presentation/common/footer.dart';
import 'package:logger/logger.dart';
import 'package:leave_application/presentation/common/alert_utils.dart';
import 'package:dio/dio.dart';

var logger = Logger(printer: PrettyPrinter());

class PasswordConfirmPage extends StatefulWidget {
  const PasswordConfirmPage({super.key});

  @override
  State<PasswordConfirmPage> createState() => _PasswordConfirmPageState();
}

class _PasswordConfirmPageState extends State<PasswordConfirmPage> {
  // 1. 컨트롤러 선언
  final TextEditingController _passwordController = TextEditingController();
  final UserApi _userApi = UserApi();

  // 상태 관리 변수
  bool _isLoading = false;

  // 가이드라인 상수
  final Color primaryColor = const Color(0xFF007AFF);
  final Color subColor = const Color(0xFFE8EFFF);
  final Color errorColor = Colors.red;
  final TextStyle title1 = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Color(0xFF007AFF),
  );

  @override
  void dispose() {
    // 2. 컨트롤러 해제 (로그인 페이지와 동일하게 메모리 누수 방지)
    _passwordController.dispose();
    super.dispose();
  }

  // 비밀번호 조건 인증체크(영어, 숫자, 특수문자 포함여부, 8자리 이상)
  Map<String, dynamic> _getPasswordStatus() {
    String p = _passwordController.text;
    if (p.isEmpty) {
      return {"text": "", "color": Colors.transparent, "isValid": false};
    }
    // 1. 길이 체크 (8자 이상)
    if (p.length < 8) {
      return {"text": "8자리 이상이어야 합니다.", "color": errorColor, "isValid": false};
    }

    // 영문, 숫자, 특수문자 포함 여부 체크
    bool hasLetters = p.contains(RegExp(r'[a-zA-Z]'));
    bool hasNumbers = p.contains(RegExp(r'[0-9]'));
    bool hasSpecial = p.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    if (!hasLetters || !hasNumbers || !hasSpecial) {
      return {
        "text": "영문, 숫자, 특수문자를 모두 포함해야 합니다.",
        "color": errorColor,
        "isValid": false,
      };
    }

    // 모든 조건 통과
    return {"text": "", "color": primaryColor, "isValid": true};
  }

  // 비밀번호 확인 로직 (로그인 로직 스타일로 리팩토링)
  Future<void> handleVerification() async {
    if (_isLoading) return;

    // 앞뒤 공백 제거 (23자가 나오는 현상 방지)
    final String password = _passwordController.text.trim();

    if (password.isEmpty) {
      AlertUtils.showAlert(context, "비밀번호를 입력하여 주세요.");
    }

    setState(() => _isLoading = true);

    try {
      final response = await _userApi.validPassword(password: password);

      if (!mounted) return;

      if (mounted &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        // 성공 시 텍스트 초기화 후 이동
        _passwordController.clear();
        context.push('/profile/password');
      }
    } catch (e) {
      String errorMessage = "오류가 발생했습니다. 다시 시도하여 주세요.";

      if (e is DioException && e.response != null) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      } else {
        errorMessage = e.toString();
      }

      logger.d("비빌번호 인증 실패 : $errorMessage");
      if (!mounted) return;

      AlertUtils.showError(context, errorMessage);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    var pwdStatus = _getPasswordStatus();

    bool isFormValid = pwdStatus['isValid'] == true;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
      body: Center(
        child: SingleChildScrollView(
          // 키보드 올라올 때 대비
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('비밀번호 확인', style: title1),
              const SizedBox(height: 16),

              // 입력창 (서브컬러 배경)
              Container(
                decoration: BoxDecoration(
                  color: subColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  textAlign: TextAlign.center,
                  onSubmitted: (_) => handleVerification(), // 엔터 키 지원
                  decoration: const InputDecoration(
                    hintText: '비밀번호를 입력하세요',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              _buildStatusMessage(pwdStatus['text'], pwdStatus['color']),
              const SizedBox(height: 40),

              // 확인 버튼
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: (_isLoading || !isFormValid)
                      ? null
                      : handleVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          '확인',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomFooter(currentIndex: '/valid'),
    );
  }

  Widget _buildStatusMessage(String message, Color color) {
    return Container(
      height: 20,
      alignment: Alignment.centerRight,
      child: Text(
        message,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
