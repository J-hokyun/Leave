import 'package:dio/dio.dart';
import 'package:leave_application/network/api_service.dart';
import 'package:intl/intl.dart';

class LeaveApi {
  final Dio _dio = ApiService().dio;

  // 1. 저장 API
  Future<Response> saveLeaveHistory({
    required int type, // 연차: 0, 반차: 1, 반반차: 2
    required String start, // yyyyMMdd
    required String end, // yyyyMMdd
    required String reason,
  }) async {
    try {
      final response = await _dio.post(
        '/api/leave/history',
        data: {
          "leaveTypeCode": type,
          "startDate": start,
          "endDate": end,
          "leaveReason": reason,
        },
      );
      return response;
    } on DioException catch (e) {
      rethrow;
    }
  }

  // 2. 개수 조회 API
  Future<Response> getLeaveCounts() async {
    try {
      final response = await _dio.get('/api/leave/count');
      return response;
    } on DioException catch (e) {
      rethrow;
    }
  }

  // 최근사용내역조회
  Future<Response> getCurrentUsed({
    required String uuid, // yyyyMMdd
    required String userId, // yyyyMMdd
    required String date,
  }) async {
    try {
      final response = await _dio.get(
        '/api/leave/current',
        queryParameters: {"uuid": uuid, "userId": userId, "date": date},
      );
      return response;
    } on DioException catch (e) {
      rethrow;
    }
  }

  /* 다음 연차 내역 조회 API */
  Future<Response> getNextUsed({
    required String uuid,
    required String userId,
    required String date,
  }) async {
    try {
      final response = await _dio.get(
        '/api/leave/next',
        queryParameters: {"uuid": uuid, "userId": userId, "date": date},
      );
      return response;
    } on DioException catch (e) {
      rethrow;
    }
  }

  /* 이전 연차 내역 조회 API */
  Future<Response> getPrevUsed({
    required String uuid, // yyyyMMdd
    required String userId, // yyyyMMdd
    required String date,
  }) async {
    try {
      final response = await _dio.get(
        '/api/leave/prev',
        queryParameters: {"uuid": uuid, "userId": userId, "date": date},
      );
      return response;
    } on DioException catch (e) {
      rethrow;
    }
  }

  /* 해당월에 사용한 연차 일자 조회  API */
  Future<Response> getMonthlyList({required DateTime date}) async {
    String formattedDate = DateFormat('yyyyMMdd').format(date);
    try {
      final response = await _dio.get(
        '/api/leave/monthly',
        queryParameters: {"date": formattedDate},
      );
      return response;
    } on DioException catch (e) {
      rethrow;
    }
  }

  /* 달력에서 터치된 날짜에 있는 연차 조회 API */
  Future<Response> getHistoryByDate({required DateTime date}) async {
    String formattedDate = DateFormat('yyyyMMdd').format(date);
    try {
      final response = await _dio.get(
        '/api/leave/history',
        queryParameters: {"date": formattedDate},
      );
      return response;
    } on DioException catch (e) {
      rethrow;
    }
  }

  // 연차 삭제
  Future<Response> deleteHistory({
    required String uuid,
    required String userId,
    required String code,
  }) async {
    try {
      final response = await _dio.post(
        '/api/leave/delete',
        data: {"uuid": uuid, "userId": "", "code": code},
      );
      return response;
    } on DioException catch (e) {
      rethrow;
    }
  }

  /* 해당월에 존재하는 연휴조회 */
  Future<Response> getHolidayInMonth({required String month}) async {
    try {
      final response = await _dio.get(
        '/api/holiday/month',
        queryParameters: {"month": month},
      );
      return response;
    } on DioException catch (e) {
      rethrow;
    }
  }
}
