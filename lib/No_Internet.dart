import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tirth_industries/Helper/Session.dart';
import 'webview.dart';

class NoInternet extends StatefulWidget {
  @override
  _NoInternetState createState() => _NoInternetState();
}

class _NoInternetState extends State<NoInternet> {

  int _state = 0;
  bool _isNetworkAvail = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset("assets/images/no_internet.png"),
              SizedBox(height: 10),
              Text("No Internet",
                style: TextStyle(color: Colors.black,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text("Please check your connection again, or connect to Wi-Fi",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30),
              MaterialButton(
                child: setUpButtonChild(),
                onPressed: () async {

                  _isNetworkAvail = await isNetworkAvailable();
                  if (_isNetworkAvail) {

                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WebViewPlus(),
                        ));

                  }

                  else{
                    setState(() {
                      if (_state == 0) {
                        animateButton();
                      }
                    });
                  }

                },
                elevation: 4.0,
                minWidth: 200,
                height: 60.0,
                color: Color(0xffFE7E7B),
              ),
            ]),
      ),
    );
  }

  Widget setUpButtonChild() {
    if (_state == 0) {
      return new Text(
        "Try Again",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16.0,
        ),
      );
    } else if (_state == 1) {
      return CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      );
    } else{
      //return Icon(Icons.check, color: Colors.white);
      return Text(
        "Try Again",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16.0,
        ),
      );
    }
  }

  void animateButton() {
    setState(() {
      _state = 1;
    });

    Timer(Duration(milliseconds: 3300), () {
      setState(() {
        _state = 2;
      });
    });
  }

}

