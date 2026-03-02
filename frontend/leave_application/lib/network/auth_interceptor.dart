import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:leave_application/main.dart';
import 'package:go_router/go_router.dart';
import 'package:leave_application/presentation/common/alert_utils.dart';
import 'package:flutter/material.dart';

var logger = Logger(
  printer: PrettyPrinter(), // 로그를 보기 좋게 박스 형태로 출력해줌
);

class AuthInterceptor extends Interceptor {
  final storage = const FlutterSecureStorage();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 1. 저장소에서 토큰 읽기
    final token = await storage.read(key: 'ACCESS_TOKEN');
    logger.d("보내는 토큰: $token");

    // 2. 토큰이 있다면 헤더에 추가
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // print('[REQ] [${options.method}] ${options.path}');
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 1. 401 혹은 403 에러 발생 시
    if (err.response?.statusCode == 401 || err.response?.statusCode == 403) {
      logger.e("인증 에러 발생: ${err.response?.statusCode}");

      final BuildContext? currentContext = rootNavigatorKey.currentContext;

      if (currentContext != null) {
        // 2. [수정] GoRouterState.of 대신 GoRouter 인스턴스에서 위치 확인
        // 현재 위치가 이미 로그인 페이지라면 무한 루프 방지를 위해 중단
        final String location = GoRouter.of(
          currentContext,
        ).routeInformationProvider.value.uri.toString();
        if (location == '/login') {
          return handler.next(err);
        }

        // 3. 알림창 띄우기
        await AlertUtils.showAlert(
          currentContext,
          "로그인이 만료되었습니다. 다시 로그인하여 주세요.",
        );

        // 4. 토큰 삭제
        await storage.delete(key: 'ACCESS_TOKEN');

        // 5. 로그인 페이지로 이동
        if (currentContext.mounted) {
          currentContext.go("/login");
        }

        // 6. [중요] 에러를 처리했으므로 handler.resolve를 호출하거나 return하여 전파 중단
        return;
      }
    }

    // 그 외의 에러는 다음 핸들러로 전달
    return handler.next(err);
  }
}
