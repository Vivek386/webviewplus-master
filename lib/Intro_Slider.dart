import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tirth_industries/Helper/Session.dart';
import 'Helper/String.dart';
import 'webview.dart';



class Intro_Slider extends StatefulWidget {
  @override
  _Intro_SliderState createState() => _Intro_SliderState();
}

class _Intro_SliderState extends State<Intro_Slider> {

  double deviceHeight;
  double deviceWidth;

  int _currentPage = 0;
  final PageController _pageController = PageController();
  List slideList = [];

  @override
  void initState() {
    super.initState();
      slideList = [
        Slide(
          imageUrl: 'assets/images/introimage_a.png',
          title: "Page1",
          description: "Himachal",
        ),
        Slide(
          imageUrl: 'assets/images/introimage_b.png',
          title: "Page2",
          description: "Rohtang",
        ),
        Slide(
          imageUrl: 'assets/images/introimage_c.png',
          title: "Page3",
          description: "LehLadakh",
        ),
      ];
  }
  @override
  void dispose(){
    super.dispose();
    _pageController.dispose();
  }

  _onPageChanged(int index){
    if (mounted){
      setState(() {
        _currentPage = index;
      });
    }
  }

  Widget _slider(){
    return Expanded(
      child: PageView.builder(
        scrollDirection: Axis.horizontal,
          itemCount: slideList.length,
          controller: _pageController,
          onPageChanged: _onPageChanged,
          itemBuilder: (BuildContext context,int index){
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Image.asset(slideList[index].imageUrl),
                ),
                Container(
                  child: Text(slideList[index].title,
                  style: TextStyle(color: Colors.black54,fontWeight: FontWeight.bold,fontSize: 20),
                  ),
                ),
                Container(
                    child: Text(slideList[index].description,
                      style: TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.normal,fontSize: 15),
                    ),
                ),
              ],
            ),
          );
          },
          ),
    );
  }

  _btn(){
    return Column(
      children: [
        Center(
          child: GestureDetector(
            onTap: (){
              if (_currentPage == 2) {
                setPrefrenceBool(ISFIRSTTIME, true);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => WebViewPlus()),
                );
              } else {
                _currentPage = _currentPage + 1;
                _pageController.animateToPage(_currentPage,
                    curve: Curves.decelerate,
                    duration: Duration(milliseconds: 300));
              }
            },
            child: Container(
              height: 45,
              width: deviceWidth * 0.8,
              color: Colors.deepOrangeAccent,
              margin : EdgeInsets.symmetric(horizontal: 10.0,vertical: 25.0) ,
              padding: EdgeInsets.only(top: 15),
              child: Text("Next",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    SystemChrome.setEnabledSystemUIOverlays([]);

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _slider(),
          _btn(),
        ],
      ),
    );
  }
}

class Slide{
  final String imageUrl;
  final String title;
  final String description;

  Slide({
        @required this.imageUrl,
        @required this.title,
        @required this.description
      });
}
