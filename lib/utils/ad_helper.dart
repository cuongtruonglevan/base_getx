import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdHelper {
  static void setAdsId(AdIdModel model) {
    _model = model;
  }

  static AdIdModel? _model;
  static final AdHelper _singleton = AdHelper._internal();

  factory AdHelper() {
    assert(_model != null);
    return _singleton;
  }

  AdHelper._internal();

  String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return _model!.bannerAndroid ?? "";
    } else if (Platform.isIOS) {
      return _model!.bannerIos ?? "";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  String get nativeAdUnitId {
    if (Platform.isAndroid) {
      return _model!.nativeAndroid ?? '';
    } else if (Platform.isIOS) {
      return _model!.nativeIos ?? '';
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  String get interAdUnitId {
    if (Platform.isAndroid) {
      return _model!.interAndroid ?? '';
    } else if (Platform.isIOS) {
      return _model!.interIos ?? '';
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  String get rewardAdUnitId {
    if (Platform.isAndroid) {
      return _model!.rewardAndroid ?? '';
    } else if (Platform.isIOS) {
      return _model!.rewardIos ?? '';
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  static Future initialize() async {
    await MobileAds.instance.initialize();
  }
}

class AdIdModel {
  String? bannerAndroid = "";
  String? bannerIos = "";
  String? interAndroid = "";
  String? interIos = "";
  String? rewardAndroid = "";
  String? rewardIos = "";
  String? nativeIos = "";
  String? nativeAndroid = "";

  AdIdModel({
    this.bannerAndroid,
    this.bannerIos,
    this.interAndroid,
    this.interIos,
    this.rewardAndroid,
    this.rewardIos,
    this.nativeIos,
    this.nativeAndroid,
  });
}
