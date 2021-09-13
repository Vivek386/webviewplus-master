import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:tirth_industries/Helper/Constant.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MaterialApp(home: WebViewPlus()));

class WebViewPlus extends StatefulWidget {
  @override
  _WebViewPlusState createState() => _WebViewPlusState();
}
 Timer _timerForInter;
class _WebViewPlusState extends State<WebViewPlus> {



  ///for google interstitial Ad
  bool _isGoogleInterstitialAdLoaded = false;

  ///for facebook interstitial Ad
  bool _isInterstitialAdLoaded = false;

  void _loadInterstitialAd() {
    if (_isInterstitialAdLoaded == false)
    FacebookInterstitialAd.loadInterstitialAd(
      placementId:
      "IMG_16_9_APP_INSTALL#2312433698835503_2650502525028617", //"IMG_16_9_APP_INSTALL#2312433698835503_2650502525028617" YOUR_PLACEMENT_ID
      listener: (result, value) {
        print(">> FAN > Interstitial Ad: $result --> $value");
        if (result == InterstitialAdResult.LOADED)
          _isInterstitialAdLoaded = true;

        /// Once an Interstitial Ad has been dismissed and becomes invalidated,
        /// load a fresh Ad by calling this function.
        if (result == InterstitialAdResult.DISMISSED &&
            value["invalidated"] == true) {
          _isInterstitialAdLoaded = false;
          _loadInterstitialAd();
        }
      },
    );
  }

  Widget _currentAd = SizedBox(
    width: 0.0,
    height: 0.0,
  );

  InAppWebViewController webView;

  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    testDevices: AD_MOB_APP_ID != null ? <String>[AD_MOB_APP_ID] : null,
    nonPersonalizedAds: true,
    keywords: <String>['Pop Singer', 'Adam Livine'],
  );

  ///google banner ad
  BannerAd _bannerAd;
   BannerAd createBannerAd() {
    return BannerAd(
        adUnitId: getBannerAdUnitId(),
        size: AdSize.banner,
        targetingInfo: targetingInfo,
        listener: (MobileAdEvent event) {
          print("BannerAd $event");
        }
    );
  }

  /// Google Interstitial ad
  InterstitialAd _googleinterstitialAd;
  InterstitialAd createInterstitialAd(){
    if(_isGoogleInterstitialAdLoaded == false)
    return InterstitialAd(
        adUnitId: getInterstitialAdUnitId(),
        targetingInfo: targetingInfo,
        listener: (MobileAdEvent event) {
          print("InterstitialAd $event");
          //print(">> FAN > Interstitial Ad: $result --> $value");
          if (event == MobileAdEvent.loaded)
            _isGoogleInterstitialAdLoaded = true;

          /// Once an Interstitial Ad has been dismissed and becomes invalidated,
          /// load a fresh Ad by calling this function.
          if (event == MobileAdEvent.closed) {
            _isGoogleInterstitialAdLoaded = false;
            print("Mobile Ad event is getting closed");
            //createInterstitialAd();
          }

        }
    );
  }

  String webUrl;

  StreamSubscription<String> _onStateChanged;

  InAppWebViewController _webViewController;

  Future<bool> _exitApp(BuildContext context) async {
    if (await _webViewController.canGoBack()) {
      print("onwill goback");
      _webViewController.goBack();

    } else {
      Scaffold.of(context).showSnackBar(
        const SnackBar(content: Text("No back history item")),
      );
      return Future.value(false);
    }
  }

  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    super.initState();
    //if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    initPlatformState();


    if(adType == 1){
      FacebookAudienceNetwork.init(
        testingId: "b9f2908b-1a6b-4a5b-b862-ded7ce289e41",
      );

      ///Facebook Banner Id
      setState(() {
        _currentAd = FacebookBannerAd(
          bannerSize: BannerSize.STANDARD,
          keepAlive: true,
          placementId: FbBannerPlacementId,
          listener: (result,value){
            print("Banner Ad: $result -->  $value");
          },
        );
      });

      ///Facebook Interstitial Id
      _timerForInter = Timer.periodic(Duration(seconds: 30), (result) {
        _loadInterstitialAd();
        _showInterstitialAd();
      });

    }else if(adType == 2){
       if(adType < 2){
         ///google banner ad
         FirebaseAdMob.instance.initialize(appId: getBannerAdUnitId());
         _bannerAd = createBannerAd()
           ..load()
           ..show(anchorOffset: -100);
       }else{
         ///google banner ad
         FirebaseAdMob.instance.initialize(appId: getBannerAdUnitId());
         _bannerAd = createBannerAd()
           ..load()
           ..show();

         ///Google Interstitial Id
         _timerForInter = Timer.periodic(Duration(seconds: 30), (result) {
           _googleinterstitialAd = createInterstitialAd()..load()..show();
         });
       }
    }
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    _timerForInter.cancel();
    _googleinterstitialAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _exitApp(context),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: Color(0xFF376f90),
        ),
        // We're using a Builder here so we have a context that is below the Scaffold
        // to allow calling Scaffold.of(context) so we can show a snackbar.
        body: Builder(builder: (BuildContext context) {
          return Column(
            children: [
              Expanded(
                child: InAppWebView(
                  initialUrlRequest: URLRequest(
                      url: Uri.parse(webinitialUrl),
                      method: 'POST',
                      body: Uint8List.fromList(utf8.encode("firstname=Foo&lastname=Bar")),
                      headers: {
                        'Content-Type': 'application/x-www-form-urlencoded'
                      }
                  ),
                  initialOptions: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(
                        useOnDownloadStart: true
                    ),
                  ),
                  onWebViewCreated: (InAppWebViewController controller){
                    _webViewController = controller;
                    controller.addJavaScriptHandler(handlerName: "mySum", callback: (args) {
                      // Here you receive all the arguments from the JavaScript side
                      // that is a List<dynamic>
                      print("From the JavaScript side:");
                      print(args);
                      return args.reduce((curr, next) => curr + next);
                    });
                  },

                  onLoadStart: onLoadStart,
                  onLoadStop: onLoadStop,

                  onConsoleMessage: (InAppWebViewController controller, ConsoleMessage consoleMessage) {
                    print("console message: ${consoleMessage.message}");
                  },

                  onDownloadStart: (controller, url)async{

                    final status = await Permission.storage.request();

                     if (status.isGranted){

                      final externalDir = await getExternalStorageDirectory();

                       print("onDownloadStart $url");

                      await FlutterDownloader.enqueue(
                       url: url.toString(),
                       savedDir: externalDir.path,
                       showNotification: true, // show download progress in status bar (for Android)
                       openFileFromNotification: true, // click on notification to open downloaded file (for Android)
                     );
                       print("onDownloadStart $url");
                     }
                     else{
                       print("Permission Denied!");
                     }
                  },
                ),
              ),
              //To display Facebook Ad..
              _currentAd,
            ],
          );
        }),
      ),
    );
  }

   void onLoadStart(InAppWebViewController controller, Uri url){
   if(mounted)setState(() async {
     webUrl = url.toString();
     if(webUrl.startsWith("mailto") || webUrl.startsWith("tel:") || webUrl.startsWith("sms:")){
       controller.stopLoading();
       launchNative(webUrl);
       print("redirect to gmail");
     }
     else{
       print("couldn't find email");
     }
   });
  }
  launchNative(url) async{
    if(Platform.isIOS){
      // for iOS phone only
      if( await canLaunch(url)){
        await launch(url, forceSafariVC: false);
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: new Text("whatsapp no installed")));
      }
    }else{
    // android , web
      if( await canLaunch(url)){
        await launch(url);
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: new Text("Whatsapp not installed")));
      }
    }
  }

  void onLoadStop(InAppWebViewController controller, Uri url){
    if(mounted)setState(() async {
      webUrl = url.toString();
      if(webUrl.startsWith("mailto") || webUrl.startsWith("tel:") || webUrl.startsWith("sms:")){

        launchNative(webUrl);
        print("redirect to gmail");
      }
      else{
        print("couldn't find email");
      }
    });
  }

  _showInterstitialAd() {
    if (_isInterstitialAdLoaded == true)
      FacebookInterstitialAd.showInterstitialAd();
    else
      print("Interstial Ad not yet loaded!");
  }

  Future<void> initPlatformState() async {
    OneSignal.shared.init(
      oneSignalAppId,
    );

    OneSignal.shared.setInFocusDisplayType(
        OSNotificationDisplayType.notification);
  }

}


