import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pgc/screens/login_screen.dart';
import 'package:pgc/screens/mainmenu_screen.dart';
import 'package:pgc/utilities/constants.dart';
import 'package:pgc/widgets/background.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addObserver(this);
    print('create');
    _checkToken();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('resume');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Stack(
        children: <Widget>[
          BackGround(),
          Container(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  transform: Matrix4.translationValues(0.0, -50.0, 0.0),
                  child: Column(
                    children: <Widget>[
                      Image.asset(
                        'assets/images/pcglogo.png',
                        height: 75,
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        height: 35,
                        width: 35,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color.fromRGBO(196, 196, 196, 1)),
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'กำลังโหลด...',
                        style: splashScreenLoadingTextStyle,
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    ));
  }

  void _goLogin() {
    Timer(
        Duration(seconds: 2),
        () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LogInScreen()),
            ));
  }

  void _goMainMenu() {
    Timer(
        Duration(seconds: 2),
        () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainMenuScreen()),
            ));
  }

  void _checkToken() async {
    final storage = new FlutterSecureStorage();
    String userId = await storage.read(key: 'userId');
    String token = await storage.read(key: 'token');

    if (userId == null || token == null) {
      _goLogin();
    } else {
      _goMainMenu();
    }
  }
}
