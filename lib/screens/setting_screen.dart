import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pgc/screens/changepassword_screen.dart';
import 'package:pgc/screens/login_screen.dart';
import 'package:pgc/screens/worklist.dart';
import 'package:pgc/utilities/constants.dart';
import 'package:pgc/widgets/background.dart';
import 'package:pgc/widgets/backpress.dart';
import 'package:pgc/widgets/profilebarwithdepartment.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key key}) : super(key: key);

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Stack(
        children: <Widget>[
          BackGround(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  BackPress(context),
                  SizedBox(height: 35),
                  _getCommonBoxMenu(
                      'assets/images/password.png',
                      'เปลี่ยนรหัสผ่าน',
                      Color.fromRGBO(255, 255, 255, 1),
                      context),
                  SizedBox(height: 22),
                  _getCommonBoxMenu('assets/images/log-out.png', 'ออกจากระบบ',
                      Color.fromRGBO(232, 85, 85, 1), context)
                ]),
          )
        ],
      ),
    ));
  }
}

GestureDetector _getCommonBoxMenu(assetPath, text, color, context) {
  return GestureDetector(
      onTap: () {
        if (text == 'เปลี่ยนรหัสผ่าน') {
          _goChangePassword(context);
        } else if (text == 'ออกจากระบบ') {
          _showDialog(context);
        }
      },
      child: Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15),
          ),
          height: 68,
          child: Container(
            padding: EdgeInsets.only(left: 25, right: 5),
            child: Row(
              children: [
                Image.asset(
                  assetPath,
                  height: 45,
                  width: 55,
                ),
                SizedBox(width: 15),
                Text(
                  text,
                  style: mainMenuBoxTextStyle,
                )
              ],
            ),
          )));
}

void _goProcessWork(context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => WorkList()),
  );
}

void _backPress(context) {
  Navigator.pop(context);
}

GestureDetector _backButton(context) {
  return GestureDetector(
    onTap: () {
      _backPress(context);
    },
    child: Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            'assets/images/backarrow.png',
            height: 25,
          ),
          SizedBox(
            width: 15,
          ),
          Text(
            'กลับไปก่อนหน้า',
            style: backPressTextStyle,
          )
        ],
      ),
    ),
  );
}

void _goLoginScreen(context) async {
  final storage = new FlutterSecureStorage();
  await storage.delete(key: 'token');
  await storage.delete(key: 'userId');
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (BuildContext context) => LogInScreen(),
    ),
    (route) => false,
  );
}

void _goChangePassword(context) {
  Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (BuildContext context) => ChangePasswordScreen(),
    ),
  );
}

void _showDialog(context) {
  showGeneralDialog(
    barrierLabel: "Barrier",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: Duration(milliseconds: 250),
    context: context,
    pageBuilder: (_, __, ___) {
      return Column(
        children: <Widget>[
          Container(
            alignment: Alignment.topCenter,
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.only(top: 250, left: 40, right: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 30,
                        ),
                        FittedBox(
                          child: Text(
                            'ยืนยันการออกจากระบบ ?',
                            style: callDialogBlueTextStyle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: GestureDetector(
                              onTap: () {
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 5),
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(137, 137, 137, 1),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.zero,
                                    topRight: Radius.zero,
                                    bottomLeft: Radius.circular(8),
                                    bottomRight: Radius.zero,
                                  ),
                                ),
                                child: Center(
                                  child: FittedBox(
                                    child: Text(
                                      'ปิด',
                                      style: buttonDialogTextStyle,
                                    ),
                                  ),
                                ),
                              )),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context, rootNavigator: true).pop();
                              _goLoginScreen(context);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(1, 84, 155, 1),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.zero,
                                  topRight: Radius.zero,
                                  bottomLeft: Radius.zero,
                                  bottomRight: Radius.circular(8),
                                ),
                              ),
                              child: Center(
                                  child: FittedBox(
                                child: Text(
                                  'ตกลง',
                                  style: buttonDialogTextStyle,
                                ),
                              )),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      );
    },
    transitionBuilder: (_, anim, __, child) {
      return SlideTransition(
        position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
        child: child,
      );
    },
  );
}
