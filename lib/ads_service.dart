import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  static String get bannerAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-8279255883736726/8684998901'
      : 'ca-app-pub-8279255883736726/8684998901';

  static initialize() {
    if (MobileAds.instance == null) {
      MobileAds.instance.initialize();
    }
  }

  static BannerAd createBannerAd() {
    BannerAd ad = new BannerAd(
        size: AdSize.banner,
        adUnitId: bannerAdUnitId,
        listener: AdListener(
          onAdLoaded: (Ad ad) => print('On Ad Loader'),
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            ad.dispose();
            print('Ad failed to load: $error');
          },
          onAdOpened: (Ad ad) => print('Ad Opened'),
          onAdClosed: (Ad ad) => print('Ad Closed'),
        ),
        request: AdRequest());
    return ad;
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-8279255883736726/7371917234";
    } else if (Platform.isIOS) {
      return "ca-app-pub-8279255883736726/7371917234";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }
}
