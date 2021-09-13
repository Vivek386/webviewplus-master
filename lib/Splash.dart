import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tirth_industries/webbview.dart';
import 'webview.dart';
import 'package:tirth_industries/Helper/Session.dart';
import 'Intro_Slider.dart';
import 'package:tirth_industries/Helper/String.dart';



class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  //bool _isNetworkAvail = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    startTime();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Image.asset(
          'assets/images/splashlogo.gif',
          fit: BoxFit.fill,
        ),
      ),
    );
  }


  startTime() async {
    var _duration = Duration(seconds: 5);
    return Timer(_duration, navigationPage);
  }

  Future<void> navigationPage() async {
    bool isFirstTime = await getPrefrenceBool(ISFIRSTTIME);
    //_isNetworkAvail = await isNetworkAvailable();
    if (isFirstTime) {
      // Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => WebViewPlus(),
      //     ));
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WebViewExample(),
          ));
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Intro_Slider(),
          ));
    }
  }


}


