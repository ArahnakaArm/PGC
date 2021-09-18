import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:pgc/responseModel/busRef.dart';
import 'package:pgc/responseModel/buslistinfo.dart';
import 'package:pgc/responseModel/routeInfo.dart';
import 'package:pgc/screens/processwork.dart';
import 'package:pgc/services/http/getHttpWithToken.dart';
import 'package:pgc/services/http/postHttpWithToken.dart';
import 'package:pgc/services/http/putHttpWithToken.dart';
import 'package:pgc/services/utils/currentLocation.dart';
import 'package:pgc/widgets/background.dart';
import 'package:pgc/widgets/commonloading.dart';
import 'package:pgc/widgets/dialogbox/confirmWorkDialogBox.dart';
import 'package:pgc/widgets/dialogbox/loadingDialogBox.dart';
import 'package:pgc/widgets/nointernetbackground.dart';
import 'package:pgc/widgets/notfoundbackground.dart';
import 'package:pgc/widgets/profilebar.dart';
import 'package:pgc/widgets/profilebarwithdepartment.dart';
import 'package:pgc/utilities/constants.dart';
import 'package:pgc/model/histories.dart';
import 'package:pgc/widgets/profilebarwithdepartmentnoalarm.dart';
import 'package:pgc/widgets/tabbutton.dart';
import 'package:pgc/services/utils/common.dart';

class WorkList extends StatefulWidget {
  @override
  _WorkListState createState() => _WorkListState();
}

class _WorkListState extends State<WorkList> with WidgetsBindingObserver {
  int _selectedPage = 0;
  PageController _pageController;
  BusRef busRef;
  List<ResultDatum> busCurrentList = [];
  BusListInfo busListRes;
  List<ResultDatum> busList = [];
  bool isHaveCurrentWork = false;
  var isLoading = true;
  var isEmpty = false;

  bool isConnent = true;
  /* var notiCounts = "0"; */
  void _changePage(int pageNum) {
    setState(() {
      _selectedPage = pageNum;
      _pageController.animateToPage(pageNum,
          duration: Duration(milliseconds: 500),
          curve: Curves.fastLinearToSlowEaseIn);
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController();
    /*    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (mounted) {
        print("NOTIC FROM " + context.widget.toStringShort());
        setState(() {
          notiCounts = (int.parse(notiCounts) + 1).toString();
        });
        final storage = new FlutterSecureStorage();
        await storage.write(key: 'notiCounts', value: notiCounts);
      }
    }); */

    _checkInternet();

    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
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
            padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ProfileBarWithDepartmentNoAlarm(),
                ]),
          ),
          Container(
              margin: EdgeInsets.only(left: 20.0, right: 20.0, top: 85),
              height: double.infinity,
              width: double.infinity,
              decoration: backgroundWithBorderDecorationStyle,
              child: _newJob(context, busList))
        ],
      ),
    ));
  }

  Future<void> _getBusInfoList() async {
    final storage = new FlutterSecureStorage();
    String token = await storage.read(key: 'token');
    String userId = await storage.read(key: 'userId');
    var busStatus = "CONFIRMED";
    var queryString = '?bus_reserve_status_id=${busStatus}&driver_id=${userId}';
    var getBusInfoListUrl = Uri.parse(
        '${dotenv.env['BASE_API']}${dotenv.env['GET_BUS_JOB_INFO_LIST']}${queryString}');

    try {
      var res = await getHttpWithToken(getBusInfoListUrl, token);

      String resultCode = (jsonDecode(res)['resultCode']);

      if (resultCode == "50000") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ไม่สามารถโหลดข้อมูลได้')),
        );
        isLoading = false;
      } else {
        setState(() {
          busList = (jsonDecode(res)['resultData'] as List)
              .map((i) => ResultDatum.fromJson(i))
              .toList();

          busList = ChangeDateFormatBusInfoList(busList);
          /* busList = []; */
          isLoading = false;
          if (busList.length == 0) {
            isEmpty = true;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${dotenv.env['NO_INTERNET_CONNECTION']}')),
        );

        setState(() {
          isLoading = false;
          isEmpty = true;
        });
      }
    }
  }

  /*  void _deleteNotification() async {
    setState(() {
      notiCounts = "0";
    });
    final storage = new FlutterSecureStorage();
    await storage.write(key: 'notiCounts', value: notiCounts);
  } */

  Container _newJob(ctx, busList) {
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
              'ใบสั่งงาน',
              style: commonHeaderLabelStyle,
            ),
            _processWorkCountBox(busList.length.toString()),
            isHaveCurrentWork
                ? _doingWorkButton(ctx)
                : Container(
                    width: 0,
                    height: 0,
                  )
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
                                itemCount: busList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  ResultDatum busListItem = busList[index];
                                  return Column(
                                    children: <Widget>[
                                      GestureDetector(
                                        onTap: () {
                                          _showDialog(
                                              context,
                                              busListItem.carInfo.carPlate,
                                              busListItem.carMileageStart,
                                              busListItem.busJobInfoId,
                                              busListItem.carInfoId);
                                        },
                                        child: Container(
                                            height: 105,
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
                                                        Row(
                                                          children: <Widget>[
                                                            Image.asset(
                                                              'assets/images/clipboard.png',
                                                              height: 20,
                                                              width: 20,
                                                            ),
                                                            SizedBox(
                                                              width: 2,
                                                            ),
                                                            Text(
                                                              '${busListItem.docNo}',
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Athiti',
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Container(
                                                            width: 90,
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 3,
                                                                    right: 3,
                                                                    top: 0,
                                                                    bottom: 0),
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                                color: true
                                                                    ? Color
                                                                        .fromRGBO(
                                                                            92,
                                                                            184,
                                                                            92,
                                                                            1)
                                                                    : Color
                                                                        .fromRGBO(
                                                                            92,
                                                                            184,
                                                                            92,
                                                                            1)),
                                                            child: Center(
                                                              child: Text(
                                                                'รอให้บริการ',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 11,
                                                                  color: Colors
                                                                      .white,
                                                                  fontFamily:
                                                                      'Athiti',
                                                                ),
                                                              ),
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
                                                          busListItem.routeInfo
                                                                      .tripType ==
                                                                  "inbound"
                                                              ? '◉ รับเข้า'
                                                                  ' ${busListItem.routeInfo.originRouteNameTh}'
                                                              : '◉ รับออก'
                                                                  ' ${busListItem.routeInfo.originRouteNameTh}',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Athiti',
                                                              color: busListItem
                                                                          .routeInfo
                                                                          .tripType ==
                                                                      "inbound"
                                                                  ? Color
                                                                      .fromRGBO(
                                                                          92,
                                                                          184,
                                                                          92,
                                                                          1)
                                                                  : Color
                                                                      .fromRGBO(
                                                                          255,
                                                                          0,
                                                                          0,
                                                                          1),
                                                              fontSize: 12)),
                                                      Text(
                                                          '◉ ทะเบียนรถ: ${busListItem.carInfo.carPlate}',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Athiti',
                                                            fontSize: 12,
                                                          )),
                                                      Text(
                                                        '◉ วันที่ปฏิบัติงาน: ${busListItem.newDateFormat}',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontFamily: 'Athiti',
                                                        ),
                                                      )
                                                    ],
                                                  ),
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

  void _showDialog(context, carPlate, beginMiles, busJobId, carInfoId) async {
    var carMileEnd = 0;
    var currentWorkCounts = await _checkInProgressWorkCounts();
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${dotenv.env['NO_INTERNET_CONNECTION']}')),
      );
    } //
    else {
      if (currentWorkCounts > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('มีงานที่กำลังทำอยู่')),
        );
      } else {
        ///// GET CAR MILE ///////

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return LoadingDialogBox();
          },
        );

        final storage = new FlutterSecureStorage();
        String token = await storage.read(key: 'token');
        String userId = await storage.read(key: 'userId');
        var orderBy = "completed_at:desc";
        var limit = 1;
        var queryString =
            '?car_info_id=${carInfoId}&order_by=${orderBy}&limit=${limit}';
        var getBusInfoListUrl = Uri.parse(
            '${dotenv.env['BASE_API']}${dotenv.env['GET_BUS_JOB_INFO_LIST']}${queryString}');

        try {
          var res = await getHttpWithToken(getBusInfoListUrl, token);

          carMileEnd = (jsonDecode(res)['resultData'][0]['car_mileage_end']);

          if (carMileEnd == null) carMileEnd = 0;

          Navigator.pop(context);
        } catch (e) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${dotenv.env['NO_INTERNET_CONNECTION']}')),
          );
        }
        print("TEST NEW NUM " + carMileEnd.toString());
        print("TEST NEW NUM " + carInfoId);
        ///// END GET CAR MILE ///////

        showGeneralDialog(
          barrierLabel: "Barrier",
          barrierDismissible: true,
          barrierColor: Colors.black.withOpacity(0.5),
          transitionDuration: Duration(milliseconds: 250),
          context: context,
          pageBuilder: (_, __, ___) {
            return ConfirmWorkDialogBox(busJobId, carPlate,
                beginMiles.toString(), carMileEnd.toString());
          },
          /*    transitionBuilder: (_, anim, __, child) {
      return SlideTransition(
        position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
        child: child,
      );
    }, */
        ).then((val) async {
          print("TEST NEW " + val.toString());
          if (val != null && val != false && val != "") {
            await _updateBus(busJobId, val);
          } else {}
        });
      }
    }
  }

  Future<void> _getCurrentWork() async {
    final storage = new FlutterSecureStorage();
    String token = await storage.read(key: 'token');
    String userId = await storage.read(key: 'userId');
    var busStatus = "INPROGRESS";
    var queryString = '?bus_reserve_status_id=${busStatus}&driver_id=${userId}';
    var getBusInfoListUrl = Uri.parse(
        '${dotenv.env['BASE_API']}${dotenv.env['GET_BUS_JOB_INFO_LIST']}${queryString}');

    try {
      var res = await getHttpWithToken(getBusInfoListUrl, token);

      busCurrentList = (jsonDecode(res)['resultData'] as List)
          .map((i) => ResultDatum.fromJson(i))
          .toList();

      if (busCurrentList.length <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ไม่มีงานที่ทำอยู่ในขณะนี้')),
        );
      } else {
        print("RESPONSE WITH HTTP " + busCurrentList[0].busJobInfoId);
        /*  setState(() {
          notiCounts = "0";
        }); */
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProcessWork(),
            settings: RouteSettings(
              arguments: busCurrentList[0].busJobInfoId,
            ),
          ),
        ).then((value) {
          _checkInternet();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${dotenv.env['NO_INTERNET_CONNECTION']}')),
      );
    }
  }

  Future<int> _checkInProgressWorkCounts() async {
    final storage = new FlutterSecureStorage();
    String token = await storage.read(key: 'token');
    String userId = await storage.read(key: 'userId');
    var busStatus = "INPROGRESS";
    var queryString = '?bus_reserve_status_id=${busStatus}&driver_id=${userId}';
    var getBusInfoListUrl = Uri.parse(
        '${dotenv.env['BASE_API']}${dotenv.env['GET_BUS_JOB_INFO_LIST']}${queryString}');
    try {
      var res = await getHttpWithToken(getBusInfoListUrl, token);

      busCurrentList = (jsonDecode(res)['resultData'] as List)
          .map((i) => ResultDatum.fromJson(i))
          .toList();
      return busCurrentList.length;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${dotenv.env['NO_INTERNET_CONNECTION']}')),
      );
      return 0;
    }

    /*   var res = await getHttpWithToken(getBusInfoListUrl, token);

    busCurrentList = (jsonDecode(res)['resultData'] as List)
        .map((i) => ResultDatum.fromJson(i))
        .toList();
    return busCurrentList.length; */
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
      /*    await _getNotiCounts(); */
      await _getBusInfoList();
      var currentWorkCount = await _checkInProgressWorkCounts();
      print("currentWorkCount " + currentWorkCount.toString());

      if (currentWorkCount > 0) {
        setState(() {
          isHaveCurrentWork = true;
        });
      } else {
        setState(() {
          isHaveCurrentWork = false;
        });
      }
    }
  }

  Future<void> _updateBus(busJobId, mile) async {
    print("TEST NEW " + busJobId.toString());
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return LoadingDialogBox();
      },
    );

    final storage = new FlutterSecureStorage();
    String token = await storage.read(key: 'token');
    //////////// GET REF INFO ///////////////////
    var queryString = '?bus_job_info_id=${busJobId}';

    var busRefUrl = Uri.parse(
        '${dotenv.env['BASE_API']}${dotenv.env['GET_REF_BUS_JOB_RESERVE']}${queryString}');

    try {
      var busRefRes = await getHttpWithToken(busRefUrl, token);

      busRef = busRefFromJson(busRefRes);

      String busReserveInfoId = busRef.resultData[0].busReserveInfoId;

      var updateBusJobObj = {
        "doc_no": busRef.resultData[0].busJobInfoInfo.docNo,
        "car_mileage_start": int.parse(mile),
        "car_mileage_end":
            busRef.resultData[0].busJobInfoInfo.carMileageEnd == null
                ? 0
                : busRef.resultData[0].busJobInfoInfo.carMileageEnd,
        "destination_image_path":
            busRef.resultData[0].busJobInfoInfo.destinationImagePath == null
                ? ''
                : busRef.resultData[0].busJobInfoInfo.destinationImagePath,
        "route_info_id": busRef.resultData[0].busJobInfoInfo.routeInfoId,
        "trip_datetime":
            busRef.resultData[0].busJobInfoInfo.tripDatetime.toString(),
        "driver_id": busRef.resultData[0].busJobInfoInfo.driverId,
        "car_info_id": busRef.resultData[0].busJobInfoInfo.carInfoId,
        "number_of_seat": busRef.resultData[0].busJobInfoInfo.numberOfSeat,
        "number_of_reserved":
            busRef.resultData[0].busJobInfoInfo.numberOfReserved,
        "bus_reserve_status_id": "INPROGRESS"
      };

      /////////// END GET REF INFO /////////////////
      ///
      ///
      ///
      /////////// UPDATE BUSJOB AND BUSRESERVE /////

      var updateJobUrl = Uri.parse(
          '${dotenv.env['BASE_API']}${dotenv.env['PUT_BUS_JOB_INFO']}/${busJobId}');

      var updateJobInfo =
          await putHttpWithToken(updateJobUrl, token, updateBusJobObj);

      for (int i = 0; i < busRef.resultData.length; i++) {
        var updateReserveJobUrl = Uri.parse(
            '${dotenv.env['BASE_API']}${dotenv.env['PUT_BUS_RESERVE_INFO']}/${busRef.resultData[i].busReserveInfoId}');
        print("TEST NEW NUM " + busRef.resultData.length.toString());
        var updateBusReserveObj = {
          "doc_no": busRef.resultData[i].busReserveInfoInfo.docNo,
          "route_info_id": busRef.resultData[i].busReserveInfoInfo.routeInfoId,
          "trip_datetime":
              busRef.resultData[i].busReserveInfoInfo.tripDatetime.toString(),
          "is_normal_time":
              busRef.resultData[i].busReserveInfoInfo.isNormalTime,
          "emp_department_id":
              busRef.resultData[i].busReserveInfoInfo.empDepartmentId,
          "bus_reserve_status_id": "INPROGRESS",
          "bus_reserve_reason_text": busRef
                      .resultData[i].busReserveInfoInfo.busReserveReasonText ==
                  null
              ? ''
              : busRef.resultData[i].busReserveInfoInfo.busReserveReasonText,
          "car_mileage": int.parse(mile),
        };

        var updateReserveJob = await putHttpWithToken(
            updateReserveJobUrl, token, updateBusReserveObj);
      }

      /////////// END UPDATE BUSJOB AND BUSRESERVE /////
      ///
      ///
      ///
      /////////// GET ROUTE POI INFO ///////////////////
      var routeInfoId = busRef.resultData[0].busJobInfoInfo.routeInfoId;
      var busInfoId = busRef.resultData[0].busJobInfoId;

      var queryString = '?route_info_id=${routeInfoId}';
      var getRoutePoiUrl = Uri.parse(
          '${dotenv.env['BASE_API']}${dotenv.env['GET_ROUTE_POI_INFO']}${queryString}');

      var routePoiInfoRes = await getHttpWithToken(getRoutePoiUrl, token);

      List<RoutePoiInfo> routePoiInfoArr = [];
      routePoiInfoArr = (jsonDecode(routePoiInfoRes)['resultData'] as List)
          .map((i) => RoutePoiInfo.fromJson(i))
          .toList();

      var postBusJobPoiUrl = Uri.parse(
          '${dotenv.env['BASE_API']}${dotenv.env['POST_BUS_JOB_POI']}');
      DateTime now = new DateTime.now();
      String isoDate = '0001-01-01T00:00:00.000' + 'Z';

      for (int i = 0; i < routePoiInfoArr.length; i++) {
        var postBusJobPoiRes =
            await postHttpWithToken(postBusJobPoiUrl, token, {
          'bus_job_info_id': busInfoId,
          'route_info_id': routeInfoId,
          'checkin_datetime': isoDate,
          'route_poi_info_id': routePoiInfoArr[i].routePoiInfoId,
          'status': 'IDLE'
        });
      }
      /*     print(routePoiInfoArr);
      print(busInfoId); */

      /////////// END GET ROUTE POI INFO ///////////////////

      /*   Navigator.of(context, rootNavigator: true).pop(true); */
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${dotenv.env['NO_INTERNET_CONNECTION']}')),
      );
      /*  Navigator.of(context, rootNavigator: true).pop(false); */
    }
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProcessWork(),
        settings: RouteSettings(
          arguments: busJobId,
        ),
      ),
    ).then((value) async {
      await _checkInternet();
    });
  }

  Expanded _doingWorkButton(context) {
    return Expanded(
        child: GestureDetector(
      onTap: () {
        _getCurrentWork();
/*       _goProgess(context); */
      },
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Color.fromRGBO(240, 173, 78, 1)),
          child: Text(
            'กำลังดำเนินการ',
            style: commonHeaderButtonDoingTextStyle,
          ),
        ),
      ),
    ));
  }
}

Container _currentJob() {
  return Container(
    child: Center(
      child: Text('2'),
    ),
  );
}

Container _processWorkCountBox(numText) {
  return Container(
    margin: EdgeInsets.only(left: 5),
    padding: EdgeInsets.symmetric(horizontal: 4.0),
    decoration: BoxDecoration(
        color: Color.fromRGBO(161, 161, 161, 1),
        borderRadius: BorderRadius.circular(3)),
    child: Text(
      numText,
      style: doingWorkCountBoxTextStyle,
    ),
  );
}
