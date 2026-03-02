import 'package:dio/dio.dart';
import 'package:leave_application/network/api_service.dart';

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
