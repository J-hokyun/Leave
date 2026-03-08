import 'package:dio/dio.dart';
import 'auth_interceptor.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  final Dio dio = Dio(); // 실제 통신을 담당하는 도구

  ApiService() {
    // 공통 주소 설정
    dio.options.baseUrl = kReleaseMode
        ? 'https://www.leavehistory.co.kr'
        : 'http://localhost:8080';

    // 시간 초과 설정 (선택)
    dio.options.connectTimeout = const Duration(seconds: 5);

    dio.interceptors.add(AuthInterceptor());

    dio.options.responseType = ResponseType.json;
  }
}
