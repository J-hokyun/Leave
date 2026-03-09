import 'package:dio/dio.dart';
import 'package:leave_application/network/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
      await storage.delete(key: 'ACCESS_TOKEN');
      rethrow;
    }
  }

  Future<Response> join({
    required String email, // yyyyMMdd
    required String password, // yyyyMMdd
    required String passwordConfirm, // yyyyMMdd
    required int leaveAccount, // yyyyMMdd
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/join',
        data: {
          "email": email,
          "password": password,
          'passwordConfirm': passwordConfirm,
          'leaveAccount': leaveAccount,
        },
      );
      return response;
    } on DioException catch (e) {
      rethrow;
    }
  }
}
