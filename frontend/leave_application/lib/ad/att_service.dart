import 'package:app_tracking_transparency/app_tracking_transparency.dart';

class ATTService {
  static Future<void> requestATT() async {
    final TrackingStatus status =
        await AppTrackingTransparency.trackingAuthorizationStatus;
    if (status == TrackingStatus.notDetermined) {
      await AppTrackingTransparency.requestTrackingAuthorization();
    }
  }
}
