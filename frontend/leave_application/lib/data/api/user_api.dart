import 'package:dio/dio.dart';
import 'package:leave_application/network/api_service.dart';

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
      rethrow;
    }
  }

  // 프로필 정보를 가져오는 API
  Future<Response> getUserProfile() async {
    try {
      final response = await _dio.get('/api/user/profile');
      return response; // 여기 안에 email, count(연차갯수) 값잇음
    } on DioException catch (e) {
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
      rethrow;
    }
  }
}
