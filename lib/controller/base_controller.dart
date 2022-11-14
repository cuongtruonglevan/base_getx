import 'package:base_getx/repository/repositories.dart';
import 'package:base_getx/utils/logger.dart';
import 'package:base_getx/utils/utils.dart';
import 'package:base_getx/widget/base_common_widget.dart';
import 'package:base_getx/widget/widget_state_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
export 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

///
/// --------------------------------------------
/// [Example]
///
/// class HomeController extends BaseController {
///
///   var count = 0.obs;
///
///   @override
///   void onInit() {
///     super.onInit();
///   }
///
///   void increment() => count ++;
///
/// }
///
/// RECOMENDED FOR your [Controller].
/// Please extends to your [Controller].
/// read the [Example] above.
class BaseController extends GetxController
    with BaseCommonWidgets, Utilities, Repositories, WidgetState, ScreenState {
  final box = GetStorage();
  bool isLoadMore = false;
  bool withScrollController = false;
  ScrollController? scrollController;
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  set setEnableScrollController(bool value) => withScrollController = value;

  String interstitialAdId = 'ca-app-pub-3940256099942544/1033173712';
  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  int maxFailedLoadAttempts = 3;

  final AdRequest request = const AdRequest(
    keywords: <String>[],
    nonPersonalizedAds: true,
  );

  /// Inline ads
  String bannerAdId = 'ca-app-pub-3940256099942544/9214589741';
  BannerAd? _anchoredAdaptiveAd;
  Orientation? _currentOrientation;

  @override
  void onInit() {
    super.onInit();
    if (withScrollController) {
      Logger.showLog(
        "SCROLL CONTROLLER ENABLE on ${Get.currentRoute}",
        withScrollController.toString(),
      );
      scrollController = ScrollController();
      scrollController?.addListener(_scrollListener);
    }
    createInterstitialAd();
  }

  @override
  void onReady() {
    super.onReady();
    loadAd();
  }

  void loadAd() async {
    await _anchoredAdaptiveAd?.dispose();
    _anchoredAdaptiveAd = null;
    update();
    _currentOrientation = MediaQuery.of(Get.context!).orientation;
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            MediaQuery.of(Get.context!).size.width.truncate());
    if (size == null) {
      print('Unable to get height of anchored banner.');
      return;
    }

    _anchoredAdaptiveAd = BannerAd(
      adUnitId: bannerAdId,
      size: size,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          // When the ad is loaded, get the ad size and use it to set
          // the height of the ad container.
          _anchoredAdaptiveAd = ad as BannerAd;
          update();
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
        },
      ),
    );
    return _anchoredAdaptiveAd!.load();
  }

  Widget getAdWidget() {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (_currentOrientation != null &&
            _currentOrientation == orientation &&
            _anchoredAdaptiveAd != null) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: SizedBox(
              width: _anchoredAdaptiveAd!.size.width.toDouble(),
              height: _anchoredAdaptiveAd!.size.height.toDouble(),
              child: AdWidget(ad: _anchoredAdaptiveAd!),
            ),
          );
        }
        // Reload the ad if the orientation changes.
        if (_currentOrientation != orientation) {
          _currentOrientation = orientation;
          loadAd();
        }
        return Container();
      },
    );
  }

  Future<void> onRefresh() async {}

  Future<void> onLoadMore() async {}

  void _scrollListener() async {
    if (scrollController != null &&
        scrollController!.offset >=
            scrollController!.position.maxScrollExtent &&
        !scrollController!.position.outOfRange) {
      if (!isLoadMore) {
        isLoadMore = true;
        update();
        await onLoadMore();
      }
      _innerBoxScrolled();
    }
  }

  void createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: interstitialAdId,
        request: request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
              createInterstitialAd();
            }
          },
        ));
  }

  Future<void> showInterstitialAd() async {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        createInterstitialAd();
      },
    );
    await _interstitialAd!.show();
    _interstitialAd = null;
    createInterstitialAd();
  }

  void _innerBoxScrolled() {
    if (scrollController!.offset <= 60 && scrollController!.offset > 40) {
      // if(!innerBoxIsScrolled) {
      //   innerBoxIsScrolled = true;
      //   update();
      // }
    }
    if (scrollController!.offset >= 0 && scrollController!.offset <= 40) {
      // if(innerBoxIsScrolled) {
      //   innerBoxIsScrolled = false;
      //   update();
      // }
    }
  }

  @override
  void onClose() {
    _interstitialAd?.dispose();
    _anchoredAdaptiveAd?.dispose();
    super.onClose();
  }
}
