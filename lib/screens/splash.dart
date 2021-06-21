import 'dart:async';
import 'package:Shareout/constants.dart';
import 'package:Shareout/screens/Home.dart';

import 'package:flutter/material.dart';

class Splash extends StatefulWidget {
  final backgroundColor = kPrimaryGradientColor;
  final TextStyle styleTextUnderTheLoader = TextStyle(
      fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  String _versionName = 'V1.0';
  final splashDelay = 5;

  @override
  void initState() {
    super.initState();

    _loadWidget();
  }

  _loadWidget() async {
    var _duration = Duration(seconds: splashDelay);
    return Timer(_duration, navigationPage);
  }

  void navigationPage() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (BuildContext context) => Home()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InkWell(
        child: Container(
          decoration: BoxDecoration(
            gradient: kPrimaryGradientColor,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 7,
                    child: Container(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        //Image.asset(
                        // 'assets/images/google_signin_button.png',
                        // height: 300,
                        // width: 300,
                        //),
                        Text(
                          "ShareOut",
                          style: TextStyle(
                              fontFamily: "Signatra",
                              fontSize: 90.0,
                              color: Colors.white),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                        ),
                      ],
                    )),
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        CircularProgressIndicator(
                          backgroundColor: Colors.white,
                        ),
                        Container(
                          height: 10,
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Spacer(),
                              Text(
                                _versionName,
                                style: TextStyle(color: Colors.white),
                              ),
                              Spacer(
                                flex: 4,
                              ),
                              Text(
                                'Loading...',
                                style: TextStyle(color: Colors.white),
                              ),
                              Spacer(),
                            ])
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
