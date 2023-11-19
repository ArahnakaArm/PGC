import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pgc/responseModel/deviceToken.dart';
import 'package:pgc/screens/changepassword_screen.dart';
import 'package:pgc/screens/login_screen.dart';
import 'package:pgc/screens/worklist.dart';
import 'package:pgc/services/http/deleteHttpWithToken.dart';
import 'package:pgc/services/http/getHttpWithToken.dart';
import 'package:pgc/utilities/constants.dart';
import 'package:pgc/widgets/background.dart';
import 'package:pgc/widgets/backpress.dart';
import 'package:pgc/widgets/dialogbox/confirmLogoutDialogBox.dart';
import 'package:pgc/widgets/dialogbox/loadingDialogBox.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  List<DeviceTokenArray> deviceTokenArr = [];
  String version = "";
  @override
  void initState() {
    // TODO: implement initState
    setVersion();
    super.initState();
  }

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
                crossAxisAlignment: CrossAxisAlignment.center,
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
                      Color.fromRGBO(232, 85, 85, 1), context),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    version,
                    style: splashScreenLoadingTextStyle,
                  )
                ]),
          )
        ],
      ),
    ));
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
    ).then((value) async {
      if (value != null) {
        _goLoginScreen();
      } else {}
    });
  }

  void _goLoginScreen() async {
    await _deleteDeviceToken();
    final storage = new FlutterSecureStorage();
    await storage.delete(key: 'token');
    await storage.delete(key: 'userId');
    await storage.delete(key: 'deviceToken');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => LogInScreen(),
      ),
      (route) => false,
    );
  }

  Future<void> _deleteDeviceToken() async {
    final storage = new FlutterSecureStorage();
    String? token = await storage.read(key: 'token');
    String? userId = await storage.read(key: 'userId');
    String? deviceToken = await storage.read(key: 'deviceToken');

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingDialogBox();
        },
      );

      var queryString = "?user_id=${userId}";
      var getDeviceTokenUrl = Uri.parse(
          '${dotenv.env['BASE_API']}${dotenv.env['GET_ALL_DEVICE_TOKEN']}${queryString}');

      var getDeviceTokenRes = await getHttpWithToken(getDeviceTokenUrl, token);

      deviceTokenArr = (jsonDecode(getDeviceTokenRes)['resultData'] as List)
          .map((i) => DeviceTokenArray.fromJson(i))
          .toList();

      var rowId = "";
      for (int i = 0; i < deviceTokenArr.length; i++) {
        if (deviceTokenArr[i].deviceToken == deviceToken) {
          rowId = deviceTokenArr[i].rowId;
        }
      }
      var deleteDeviceTokenUrl = Uri.parse(
          '${dotenv.env['BASE_API']}${dotenv.env['DELETE_DEVICE_TOKEN']}/${rowId}');

      var res = await deleteHttpWithToken(deleteDeviceTokenUrl, token);
      Navigator.pop(context); //pop dialog
    } catch (e) {
      Navigator.pop(context); //pop dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${dotenv.env['NO_INTERNET_CONNECTION']}')),
      );
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

  void setVersion() {
    setState(() {
      version = 'V ${dotenv.env['CURRENT_VER']}';
    });
  }
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

void _goChangePassword(context) {
  Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (BuildContext context) => ChangePasswordScreen(),
    ),
  );
}
