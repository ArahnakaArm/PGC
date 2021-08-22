import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pgc/screens/history.dart';
import 'package:pgc/screens/processwork.dart';
import 'package:pgc/screens/worklist.dart';
import 'package:pgc/widgets/background.dart';
import 'package:pgc/utilities/constants.dart';
import 'package:badges/badges.dart';
import 'package:pgc/widgets/dialogbox/callDialogBox.dart';
import 'package:pgc/widgets/profilebar.dart';
import 'package:pgc/widgets/profilebarwithdepartment.dart';
import 'package:url_launcher/url_launcher.dart';

class MainMenuScreen extends StatefulWidget {
  @override
  _MainMenuScreenState createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  DateTime current;

  Future<bool> popped() {
    FToast fToast = FToast();
    fToast.init(context);

    DateTime now = DateTime.now();
    if (current == null || now.difference(current) > Duration(seconds: 2)) {
      current = now;
      /*     Fluttertoast.showToast(
          msg: "กดย้อนกลับอีกครั้งเพื่อปิด", toastLength: Toast.LENGTH_SHORT); */
      fToast.showToast(
          child: Container(
        padding: EdgeInsets.symmetric(vertical: 1, horizontal: 10),
        decoration: BoxDecoration(
            color: Color.fromRGBO(75, 132, 241, 1),
            borderRadius: BorderRadius.circular(20)),
        child: Text(
          'กดปุ่มกลับอีกครั้ง เพื่อออกจากแอป',
          style: toastTextStyle,
        ),
      ));
      return Future.value(false);
    } else {
      Fluttertoast.cancel();
      return Future.value(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => popped(),
        child: Scaffold(
            body: SafeArea(
          child: Stack(
            children: <Widget>[
              BackGround(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ProfileBarWithDepartment(),
                      SizedBox(height: 30),
                      _getWithNotiBoxMenu('assets/images/bus.png', 'รับงาน',
                          Color.fromRGBO(255, 255, 255, 1), context),
                      SizedBox(height: 22),
                      _getCommonBoxMenu('assets/images/clock.png', 'ประวัติงาน',
                          Color.fromRGBO(240, 173, 78, 1), context),
                      SizedBox(height: 22),
                      _getCommonBoxMenu(
                          'assets/images/assist.png',
                          'ติดต่อเจ้าหน้าที่',
                          Color.fromRGBO(232, 85, 85, 1),
                          context)
                    ]),
              )
            ],
          ),
        )));
  }

  GestureDetector _getCommonBoxMenu(assetPath, text, color, context) {
    return GestureDetector(
        onTap: () {
          if (text == 'ประวัติงาน') {
            _goHistory(context);
          } else {
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

  Dialog _dialogBox() {
    return Dialog(
      shape: RoundedRectangleBorder(),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(),
    );
  }

  Container contentBox() {
    return Container(
      width: 200,
      height: 200,
    );
  }

  GestureDetector _getWithNotiBoxMenu(assetPath, text, color, context) {
    return GestureDetector(
        onTap: () {
          _goProcessWork(context);
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
                  Badge(
                      position: BadgePosition.topEnd(top: -5, end: -35),
                      toAnimate: false,
                      shape: BadgeShape.circle,
                      badgeColor: Color.fromRGBO(255, 0, 0, 1),
                      borderRadius: BorderRadius.circular(8),
                      badgeContent: Container(
                        width: 18,
                        height: 18,
                        alignment: Alignment.center,
                        child: Text(
                          '14',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                      child: Text(
                        text,
                        style: mainMenuBoxTextStyle,
                      )),
                ],
              ),
            )));
  }
}

void _goProcessWork(context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => WorkList()),
  );
}

void _goHistory(context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => History()),
  );
}

void _openCallDialog(context) {}

void _showDialog(context) {
  showGeneralDialog(
    barrierLabel: "Barrier",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: Duration(milliseconds: 250),
    context: context,
    pageBuilder: (_, __, ___) {
      return CallDialogBox('097-347-1602');
    },
    transitionBuilder: (_, anim, __, child) {
      return SlideTransition(
        position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
        child: child,
      );
    },
  );
}

Future<void> _makePhoneCall(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
