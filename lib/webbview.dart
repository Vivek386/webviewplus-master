import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:tirth_industries/Helper/Constant.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(MaterialApp(home: WebViewExample()));


class WebViewExample extends StatefulWidget {
  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

WebViewController controllerGlobal;

Future<bool> _exitApp(BuildContext context) async {
  if (await controllerGlobal.canGoBack()) {
    print("onwill goback");
    controllerGlobal.goBack();
  } else {
    Scaffold.of(context).showSnackBar(
      const SnackBar(content: Text("No back history item")),
    );
    return Future.value(false);
  }
}
Timer _timerForInter;
class _WebViewExampleState extends State<WebViewExample> {
  final Completer<WebViewController> _controller =
  Completer<WebViewController>();

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

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();

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
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _exitApp(context),
      child: Scaffold(

        appBar: (navigationAppBar==true)
        ?AppBar(
          title: Text(appbartitle),
          // This drop down menu demonstrates that Flutter widgets can be shown over the web view.
          actions: <Widget>[
            NavigationControls(_controller.future),
            //SampleMenu(_controller.future),
          ],
        ):null,
        // We're using a Builder here so we have a context that is below the Scaffold
        // to allow calling Scaffold.of(context) so we can show a snackbar.
        body: Builder(builder: (BuildContext context) {
          return Column(
            children: [
              Expanded(
                child: WebView(
                  initialUrl: webinitialUrl,
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (WebViewController webViewController) {
                    _controller.complete(webViewController);
                  },
                  // TODO(iskakaushik): Remove this when collection literals makes it to stable.
                  // ignore: prefer_collection_literals
                  javascriptChannels: <JavascriptChannel>[
                    _toasterJavascriptChannel(context),
                  ].toSet(),
                  navigationDelegate: (NavigationRequest request) {
                    if (request.url.startsWith('https://www.youtube.com/')) {
                      print('blocking navigation to $request}');
                      return NavigationDecision.prevent;
                    }
                    if (request.url.startsWith('https://flutter.dev/docs')) {
                      print('blocking navigation to $request}');
                      return NavigationDecision.prevent;
                    }
                    // if (request.url.startsWith('https://www.google.com/maps')) {
                    //   print('blocking navigation to $request}');
                    //   return NavigationDecision.prevent;
                    // }
                    if (request.url.startsWith('mailto') || request.url.startsWith("tel:")
                        || request.url.startsWith("sms:")|| request.url.startsWith("market:") || request.url.startsWith("geo:")) {
                         launchNative(request.url);
                      print('blocking navigation to $request}');
                      return NavigationDecision.prevent;
                    }
                    // if (request.url.startsWith('geo')) {
                    //   launchNative("https://www.google.com/maps/search/?api=1&parameters");
                    //   print('blocking navigation to $request}');
                    //   return NavigationDecision.prevent;
                    // }
                    ///request.url.startsWith("geo:")
                    print('allowing navigation to $request');
                    return NavigationDecision.navigate;
                  },
                  onPageFinished: (String url) {
                    print('Page finished loading: $url');
                  },
                ),
              ),
              _currentAd
            ],
          );
        }),
        //floatingActionButton: favoriteButton(),
      ),
    );
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
  ///maps url : ==> url: geo://?q=Delhi+Date+House
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

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }

  Widget favoriteButton() {
    return FutureBuilder<WebViewController>(
        future: _controller.future,
        builder: (BuildContext context,
            AsyncSnapshot<WebViewController> controller) {
          if (controller.hasData) {
            return FloatingActionButton(
              onPressed: () async {
                final String url = await controller.data.currentUrl();
                Scaffold.of(context).showSnackBar(
                  SnackBar(content: Text('Favorited $url')),
                );
              },
              child: const Icon(Icons.favorite),
            );
          }
          return Container();
        });
  }
}

enum MenuOptions {
  showUserAgent,
  listCookies,
  clearCookies,
  addToCache,
  listCache,
  clearCache,
  navigationDelegate,
}

class SampleMenu extends StatelessWidget {
  SampleMenu(this.controller);

  final Future<WebViewController> controller;
  final CookieManager cookieManager = CookieManager();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: controller,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> controller) {
        return PopupMenuButton<MenuOptions>(
          onSelected: (MenuOptions value) {
            switch (value) {
              case MenuOptions.showUserAgent:
                _onShowUserAgent(controller.data, context);
                break;
              case MenuOptions.listCookies:
                _onListCookies(controller.data, context);
                break;
              case MenuOptions.clearCookies:
                _onClearCookies(context);
                break;
              case MenuOptions.addToCache:
                _onAddToCache(controller.data, context);
                break;
              case MenuOptions.listCache:
                _onListCache(controller.data, context);
                break;
              case MenuOptions.clearCache:
                _onClearCache(controller.data, context);
                break;
              case MenuOptions.navigationDelegate:
                _onNavigationDelegateExample(controller.data, context);
                break;
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuItem<MenuOptions>>[
            PopupMenuItem<MenuOptions>(
              value: MenuOptions.showUserAgent,
              child: const Text('Show user agent'),
              enabled: controller.hasData,
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.listCookies,
              child: Text('List cookies'),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.clearCookies,
              child: Text('Clear cookies'),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.addToCache,
              child: Text('Add to cache'),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.listCache,
              child: Text('List cache'),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.clearCache,
              child: Text('Clear cache'),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.navigationDelegate,
              child: Text('Navigation Delegate example'),
            ),
          ],
        );
      },
    );
  }

  void _onShowUserAgent(
      WebViewController controller, BuildContext context) async {
    // Send a message with the user agent string to the Toaster JavaScript channel we registered
    // with the WebView.
    controller.evaluateJavascript(
        'Toaster.postMessage("User Agent: " + navigator.userAgent);');
  }

  void _onListCookies(
      WebViewController controller, BuildContext context) async {
    final String cookies =
    await controller.evaluateJavascript('document.cookie');
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text('Cookies:'),
          _getCookieList(cookies),
        ],
      ),
    ));
  }

  void _onAddToCache(WebViewController controller, BuildContext context) async {
    await controller.evaluateJavascript(
        'caches.open("test_caches_entry"); localStorage["test_localStorage"] = "dummy_entry";');
    Scaffold.of(context).showSnackBar(const SnackBar(
      content: Text('Added a test entry to cache.'),
    ));
  }

  void _onListCache(WebViewController controller, BuildContext context) async {
    await controller.evaluateJavascript('caches.keys()'
        '.then((cacheKeys) => JSON.stringify({"cacheKeys" : cacheKeys, "localStorage" : localStorage}))'
        '.then((caches) => Toaster.postMessage(caches))');
  }

  void _onClearCache(WebViewController controller, BuildContext context) async {
    await controller.clearCache();
    Scaffold.of(context).showSnackBar(const SnackBar(
      content: Text("Cache cleared."),
    ));
  }

  void _onClearCookies(BuildContext context) async {
    final bool hadCookies = await cookieManager.clearCookies();
    String message = 'There were cookies. Now, they are gone!';
    if (!hadCookies) {
      message = 'There are no cookies.';
    }
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  String kNavigationExamplePage = '''
<!DOCTYPE html><html>
<head><title>Navigation Delegate Example</title></head>
<body>
<p>
The navigation delegate is set to block navigation to the youtube website.
</p>
<ul>
<ul><a href="https://www.youtube.com/">https://www.youtube.com/</a></ul>
<ul><a href="https://www.google.com/">https://www.google.com/</a></ul>
<ul><a href="https://www.google.com/">https://nodejs.org/en</a></ul>
</ul>
</body>
</html>
''';

  void _onNavigationDelegateExample(
      WebViewController controller, BuildContext context) async {
    final String contentBase64 =
    base64Encode(const Utf8Encoder().convert(kNavigationExamplePage));
    controller.loadUrl('data:text/html;base64,$contentBase64');
  }

  Widget _getCookieList(String cookies) {
    if (cookies == null || cookies == '""') {
      return Container();
    }
    final List<String> cookieList = cookies.split(';');
    final Iterable<Text> cookieWidgets =
    cookieList.map((String cookie) => Text(cookie));
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: cookieWidgets.toList(),
    );
  }
}



class NavigationControls extends StatelessWidget {
  const NavigationControls(this._webViewControllerFuture)
      : assert(_webViewControllerFuture != null);

  final Future<WebViewController> _webViewControllerFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: _webViewControllerFuture,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> snapshot) {
        final bool webViewReady =
            snapshot.connectionState == ConnectionState.done;
        final WebViewController controller = snapshot.data;
        controllerGlobal = controller;

        return Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: !webViewReady
                  ? null
                  : () async {
                if (await controller.canGoBack()) {
                  controller.goBack();
                } else {
                  Scaffold.of(context).showSnackBar(
                    const SnackBar(content: Text("No back history item")),
                  );
                  return;
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: !webViewReady
                  ? null
                  : () async {
                if (await controller.canGoForward()) {
                  controller.goForward();
                } else {
                  Scaffold.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("No forward history item")),
                  );
                  return;
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.replay),
              onPressed: !webViewReady
                  ? null
                  : () {
                controller.reload();
              },
            ),
          ],
        );
      },
    );
  }
}