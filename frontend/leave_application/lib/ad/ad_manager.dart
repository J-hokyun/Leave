import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  // 싱글톤 패턴 구현
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;
  AdManager._internal();

  InterstitialAd? _interstitialAd;
  bool _isAdLoading = false;

  // 광고 단위 ID (kReleaseMode 적용)
  final String _interstitialAdUnitId = kReleaseMode
      ? 'ca-app-pub-8528721677066882/5528109791'
      : 'ca-app-pub-3940256099942544/1033173712';

  // 광고 미리 로드
  void loadInterstitialAd() {
    if (_isAdLoading || _interstitialAd != null) return;

    _isAdLoading = true;
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdLoading = false;

          _interstitialAd!.fullScreenContentCallback =
              FullScreenContentCallback(
                onAdDismissedFullScreenContent: (ad) {
                  ad.dispose();
                  _interstitialAd = null;
                  loadInterstitialAd(); // 광고 닫히면 다음 광고 미리 로드
                },
                onAdFailedToShowFullScreenContent: (ad, error) {
                  ad.dispose();
                  _interstitialAd = null;
                  loadInterstitialAd();
                },
              );
        },
        onAdFailedToLoad: (err) {
          _isAdLoading = false;
          _interstitialAd = null;
          if (!kReleaseMode) print('광고 로드 실패: ${err.message}');
        },
      ),
    );
  }

  // 광고 보여주기 호출 함수
  void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
    } else {
      // 광고가 없다면 미리 로드만 시도
      loadInterstitialAd();
    }
  }
}
