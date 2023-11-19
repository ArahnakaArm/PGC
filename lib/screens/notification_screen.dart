import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pgc/responseModel/notificationList.dart';
import 'package:pgc/services/http/getHttpWithToken.dart';
import 'package:pgc/services/http/putHttpWithToken.dart';
import 'package:pgc/widgets/background.dart';
import 'package:pgc/widgets/commonloading.dart';
import 'package:pgc/widgets/dialogbox/loadingDialogBox.dart';
import 'package:pgc/widgets/nointernetbackground.dart';
import 'package:pgc/widgets/notfoundbackground.dart';
import 'package:pgc/utilities/constants.dart';
import 'package:pgc/services/utils/common.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with WidgetsBindingObserver {
  bool isHaveCurrentWork = false;
  var isLoading = true;
  var isEmpty = false;
  bool isConnent = true;
  List<ResultNotificationList> notificationList = [];
  List<ResultNotificationList> notificationListUnread = [];
  var notificationCounts = "0";

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        notificationCounts = ModalRoute.of(context)!.settings.arguments == null
            ? "0"
            : ModalRoute.of(context)?.settings.arguments as String;
        print(notificationCounts);
      });

      _checkInternet();
      /*  _getBusJobPoiInfo(passedData.busJobPoiId); */
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('object');
      /* _getBusInfoList(); */
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
              margin: EdgeInsets.only(left: 20.0, right: 20.0, top: 20),
              height: double.infinity,
              width: double.infinity,
              decoration: backgroundWithBorderDecorationStyle,
              child: _notificationList())
        ],
      ),
    ));
  }

  Future<void> _getNotificationList() async {
    final storage = new FlutterSecureStorage();
    String? token = await storage.read(key: 'token');
    String? userId = await storage.read(key: 'userId');

    var queryString = '?receiver_id=${userId}&offset=0&limit=10';
    var getNotificationListUrl = Uri.parse(
        '${dotenv.env['BASE_API']}${dotenv.env['GET_NOTIFICATION']}${queryString}');

    try {
      var res = await getHttpWithToken(getNotificationListUrl, token);

      String resultCode = (jsonDecode(res)['resultCode']);

      if (resultCode == "50000") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ไม่สามารถโหลดข้อมูลได้')),
        );
        isLoading = false;
      } else {
        setState(() {
          notificationList = (jsonDecode(res)['resultData'] as List)
              .map((i) => ResultNotificationList.fromJson(i))
              .toList();

          /* busList = []; */
          isLoading = false;
          if (notificationList.length == 0) {
            isEmpty = true;
          }
        });
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${dotenv.env['NO_INTERNET_CONNECTION']}')),
      );
      setState(() {
        isLoading = false;
        isEmpty = true;
      });
    }
  }

  Future<void> _doUpdateNotiList() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
            onWillPop: () {
              return Future.value(false);
            },
            child: LoadingDialogBox());
      },
    );
    await _getNotificationListUnreadAndUpdate();

    Navigator.pop(context);
  }

  Future<void> _getNotificationListUnreadAndUpdate() async {
    final storage = new FlutterSecureStorage();
    String? token = await storage.read(key: 'token');
    String? userId = await storage.read(key: 'userId');

    var queryString = '?receiver_id=${userId}&offset=0&limit=10&is_read=false';
    var getNotificationListUrl = Uri.parse(
        '${dotenv.env['BASE_API']}${dotenv.env['GET_NOTIFICATION']}${queryString}');

    try {
      var res = await getHttpWithToken(getNotificationListUrl, token);

      String resultCode = (jsonDecode(res)['resultCode']);

      if (resultCode == "50000") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ไม่สามารถโหลดข้อมูลได้')),
        );
        isLoading = false;
      } else {
        notificationListUnread = (jsonDecode(res)['resultData'] as List)
            .map((i) => ResultNotificationList.fromJson(i))
            .toList();

        /* busList = []; */
      }
      for (int i = 0; i < notificationListUnread.length; i++) {
        try {
          var updateNotificationObj = {
            "receiver_id": notificationListUnread[i].receiverId,
            "text": notificationListUnread[i].notiText,
            "detail": notificationListUnread[i].notiDetail,
            "is_read": "true"
          };

          var putNotificationUrl = Uri.parse(
              '${dotenv.env['BASE_API']}${dotenv.env['GET_NOTIFICATION']}/${notificationListUnread[i].notificationId}');

          var res = await putHttpWithToken(
              putNotificationUrl, token, updateNotificationObj);
        } catch (e) {
          print(e);
        }
        setState(() {
          notificationList[i].isRead = "true";
        });
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${dotenv.env['NO_INTERNET_CONNECTION']}')),
      );
      setState(() {
        isLoading = false;
        isEmpty = true;
      });
    }
  }

  Container _notificationList() {
    return Container(
      padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 20),
      child: Column(children: <Widget>[
        Row(
          children: <Widget>[
            Image.asset(
              'assets/images/list.png',
              height: 20,
              width: 20,
            ),
            SizedBox(width: 10),
            Text(
              'รายการแจ้งเตือน',
              style: commonHeaderLabelStyle,
            ),
            _doingWorkButton(context)
          ],
        ),
        SizedBox(
          height: 16,
        ),
        isLoading
            ? Expanded(
                child: CircularLoading(),
              )
            : !isConnent
                ? NoInternetBackground()
                : isEmpty
                    ? NotFoundBackground()
                    : Expanded(
                        child: Padding(
                            padding: const EdgeInsets.only(left: 0, right: 0),
                            child: ListView.builder(
                                key: PageStorageKey<String>('pageOne'),
                                itemCount: notificationList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  ResultNotificationList notilist =
                                      notificationList[index];
                                  return Column(
                                    children: <Widget>[
                                      GestureDetector(
                                        onTap: () {
                                          _updateNoti(index, notilist);
                                        },
                                        child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Column(
                                              children: <Widget>[
                                                Container(
                                                    padding: EdgeInsets.only(
                                                        left: 12.0,
                                                        right: 5.0,
                                                        top: 8),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: <Widget>[
                                                        notilist.isRead ==
                                                                "true"
                                                            ? Image.asset(
                                                                'assets/images/bell.png',
                                                                height: 20,
                                                                width: 20,
                                                              )
                                                            : Image.asset(
                                                                'assets/images/bell-blue.png',
                                                                height: 20,
                                                                width: 20,
                                                              ),
                                                        SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(
                                                          '${notilist.notiText}',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Athiti',
                                                          ),
                                                        ),
                                                        Expanded(
                                                            child: Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: Text(
                                                              '${convertToAgo(notilist.createdAt.toString())}',
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Athiti',
                                                                fontSize: 12,
                                                              )),
                                                        ))
                                                      ],
                                                    )),
                                                Container(
                                                  padding: EdgeInsets.only(
                                                      left: 30.0,
                                                      right: 5.0,
                                                      top: 3),
                                                  alignment: Alignment.topLeft,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Text(
                                                          '${notilist.notiDetail}',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Athiti',
                                                              fontSize: 12)),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                )
                                              ],
                                            )),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      )
                                    ],
                                  );
                                })))
      ]),
    );
  }

  Expanded _doingWorkButton(context) {
    return Expanded(
        child: GestureDetector(
      onTap: () {
        _doUpdateNotiList();
/*       _goProgess(context); */
      },
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Color.fromRGBO(240, 173, 78, 1)),
          child: Text(
            'อ่านทั้งหมด',
            style: commonHeaderButtonDoingTextStyle,
          ),
        ),
      ),
    ));
  }

  void _checkInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        isLoading = false;
        isConnent = false;
      });
    } //
    else {
      await _getNotificationList();
    }
  }

  Future<void> _updateNoti(index, ResultNotificationList data) async {
    if (data.isRead == "false") {
      final storage = new FlutterSecureStorage();
      String? token = await storage.read(key: 'token');
      String? userId = await storage.read(key: 'userId');
      try {
        var updateNotificationObj = {
          "receiver_id": data.receiverId,
          "text": data.notiText,
          "detail": data.notiDetail,
          "is_read": "true"
        };

        var putNotificationUrl = Uri.parse(
            '${dotenv.env['BASE_API']}${dotenv.env['GET_NOTIFICATION']}/${data.notificationId}');

        var res = await putHttpWithToken(
            putNotificationUrl, token, updateNotificationObj);
        print(res);
        setState(() {
          notificationList[index].isRead = "true";
        });
      } catch (e) {
        print(e);
      }
    }
  }
}
