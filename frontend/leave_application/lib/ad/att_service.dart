import 'package:app_tracking_transparency/app_tracking_transparency.dart';

class ATTService {
  static Future<void> requestATT() async {
    // 1. 현재 추적 권한 상태 확인
    final TrackingStatus status =
        await AppTrackingTransparency.trackingAuthorizationStatus;

    // 2. 만약 권한이 '결정되지 않음(notDetermined)' 상태라면 팝업 요청
    if (status == TrackingStatus.notDetermined) {
      // (선택사항) 애플 가이드라인에 따라 사용자에게 왜 이 권한이 필요한지 설명하는
      // 커스텀 다이얼로그를 먼저 띄워주는 것이 승인 확률을 높여줍니다.
      await AppTrackingTransparency.requestTrackingAuthorization();
    }
  }
}
