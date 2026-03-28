import 'package:dio/dio.dart';
import 'package:leave_application/network/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(), // 로그를 보기 좋게 박스 형태로 출력해줌
);

class UserApi {
  final Dio _dio = ApiService().dio;

  // 프로필 변경 전 비밀번호 확인하는 API
  Future<Response> validPassword({required String password}) async {
    try {
      final response = await _dio.post(
        '/api/user/valid',
        data: {"password": password},
      );
      return response;
    } on DioException catch (e) {
      logger.d("POST /api/user/valid exception : $e");
      rethrow;
    }
  }

  // 프로필 정보를 가져오는 API
  Future<Response> getUserProfile() async {
    try {
      final response = await _dio.get('/api/user/profile');
      return response;
    } on DioException catch (e) {
      logger.d("GET /api/user/profile exception : $e");
      rethrow;
    }
  }

  // 비밀번호 변경 API
  Future<Response> changePassword({
    required String password,
    required String passwordConfirm,
  }) async {
    try {
      final response = await _dio.post(
        '/api/user/profile/password',
        data: {"password": password, "passwordConfirm": passwordConfirm},
      );
      return response;
    } on DioException catch (e) {
      logger.d("POST /api/user/profile/password exception : $e");
      rethrow;
    }
  }

  // 연차 갯수 변경 API
  Future<Response> changeCount({required int count}) async {
    try {
      final response = await _dio.post(
        '/api/user/profile/count',
        data: {"count": count},
      );
      return response;
    } on DioException catch (e) {
      logger.d("POST /api/user/profile/count exception : $e");
      rethrow;
    }
  }

  // 연차 공휴일 여부 포함 변경 API
  Future<Response> changeIsIncludeHoliday({
    required String isIncludeHoliday,
  }) async {
    try {
      final response = await _dio.post(
        '/api/user/profile/holiday',
        data: {"isIncludeHoliday": isIncludeHoliday},
      );
      return response;
    } on DioException catch (e) {
      logger.d("POST /api/user/profile/holiday exception : $e");
      rethrow;
    }
  }

  // 회원탈퇴 API
  Future<Response> deleteUserInform() async {
    final storage = const FlutterSecureStorage();
    try {
      final response = await _dio.post('/api/user/profile/delete');
      await storage.delete(key: 'ACCESS_TOKEN');
      return response;
    } on DioException catch (e) {
      logger.d("POST /api/user/profile/delete exception : $e");
      await storage.delete(key: 'ACCESS_TOKEN');
      rethrow;
    }
  }
}
