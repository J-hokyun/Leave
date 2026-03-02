import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:leave_application/data/api/auth_api.dart';
import 'package:dio/dio.dart';
import 'package:leave_application/presentation/common/alert_utils.dart';

var logger = Logger(
  printer: PrettyPrinter(), // 로그를 보기 좋게 박스 형태로 출력해줌
);

class JoinPage extends StatefulWidget {
  const JoinPage({super.key});

  @override
  State<JoinPage> createState() => _JoinPageState();
}

class _JoinPageState extends State<JoinPage> {
  final AuthApi _authApi = AuthApi();

  final Color primaryColor = const Color(0xFF007AFF);
  final Color inputFillColor = const Color(0xFFEDF2FF);
  final Color errorColor = Colors.red;

  // 1. 입력 컨트롤러
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final TextEditingController _leaveController = TextEditingController();

  bool _isPasswordObscure = true;
  bool _isConfirmObscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _leaveController.dispose();
    super.dispose();
  }

  // 이메일 입력값 유효 인증 로직
  Map<String, dynamic> _getEmailStatus() {
    String email = _emailController.text;
    if (email.isEmpty) {
      return {"text": "", "color": Colors.transparent, "isValid": false};
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return {"text": "유효한 이메일이 아닙니다.", "color": errorColor, "isValid": false};
    }

    return {"text": "유효한 이메일 입니다.", "color": primaryColor, "isValid": true};
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
    return {"text": "사용 가능한 비밀번호입니다.", "color": primaryColor, "isValid": true};
  }

  // 비밀번호 & 비밀번화 확인 일치 체크
  Map<String, dynamic> _getConfirmStatus() {
    String p1 = _passwordController.text;
    String p2 = _confirmController.text;
    if (p2.isEmpty) return {"text": "", "color": Colors.transparent};
    if (p1 != p2) return {"text": "비밀번호가 일치하지 않습니다.", "color": errorColor};
    return {"text": "비밀번호가 일치합니다.", "color": primaryColor};
  }

  // 연채 갯수 체크
  Map<String, dynamic> _getLeaveStatus() {
    String val = _leaveController.text;

    // 1. 비어있는 경우
    if (val.isEmpty) {
      return {"text": "", "color": Colors.transparent, "isValid": false};
    }

    int? leaveCount = int.tryParse(val);

    // 2. 숫자가 12~99 범위를 벗어난 경우
    if (leaveCount == null || leaveCount < 12 || leaveCount > 99) {
      return {
        "text": "12~99 사이 숫자를 입력해주세요.",
        "color": errorColor,
        "isValid": false,
      };
    }

    // 3. 정상 입력
    return {"text": "적절한 연차 갯수입니다.", "color": primaryColor, "isValid": true};
  }

  Future<void> _registerUser() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final response = await _authApi.join(
        email: _emailController.text,
        password: _passwordController.text,
        passwordConfirm: _confirmController.text,
        leaveAccount: int.tryParse(_leaveController.text) ?? 0,
      );

      if (response.statusCode == 200) {
        logger.d("회원가입 성공 ");

        if (!mounted) return;

        await AlertUtils.showAlert(context, "회원가입에 성공하였습니다.");
        if (mounted) {
          context.go("/login");
        }
      }
    } catch (e) {
      String errorMessage = "오류가 발생했습니다. 다시 시도하여 주세요.";

      if (e is DioException && e.response != null) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      } else {
        errorMessage = e.toString();
      }

      logger.d("회원가입 실패 : $errorMessage");
      if (!mounted) return;
      AlertUtils.showError(context, errorMessage);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    var emailStatus = _getEmailStatus();
    var pwdStatus = _getPasswordStatus();
    var confirmStatus = _getConfirmStatus();
    var countStatus = _getLeaveStatus();
    // 모든 필드가 채워지고 비밀번호 조건이 맞을 때만 가입 버튼 활성화
    bool isFormValid =
        emailStatus['isValid'] == true &&
        pwdStatus['isValid'] == true &&
        confirmStatus['color'] == primaryColor &&
        countStatus['isValid'] == true;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: primaryColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '회원가입',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // 이메일 섹션 (심플하게 변경)
            _buildInputLabel('이메일'),
            _buildTextField(
              controller: _emailController,
              hintText: 'example@example.com',
              keyboardType: TextInputType.emailAddress,
              onChanged: (_) => setState(() {}),
            ),
            _buildStatusMessage(emailStatus['text'], emailStatus['color']),
            const SizedBox(height: 25),

            // 비밀번호 섹션
            _buildInputLabel('비밀번호'),
            _buildTextField(
              controller: _passwordController,
              isObscure: _isPasswordObscure,
              onChanged: (_) => setState(() {}),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordObscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () =>
                    setState(() => _isPasswordObscure = !_isPasswordObscure),
                color: Colors.black45,
              ),
            ),
            _buildStatusMessage(pwdStatus['text'], pwdStatus['color']),
            const SizedBox(height: 15),

            // 비밀번호 확인 섹션
            _buildInputLabel('비밀번호 확인'),
            _buildTextField(
              controller: _confirmController,
              isObscure: _isConfirmObscure,
              onChanged: (_) => setState(() {}),
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmObscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () =>
                    setState(() => _isConfirmObscure = !_isConfirmObscure),
                color: Colors.black45,
              ),
            ),
            _buildStatusMessage(confirmStatus['text'], confirmStatus['color']),
            const SizedBox(height: 25),

            // 연차갯수 섹션
            _buildInputLabel('연차갯수'),
            _buildTextField(
              controller: _leaveController,
              hintText: '숫자만 입력',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2),
              ],
              onChanged: (_) => setState(() {}),
            ),
            _buildStatusMessage(countStatus['text'], countStatus['color']),
            const SizedBox(height: 50),

            // 회원가입 버튼
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isFormValid ? _registerUser : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  '회원가입',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
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

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTextField({
    String? hintText,
    bool isObscure = false,
    Widget? suffixIcon,
    TextEditingController? controller,
    Function(String)? onChanged,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      obscureText: isObscure,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: primaryColor.withValues(alpha: 0.3)),
        filled: true,
        fillColor: inputFillColor,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
