import 'dart:convert';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pgc/responseModel/buslistinfo.dart';
import 'package:pgc/responseModel/user.dart';
import 'package:pgc/screens/history.dart';
import 'package:pgc/screens/unity/message.dart';
import 'package:pgc/screens/worklist.dart';
import 'package:pgc/services/http/getHttpWithToken.dart';
import 'package:pgc/services/utils/common.dart';
import 'package:pgc/widgets/background.dart';
import 'package:pgc/utilities/constants.dart';
import 'package:badges/badges.dart';
import 'package:pgc/widgets/dialogbox/callDialogBox.dart';
import 'package:pgc/widgets/profilebarwithdepartment.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class MainMenuScreen extends StatefulWidget {
  @override
  _MainMenuScreenState createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  AndroidNotificationChannel channel;

  /// Initialize the [FlutterLocalNotificationsPlugin] package.
  FlutterLocalNotificationsPlugin localNotification;
  String _tokenNoti;
  Stream<String> _tokenStream;
  DateTime current;
  User user;
  BusListInfo busListInfo;
  var workCounts;
  get http => null;
  bool isConnect = true;

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

  Future _showNotification(title, body) async {
    var androidDetails = new AndroidNotificationDetails(
        "channelId", "channelName", "channelDescription",
        importance: Importance.high);

    var iosDetails = new IOSNotificationDetails();
    var generalNotificationDetails =
        new NotificationDetails(android: androidDetails, iOS: iosDetails);

    await localNotification.show(0, title, body, generalNotificationDetails);
  }

  @override
  void initState() {
    var androidInitialize = new AndroidInitializationSettings('ic_launcher');
    var iOSInitialize = new IOSInitializationSettings();
    var initialzationSettings = new InitializationSettings(
        android: androidInitialize, iOS: iOSInitialize);

    localNotification = new FlutterLocalNotificationsPlugin();

    localNotification.initialize(initialzationSettings);
    // TODO: implement initState
    _checkInternet();
    /*    if (isConnect) {
      _getWorkCounts();
    }
 */
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage message) {
      if (message != null) {}
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification notification = message.notification;
      print(notification.title);
      print(notification.body);
      await _showNotification(notification.title, notification.body);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      Navigator.pushNamed(context, '/message',
          arguments: MessageArguments(message, true));
    });
    super.initState();
    /*   _getProfile(); */
  }

  void setToken(String token) {
    print('FCM Token: $token');
    setState(() {
      _tokenNoti = token;
    });
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

  Future<void> _getProfile() async {
    final storage = new FlutterSecureStorage();
    String token = await storage.read(key: 'token');
    var getUserByMeUrl = Uri.parse(
        '${dotenv.env['BASE_API']}${dotenv.env['GET_USER_BY_ME_PATH']}');

    /*    var userByMeRes = await getHttpWithToken(getUserByMeUrl, token); */
    var res = await getHttpWithToken(
      getUserByMeUrl,
      token,
    );

    setState(() {
      user = userFromJson(res) ?? '';
      storage.write(key: 'profileUrl', value: user.resultData.imageProfileFile);
      storage.write(key: 'firstName', value: user.resultData.firstnameTh);
      storage.write(key: 'lastName', value: user.resultData.lastnameTh);
      storage.write(
          key: 'department',
          value:
              user.resultData.empInfo.empDepartmentInfo.empDepartmentNameTh ??
                  "");
    });
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
                          workCounts ?? "0",
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

  Future<void> _getWorkCounts() async {
    final storage = new FlutterSecureStorage();
    String token = await storage.read(key: 'token');
    String userId = await storage.read(key: 'userId');

    var busStatus = "CONFIRMED";
    var queryString = '?bus_reserve_status_id=${busStatus}';
    var getBusInfoListUrl = Uri.parse(
        '${dotenv.env['BASE_API']}${dotenv.env['GET_BUS_JOB_INFO_LIST']}${queryString}&driver_id=${userId}');
    var res = await getHttpWithToken(getBusInfoListUrl, token);

    var workCountConverted = jsonDecode(res)['rowCount'] as int;

    setState(() {
      workCounts = workCountConverted.toString();
    });
  }

  void _goProcessWork(context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WorkList()),
    ).then((value) async {
      await _checkInternet();
    });
  }

  void _checkInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${dotenv.env['NO_INTERNET_CONNECTION']}')),
      );
    } //
    else {
      FirebaseMessaging.instance.getToken().then(setToken);
      _tokenStream = FirebaseMessaging.instance.onTokenRefresh;
      _tokenStream.listen(setToken);

      if (await Permission.notification.request().isGranted) {
        _sendNotiToken(_tokenNoti);
      } else {}

      await _getWorkCounts();
    }
  }
}

Future<void> _sendNotiToken(notiToken) async {}

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
    /*  transitionBuilder: (_, anim, __, child) {
      return SlideTransition(
        position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
        child: child,
      );
    }, */
  );
}

Future<void> _makePhoneCall(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
