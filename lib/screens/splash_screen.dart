import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pgc/responseModel/user.dart';
import 'package:pgc/screens/login_screen.dart';
import 'package:pgc/screens/mainmenu_screen.dart';
import 'package:pgc/utilities/constants.dart';
import 'package:pgc/widgets/background.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../services/http/getHttpWithTokenTimeout.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with WidgetsBindingObserver {
  User? user;
  String version = "";
  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addObserver(this);

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
      /*  */
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
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        version,
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
    /*  Timer(
        Duration(seconds: 2),
        () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LogInScreen()),
            )); */

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LogInScreen()));
  }

  void _goMainMenu() {
    _getProfile();
  }

  Future<void> _checkToken() async {
    try {
      setState(() {
        version = 'V ${dotenv.env['CURRENT_VER']}';
      });

      final storage = new FlutterSecureStorage();
      String? userId = await storage.read(key: 'userId');
      String? token = await storage.read(key: 'token');

      if (userId == null || token == null) {
        _goLogin();
      } else {
        _goMainMenu();
      }
    } catch (e) {
      FToast fToast = FToast();
      fToast.init(context);

      fToast.showToast(
          toastDuration: Duration(seconds: 10),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 1, horizontal: 10),
            decoration: BoxDecoration(
                color: Color.fromRGBO(75, 132, 241, 1),
                borderRadius: BorderRadius.circular(20)),
            /*    child: Text(
              'เกิดข้อผิดพลาดระหว่างอ่านข้อมูล',
              style: toastTextStyle,
            ), */
            child: Text(
              e.toString(),
              style: toastTextStyle,
            ),
          ));
    }
  }

  Future<void> _getProfile() async {
    try {
      final storage = new FlutterSecureStorage();
      String? token = await storage.read(key: 'token');

      var getUserByMeUrl = Uri.parse(
          '${dotenv.env['BASE_API']}${dotenv.env['GET_USER_BY_ME_PATH']}');

      var res = await getHttpWithTokenTimeout(
        getUserByMeUrl,
        token,
      );

      var checkRes = jsonDecode(res)['resultCode'];

      if (checkRes == '20000') {
        user = userFromJson(res);

        await storage.write(
            key: 'userId', value: user!.resultData.userId ?? "");
        await storage.write(
            key: 'profileUrl', value: user!.resultData.imageProfileFile ?? "");
        await storage.write(
            key: 'firstName', value: user!.resultData.firstnameTh ?? "");
        await storage.write(
            key: 'lastName', value: user!.resultData.lastnameTh ?? "");
        await storage.write(
            key: 'department',
            value: user!
                    .resultData.empInfo.empDepartmentInfo.empDepartmentNameTh ??
                "");

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MainMenuScreen()));
      } else {
        _goLogin();
      }

      /*     Timer(
          Duration(seconds: 2),
          () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MainMenuScreen()),
              )); */
    } catch (e) {
      FToast fToast = FToast();
      fToast.init(context);

      fToast.showToast(
          toastDuration: Duration(seconds: 10),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 1, horizontal: 10),
            decoration: BoxDecoration(
                color: Color.fromRGBO(75, 132, 241, 1),
                borderRadius: BorderRadius.circular(20)),
            child: Text(
              e.toString(),
              style: toastTextStyle,
            ),
          ));

      _goLogin();
    }
  }
}
