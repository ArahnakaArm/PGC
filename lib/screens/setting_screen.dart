import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pgc/screens/changepassword_screen.dart';
import 'package:pgc/screens/login_screen.dart';
import 'package:pgc/screens/worklist.dart';
import 'package:pgc/utilities/constants.dart';
import 'package:pgc/widgets/background.dart';
import 'package:pgc/widgets/backpress.dart';
import 'package:pgc/widgets/dialogbox/confirmLogoutDialogBox.dart';
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
      return ConfirmLogoutDialogBox();
    },
  );
}
