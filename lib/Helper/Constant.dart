import 'package:flutter/material.dart';
import 'dart:io';

TextDirection direction=TextDirection.ltr;

final String appName = 'WebView_Plus';
final String appbartitle = 'WebView_Plus';
bool navigationAppBar = false;
final String webinitialUrl = 'https://webviewplus.com/test/?cache=7';
//final String webinitialUrl = 'https://netsofters.in';

final String oneSignalAppId = "5efaf2ff-a430-4834-8409-966f7b2c5711";


final int adType = 0; // 0 = No Ads, 1 = Facebook Ads , 2 = Google Ad Mob

///google AD Id's
///app id android
const String AD_MOB_APP_ID = 'ca-app-pub-3940256099942544~3347511713';
///banner ad id android
const String AD_MOB_BANNER_ANDROID='ca-app-pub-3940256099942544/6300978111';//
///Interstitial ad id android
const String AD_MOB_INSTER_ANDROID = 'ca-app-pub-3940256099942544/1033173712';//

///facebook ad id's
///Interstitial ad id android
const String INTERSTITIAL_PLACEMENT_ID = 'IMG_16_9_APP_INSTALL#2312433698835503_2650502525028617';//
///banner ad id android
const String FbBannerPlacementId = "IMG_16_9_APP_INSTALL#2312433698835503_2964944860251047";//


///app id ios
const String AD_MOB_APP_ID_IOS = 'IMG_16_9_APP_INSTALL#2312433698835503_2650502525028617';
///banner ad id ios
const String AD_MOB_BANNER_IOS='ca-app-pub-3940256099942544/2934735716';
///Interstitial id ios
const String AD_MOB_INSTER_IOS = 'ca-app-pub-3940256099942544/4411468910';

String getBannerAdUnitId() {
  if (Platform.isIOS) {
    return 'ca-app-pub-3940256099942544/2934735716';
  } else if (Platform.isAndroid) {
    return 'ca-app-pub-3940256099942544/6300978111';
  }
  return null;
}

String getInterstitialAdUnitId() {
  if (Platform.isIOS) {
    return AD_MOB_INSTER_IOS;
  } else if (Platform.isAndroid) {
    return AD_MOB_INSTER_ANDROID;
  }
  return null;
}

String getAppId() {
  if (Platform.isIOS) {
    return AD_MOB_APP_ID_IOS;
  } else if (Platform.isAndroid) {
    return AD_MOB_APP_ID;
  }
  return null;
}