// ignore_for_file: await_only_futures

import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pgc/responseModel/buslistinfo.dart';
import 'package:pgc/responseModel/deviceToken.dart';
import 'package:pgc/responseModel/user.dart';
import 'package:pgc/screens/history.dart';
import 'package:pgc/screens/notification_screen.dart';
import 'package:pgc/screens/setting_screen.dart';
import 'package:pgc/screens/worklist.dart';
import 'package:pgc/services/http/getHttpWithToken.dart';
import 'package:pgc/services/http/patchHttpWithToken.dart';
import 'package:pgc/services/http/postHttpWithToken.dart';
import 'package:pgc/services/utils/common.dart';
import 'package:pgc/widgets/background.dart';
import 'package:pgc/utilities/constants.dart';
import 'package:badges/badges.dart';
import 'package:pgc/widgets/dialogbox/callDialogBox.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as httpp;
import 'package:badges/badges.dart' as badges;

class MainMenuScreen extends StatefulWidget {
  @override
  _MainMenuScreenState createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with WidgetsBindingObserver {
  AndroidNotificationChannel? channel;
  IO.Socket? socket;
  List<ResultDatum> busList = [];
  String version = "";

  /// Initialize the [FlutterLocalNotificationsPlugin] package.
  ///
  FlutterLocalNotificationsPlugin? localNotification;
  String? _tokenNoti = '';
  Stream<String>? _tokenStream;
  DateTime? current;
  User? user;
  String callAdminNumber = "";
  BusListInfo? busListInfo;
  List<DeviceTokenArray>? deviceTokenArr;
  var workCounts;
  get http => null;

  var notiCounts = "0";
  var notiCountsToSend = "0";

  /////////////// Profilebar //////////////////
  bool isConnect = true;
  String? baseProfileUrl;
  bool haveImage = false;
  var firstName;
  var lastName;
  var profileUrl = "";
  var department;
  final ImagePicker _picker = ImagePicker();

  Future<bool> popped() {
    FToast fToast = FToast();
    fToast.init(context);

    DateTime now = DateTime.now();
    if (current == null || now.difference(current!) > Duration(seconds: 2)) {
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

  Future<void> playLocalAsset() async {
    final player = AudioPlayer();
    await player.play(AssetSource('success.wav'));
  }

  Future<void> playLocalAssetFail() async {
    final player = AudioPlayer();
    await player.play(AssetSource('fail.wav'));
  }

  Future _showNotification(data) async {
    var androidDetails = new AndroidNotificationDetails(
        "channelId", "Work Notifications",
        importance: Importance.max, channelShowBadge: true);

    var generalNotificationDetails =
        new NotificationDetails(android: androidDetails);

    await localNotification?.show(
        0, data['title'], data['body'], generalNotificationDetails);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      print('resume');
      await _getNotification();
      await _getWorkCounts();
    }
  }

  @override
  void initState() {
    setVersion();
    WidgetsBinding.instance.addObserver(this);

    var androidInitialize = new AndroidInitializationSettings('ic_launcher');

    var initialzationSettings =
        new InitializationSettings(android: androidInitialize);

    localNotification = new FlutterLocalNotificationsPlugin();

    localNotification?.initialize(initialzationSettings);
    // TODO: implement initState

    /*    if (isConnect) {
      _getWorkCounts();
    }
 */
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        print('A new onMessageOpenedApp event was published!2');
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('A new onMessageOpenedAppQQQQ event was published!s2');
      if (mounted) {
        await _getNotification();
        await _getWorkCounts();
        print('A new onMessageOpenedAppQQQQ event was published!2');
      }
      print('Handling a background message ${message.messageId}');
      await _showNotification(message.data);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
    });

    _checkInternet();
    super.initState();
    /*   _getProfile(); */
  }

  Future<void> setToken(String token) async {
    print('FCM Token: $token');
    setState(() {
      _tokenNoti = token;
    });

    if (await Permission.notification.request().isGranted) {
      _sendNotiToken(_tokenNoti);
      print('GRANT PERMISSION : ' + _tokenNoti!);
    } else {}
  }

  void _deleteNotification() async {
    setState(() {
      notiCounts = "0";
    });
    final storage = new FlutterSecureStorage();
    await storage.write(key: 'notiCounts', value: notiCounts);
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
                    GestureDetector(onTap: () {}, child: _wigetProfilebar()),
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
                        context),
                    SizedBox(
                      height: 22,
                    ),
                    Center(
                        child: Text(
                      version,
                      style: splashScreenLoadingTextStyle,
                    )),
                  ],
                ),
              )
            ],
          ),
        )));
  }

  Future<void> _getProfile() async {
    final storage = new FlutterSecureStorage();
    String? token = await storage.read(key: 'token');
    var getUserByMeUrl = Uri.parse(
        '${dotenv.env['BASE_API']}${dotenv.env['GET_USER_BY_ME_PATH']}');

    /*    var userByMeRes = await getHttpWithToken(getUserByMeUrl, token); */
    var res = await getHttpWithToken(
      getUserByMeUrl,
      token,
    );

    setState(() {
      user = userFromJson(res);
      storage.write(
          key: 'profileUrl', value: user?.resultData.imageProfileFile);
      storage.write(key: 'firstName', value: user?.resultData.firstnameTh);
      storage.write(key: 'lastName', value: user?.resultData.lastnameTh);
      storage.write(
          key: 'department',
          value:
              user?.resultData.empInfo.empDepartmentInfo.empDepartmentNameTh ??
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
                  badges.Badge(
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
    print("?WORK COUNT WORK");
    final storage = new FlutterSecureStorage();
    String? token = await storage.read(key: 'token');
    String? userId = await storage.read(key: 'userId');
    DateTime nowLocal = new DateTime.now();
    DateTime now = new DateTime.now().subtract(Duration(hours: 7));

    if (now.day == nowLocal.day) {
      now = now.subtract(Duration(days: 1));
    }

    var dateFormatted = now.toIso8601String();

    var startDateToday =
        dateFormatted.toString().split('T')[0] + 'T14:00:00%2B00:00';

    DateTime threeDay = new DateTime.now()
        .subtract(Duration(hours: 7))
        .add(Duration(hours: 72));

    if (threeDay.hour >= 17) {
      threeDay = threeDay.add(Duration(days: 1));
    }

    var dateFormattedThreeDay = threeDay.toIso8601String();

    var endDateThreeDays =
        dateFormattedThreeDay.toString().split('T')[0] + 'T16:59:59%2B00:00';

    var busStatus = "CONFIRMED";
    var notCarSys = "CAR_SYS";
    var queryString =
        '?bus_reserve_status_id=${busStatus}&exclude_allocated_by=${notCarSys}&start_trip_datetime=${startDateToday}&end_trip_datetime=${endDateThreeDays}&limit=0';
    var getBusInfoListUrl = Uri.parse(
        '${dotenv.env['BASE_API']}${dotenv.env['GET_BUS_JOB_INFO_LIST']}${queryString}&driver_id=${userId}');
    var res = await getHttpWithToken(getBusInfoListUrl, token);

    print("WORK COUNT WORK " + getBusInfoListUrl.toString());

    // busList = (jsonDecode(res)['resultData'] as List)
    //     .map((i) => ResultDatum.fromJson(i))
    //     .toList();

    // var workCountConverted = busList.length;

    // print("WORK COUNT WORK " + jsonDecode(res)['rowCount'].toString());

    setState(() {
      workCounts = jsonDecode(res)['rowCount'].toString() ?? "0";
    });
  }

  _goNotificationList(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationScreen(),
        settings: RouteSettings(
          arguments: notiCountsToSend,
        ),
      ),
    ).then((value) async {
      _checkInternet();
    });
  }

  void _goProcessWork(context) {
    setState(() {
      notiCounts = "0";
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WorkList()),
    ).then((value) async {
      _checkInternet();
    });
  }

  Future<void> _getNotification() async {
    var newNotiCounts = await getNotificationsCount();
    notiCountsToSend = newNotiCounts;
    setState(() {
      notiCounts = newNotiCounts;
      /*      notiCounts = "100"; */
    });
  }

  void _checkInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      isConnect = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${dotenv.env['NO_INTERNET_CONNECTION']}')),
      );
    } //
    else {
      await _getProfileStorage();
      await _getNotification();

      callAdminNumber = await _getAdminNumber();

      FirebaseMessaging.instance.getToken().then(
        (token) {
          setToken(token!);
        },
      );
      _tokenStream = FirebaseMessaging.instance.onTokenRefresh;
      _tokenStream?.listen(setToken);

      await _getWorkCounts();
    }
  }

  Future<String> _getAdminNumber() async {
    try {
      final storage = new FlutterSecureStorage();
      String? token = await storage.read(key: 'token');
      String? userId = await storage.read(key: 'userId');

      var getAdminNumberUrl = Uri.parse(
          '${dotenv.env['BASE_API']}${dotenv.env['GET_APP_ADMIN_NUMBER']}');

      var adminNumberRes = await getHttpWithToken(getAdminNumberUrl, token);

      print(adminNumberRes);

      var adminNumberFomated = jsonDecode(adminNumberRes);
      adminNumberFomated = adminNumberFomated['resultData']['value'];

      return adminNumberFomated;
    } catch (e) {
      return '';
    }
  }

  void setVersion() {
    setState(() {
      version = 'V ${dotenv.env['CURRENT_VER']}';
    });
  }

  Future<void> _sendNotiToken(notiToken) async {
    try {
      final storage = new FlutterSecureStorage();
      String? token = await storage.read(key: 'token');
      String? userId = await storage.read(key: 'userId');
      var queryString = "?user_id=${userId}";
      var getDeviceTokenUrl = Uri.parse(
          '${dotenv.env['BASE_API']}${dotenv.env['GET_ALL_DEVICE_TOKEN']}${queryString}');

      var getDeviceTokenRes = await getHttpWithToken(getDeviceTokenUrl, token);

      setState(() {
        deviceTokenArr = (jsonDecode(getDeviceTokenRes)['resultData'] as List)
            .map((i) => DeviceTokenArray.fromJson(i))
            .toList();
      });

      var contain =
          deviceTokenArr!.where((element) => element.deviceToken == notiToken);
      if (contain.isEmpty) {
        var tokenDeviceBody = {"user_id": userId, "device_token": notiToken};
        var postDeviceTokenUrl = Uri.parse(
            '${dotenv.env['BASE_API']}${dotenv.env['CREATE_DEVICE_TOKEN']}');
        var res =
            await postHttpWithToken(postDeviceTokenUrl, token, tokenDeviceBody);
        await storage.write(key: 'deviceToken', value: notiToken);
      } else {}
    } catch (e) {}
  }

  void _goHistory(context) {
    setState(() {
      notiCounts = "0";
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => History()),
    ).then((value) async {
      _checkInternet();
    });
  }

  /////////////////////////////// PROFILEBAR ///////////////////////////////////

  Row _wigetProfilebar() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    _openBottomSheet();
                  },
                  child: CircleAvatar(
                    radius: 23.0,
                    backgroundImage: isConnect
                        ? haveImage
                            ? NetworkImage(profileUrl ?? "")
                                as ImageProvider<Object> // Explicit cast
                            : AssetImage(
                                'assets/images/user.png') // Explicit cast
                        : AssetImage('assets/images/user.png'), // Explicit cast
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          /*    Text(
                        user?.resultData?.firstnameTh ?? "",
                        style: profileNameStyle,
                      ), */

                          Text(
                            firstName ?? "",
                            style: profileNameStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            lastName ?? "",
                            style: profileNameStyle,
                            overflow: TextOverflow.ellipsis,
                          )
                        ],
                      ),
                      SizedBox(
                        height: 1,
                      ),
                      /* Text(
                    "แผนก: ${user?.resultData?.empInfo?.empDepartmentInfo?.empDepartmentNameTh ?? ""}",
                    style: profileNameStyle,
                  ) */
                      Text(
                        "${department ?? ""}",
                        style: profileNameStyle,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          Row(
            children: [
              notiCounts != "0"
                  ? GestureDetector(
                      onTap: () {
                        _deleteNotification();
                        _goNotificationList(context);
                      },
                      child: badges.Badge(
                        position: BadgePosition.topEnd(top: -5, end: -6),
                        toAnimate: false,
                        shape: BadgeShape.circle,
                        badgeColor: Color.fromRGBO(255, 0, 0, 1),
                        borderRadius: BorderRadius.circular(8),
                        badgeContent: Container(
                          alignment: Alignment.center,
                          child: Text(
                            int.parse(notiCounts) > 99
                                ? '99+'
                                : '${notiCounts}',
                            style: TextStyle(color: Colors.white, fontSize: 8),
                          ),
                        ),
                        child: Icon(
                          Icons.add_alert,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: () {
                        _deleteNotification();
                        _goNotificationList(context);
                      },
                      child: Icon(
                        Icons.add_alert,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
              SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  _goSettingScreen(context);
                },
                child: Icon(
                  Icons.settings,
                  color: Colors.white,
                  size: 35,
                ),
              )
            ],
          ),
        ]);
  }

  Future<void> _getProfileStorage() async {
    final storage = new FlutterSecureStorage();
    var firstNameTh = await storage.read(key: 'firstName');
    var lastNameTh = await storage.read(key: 'lastName');
    var profileUrlTh = await storage.read(key: 'profileUrl');
    var departmentTh = await storage.read(key: 'department');

    if (profileUrlTh == null || profileUrlTh == '') {
      setState(() {
        firstName = firstNameTh;
        lastName = lastNameTh;
        department = departmentTh;
        haveImage = false;
      });
    } else {
      setState(() {
        firstName = firstNameTh;
        lastName = lastNameTh;
        department = departmentTh;

        if (profileUrlTh != null || profileUrlTh != '') {
          haveImage = true;
          profileUrl = /* dotenv.env['BASE_URL_PROFILE'] + */ profileUrlTh;
        } else {
          haveImage = false;
          profileUrl = "";
        }
      });
    }
  }

  void _goSettingScreen(context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingScreen()),
    );
  }

  void _openBottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return _bottomSheet();
        });
  }

  Column _bottomSheet() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          leading: new Icon(Icons.photo),
          title: new Text('เลือกรูปภาพ'),
          onTap: () {
            Navigator.pop(context);
            _pickImage(ImageSource.gallery);
          },
        ),
        ListTile(
          leading: new Icon(Icons.camera_alt),
          title: new Text('ถ่ายรูป'),
          onTap: () {
            Navigator.pop(context);
            _pickImage(ImageSource.camera);
          },
        ),
        ListTile(
          leading: new Icon(Icons.cancel),
          title: new Text('ยกเลิก'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
/* 
  void _pickImageGallery() async {
    try {
      final XFile photo = await _picker.pickImage(source: ImageSource.gallery);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณาอนุญาติให้เข้าถึงรูปภาพ')),
      );
    }
  } */

  void _showDialog(context) {
    showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 250),
      context: context,
      pageBuilder: (_, __, ___) {
        return CallDialogBox(callAdminNumber);
      },
      /*  transitionBuilder: (_, anim, __, child) {
      return SlideTransition(
        position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
        child: child,
      );
    }, */
    );
  }

  void _pickImage(src) async {
    final storage = new FlutterSecureStorage();
    String? token = await storage.read(key: 'token');

    try {
      final XFile? photo =
          await _picker.pickImage(source: src, maxWidth: 700, maxHeight: 1200);
      if (photo == null) {
        return;
      }
      Map<String, String> headers = {HttpHeaders.authorizationHeader: token!};
      Uri uri = Uri.parse(
          '${dotenv.env['BASE_API']}${dotenv.env['POST_IMAGE_USER']}');
      httpp.MultipartRequest request = httpp.MultipartRequest('POST', uri);

      request.files.add(await httpp.MultipartFile.fromPath(
        'file',
        photo.path,
      ));

      request.headers.addAll(headers);

      httpp.StreamedResponse response = await request.send();
      var responseImageUpload = await httpp.Response.fromStream(response);

      Map<String, dynamic> uploadImageObjRes =
          jsonDecode(responseImageUpload.body);

      var imagePath = uploadImageObjRes['resultData']['location'];

      //////////////////////// UPDATE USER //////////////////////////

      var meUrl = Uri.parse(
          '${dotenv.env['BASE_API']}${dotenv.env['GET_USER_BY_ME_PATH']}');

      var res = await patchHttpWithToken(
          meUrl, token, {"image_profile_file": imagePath.toString()});

      ///////////////////////////////////////////////////////////////
      setState(() {
        profileUrl = /* dotenv.env['BASE_URL_PROFILE'] +  */ imagePath;
      });

      await storage.write(key: 'profileUrl', value: imagePath);
    } catch (e) {
      print("RESPONSE WITH HTTP " + e.toString());
      if (e.toString() ==
          "PlatformException(camera_access_denied, The user did not allow camera access., null, null)") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('กรุณาอนุญาติการใช้กล้อง')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง')),
        );
      }
    }
  }
}

void _openCallDialog(context) {}

Future<void> _makePhoneCall(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
