import 'package:dio/dio.dart';
import 'package:leave_application/network/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(), // 로그를 보기 좋게 박스 형태로 출력해줌
);

class AuthApi {
  final Dio _dio = ApiService().dio;

  Future<Response> login({
    required String email, // yyyyMMdd
    required String password, // yyyyMMdd
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {"email": email, "password": password},
      );
      return response;
    } on DioException catch (e) {
      logger.d("POST /api/auth/login exception : $e");
      rethrow;
    }
  }

  Future<Response> logout() async {
    final storage = const FlutterSecureStorage();
    try {
      final response = await _dio.post('/api/auth/logout');
      if (response.statusCode == 200) {
        await storage.delete(key: 'ACCESS_TOKEN');
      }
      return response;
    } on DioException catch (e) {
      logger.d("POST /api/auth/logout exception : $e");
      await storage.delete(key: 'ACCESS_TOKEN');
      rethrow;
    }
  }

  Future<Response> join({
    required String email, // yyyyMMdd
    required String password, // yyyyMMdd
    required String passwordConfirm, // yyyyMMdd
    required int leaveAccount, // yyyyMMdd
    required bool? includeHoliday,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/join',
        data: {
          "email": email,
          "password": password,
          'passwordConfirm': passwordConfirm,
          'leaveAccount': leaveAccount,
          'includeHoliday': includeHoliday,
        },
      );
      return response;
    } on DioException catch (e) {
      logger.d("POST /api/auth/join exception : $e");
      rethrow;
    }
  }
}
