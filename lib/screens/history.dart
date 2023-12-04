import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pgc/responseModel/buslistinfo.dart';
import 'package:pgc/screens/history_Info.dart';
import 'package:pgc/services/http/getHttpWithToken.dart';
import 'package:pgc/services/utils/common.dart';
import 'package:pgc/widgets/background.dart';
import 'package:pgc/widgets/commonloading.dart';
import 'package:pgc/widgets/nointernetbackground.dart';
import 'package:pgc/widgets/notfoundbackground.dart';
import 'package:pgc/utilities/constants.dart';
import 'package:pgc/widgets/profilebarwithdepartmentnoalarm.dart';

class History extends StatefulWidget {
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  BusListInfo? busListRes;
  List<ResultDatum> busList = [];
  List<ResultDatum> busListCancel = [];
  var isLoading = true;
  var isEmpty = false;
  bool isConnent = true;
  var notiCounts = "0";
  @override
  void initState() {
    _checkInternet();
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _headerWidget(
                      'assets/images/list.png', 'ประวัติงาน(10 รายการล่าสุด)'),
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
                                      padding: const EdgeInsets.only(
                                          left: 20, right: 20),
                                      child: ListView.builder(
                                          itemCount: busList.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            ResultDatum busListItem =
                                                busList[index];
                                            return Column(
                                              children: <Widget>[
                                                GestureDetector(
                                                  onTap: () {
                                                    if (busListItem
                                                            .busReserveStatusId ==
                                                        "COMPLETED") {
                                                      _goHistoryInfo(busListItem
                                                          .busJobInfoId);
                                                    }
                                                  },
                                                  child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      child: Column(
                                                        children: <Widget>[
                                                          Container(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left:
                                                                          12.0,
                                                                      right:
                                                                          5.0,
                                                                      top: 8),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: <Widget>[
                                                                  Row(
                                                                    children: <Widget>[
                                                                      Image
                                                                          .asset(
                                                                        'assets/images/clipboard.png',
                                                                        height:
                                                                            15,
                                                                        width:
                                                                            15,
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            2,
                                                                      ),
                                                                      Text(
                                                                        '${busListItem.docNo}',
                                                                        style:
                                                                            TextStyle(
                                                                          fontFamily:
                                                                              'Athiti',
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Container(
                                                                      width: 90,
                                                                      padding: const EdgeInsets.only(
                                                                          left:
                                                                              3,
                                                                          right:
                                                                              3,
                                                                          top:
                                                                              0,
                                                                          bottom:
                                                                              0),
                                                                      decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.circular(
                                                                              8),
                                                                          color: busListItem.busReserveStatusId != "COMPLETED"
                                                                              ? Colors.red
                                                                              : Color.fromRGBO(192, 192, 192, 1)),
                                                                      child: Center(
                                                                        child:
                                                                            Text(
                                                                          busListItem.busReserveStatusId == "COMPLETED"
                                                                              ? 'ให้บริการสำเร็จ'
                                                                              : 'ยกเลิก',
                                                                          style: TextStyle(
                                                                              fontFamily: 'Athiti',
                                                                              fontSize: 11,
                                                                              color: Colors.white),
                                                                        ),
                                                                      ))
                                                                ],
                                                              )),
                                                          Container(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 25.0,
                                                                    right: 5.0,
                                                                    top: 3),
                                                            alignment: Alignment
                                                                .topLeft,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: <Widget>[
                                                                Row(
                                                                  children: <Widget>[
                                                                    Text("◉",
                                                                        style:
                                                                            TextStyle(
                                                                          fontFamily:
                                                                              'Athiti',
                                                                          color: busListItem.routeInfo.tripType == "inbound"
                                                                              ? Color.fromRGBO(92, 184, 92, 1)
                                                                              : Color.fromRGBO(255, 0, 0, 1),
                                                                          fontSize:
                                                                              12,
                                                                        )),
                                                                    SizedBox(
                                                                      width: 3,
                                                                    ),
                                                                    busListItem.routeInfo.tripType ==
                                                                            "inbound"
                                                                        ? Image
                                                                            .asset(
                                                                            'assets/images/in.png',
                                                                            width:
                                                                                17,
                                                                            height:
                                                                                15,
                                                                          )
                                                                        : Image
                                                                            .asset(
                                                                            'assets/images/out.png',
                                                                            width:
                                                                                17,
                                                                            height:
                                                                                15,
                                                                          ),
                                                                    SizedBox(
                                                                      width: 3,
                                                                    ),
                                                                    Expanded(
                                                                        child: Text(
                                                                            busListItem.routeInfo.tripType == "inbound"
                                                                                ? ' ${busListItem.routeInfo.originRouteNameTh} - ${busListItem.routeInfo.destinationRouteNameTh}'
                                                                                : ' ${busListItem.routeInfo.originRouteNameTh} - ${busListItem.routeInfo.destinationRouteNameTh}',
                                                                            maxLines:
                                                                                1,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            style: TextStyle(
                                                                              fontFamily: 'Athiti',
                                                                              color: busListItem.routeInfo.tripType == "inbound" ? Color.fromRGBO(92, 184, 92, 1) : Color.fromRGBO(255, 0, 0, 1),
                                                                              fontSize: 12,
                                                                            )))
                                                                  ],
                                                                ),
                                                                Row(
                                                                  children: <Widget>[
                                                                    Text('◉',
                                                                        style:
                                                                            TextStyle(
                                                                          fontFamily:
                                                                              'Athiti',
                                                                          fontSize:
                                                                              12,
                                                                        )),
                                                                    SizedBox(
                                                                      width: 3,
                                                                    ),
                                                                    Container(
                                                                      margin: EdgeInsets
                                                                          .only(
                                                                              top: 2),
                                                                      child: Image
                                                                          .asset(
                                                                        'assets/images/car-plate.png',
                                                                        width:
                                                                            18,
                                                                        height:
                                                                            18,
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      width: 3,
                                                                    ),
                                                                    Text(
                                                                        ' ${busListItem.carInfo.carPlate}',
                                                                        style:
                                                                            TextStyle(
                                                                          fontFamily:
                                                                              'Athiti',
                                                                          fontSize:
                                                                              12,
                                                                        ))
                                                                  ],
                                                                ),
                                                                Row(
                                                                  children: <Widget>[
                                                                    Text(
                                                                      '◉',
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        fontFamily:
                                                                            'Athiti',
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      width: 3,
                                                                    ),
                                                                    Container(
                                                                      margin: EdgeInsets
                                                                          .only(
                                                                              top: 2),
                                                                      child: Image
                                                                          .asset(
                                                                        'assets/images/schedule.png',
                                                                        width:
                                                                            18,
                                                                        height:
                                                                            18,
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      width: 3,
                                                                    ),
                                                                    Expanded(
                                                                        child:
                                                                            Text(
                                                                      ' ${busListItem.newDateFormat}',
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        fontFamily:
                                                                            'Athiti',
                                                                      ),
                                                                    ))
                                                                  ],
                                                                ),
                                                                Row(
                                                                  children: <Widget>[
                                                                    Text(
                                                                      '◉',
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        fontFamily:
                                                                            'Athiti',
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      width: 3,
                                                                    ),
                                                                    Container(
                                                                      margin: EdgeInsets
                                                                          .only(
                                                                              top: 2),
                                                                      child: Image
                                                                          .asset(
                                                                        'assets/images/man.png',
                                                                        width:
                                                                            18,
                                                                        height:
                                                                            18,
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      width: 3,
                                                                    ),
                                                                    Expanded(
                                                                        child:
                                                                            Text(
                                                                      ' ${busListItem.numberOfReserved} คน',
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        fontFamily:
                                                                            'Athiti',
                                                                      ),
                                                                    ))
                                                                  ],
                                                                )
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
                ],
              )),
        ],
      ),
    ));
  }

  void _deleteNotification() async {
    setState(() {
      notiCounts = "0";
    });
    final storage = new FlutterSecureStorage();
    await storage.write(key: 'notiCounts', value: notiCounts);
  }

  Future<void> _getBusInfoList() async {
    final storage = new FlutterSecureStorage();
    String? token = await storage.read(key: 'token');
    String? userId = await storage.read(key: 'userId');
    var busStatus = "COMPLETED";

    DateTime nowLocal = new DateTime.now();
    DateTime now = new DateTime.now().subtract(Duration(hours: 7));

    if (now.day == nowLocal.day) {
      now = now.subtract(Duration(days: 1));
    }

    var dateFormatted = now.toIso8601String();

    var startDateToday =
        dateFormatted.toString().split('T')[0] + 'T14:00:00%2B00:00';

    DateTime nowEndDate = new DateTime.now().subtract(Duration(hours: 7));

    if (now.hour >= 17) {
      nowEndDate = nowEndDate.add(Duration(days: 1));
    }

    var endDateFormatted = nowEndDate.toIso8601String();

    var endDateToday =
        endDateFormatted.toString().split('T')[0] + 'T16:59:59%2B00:00';

    DateTime oneDay = new DateTime.now().subtract(Duration(hours: 7));

    if (oneDay.hour >= 17) {
      oneDay = oneDay.add(Duration(days: 1));
    }

    DateTime sevenDayAgo = new DateTime.now()
        .subtract(Duration(hours: 7))
        .subtract(Duration(hours: 168));

    if (sevenDayAgo.hour >= 17) {
      sevenDayAgo = sevenDayAgo.add(Duration(days: 1));
    }

    var dateFormattedSevenDayAgo = sevenDayAgo.toIso8601String();

    var endDateSevenDaysAgo =
        dateFormattedSevenDayAgo.toString().split('T')[0] + 'T16:59:59%2B00:00';

    var queryString =
        '?bus_reserve_status_id=${busStatus}&driver_id=${userId}&start_trip_datetime=${endDateSevenDaysAgo}&end_trip_datetime=${endDateToday}';
    var getBusInfoListUrl = Uri.parse(
        '${dotenv.env['BASE_API']}${dotenv.env['GET_BUS_JOB_INFO_LIST']}${queryString}');
    var res = await getHttpWithToken(getBusInfoListUrl, token);

    var busStatusCancel = "CANCELLED";
    var queryStringCancel =
        '?bus_reserve_status_id=${busStatusCancel}&driver_id=${userId}';
    var getBusInfoListCancelUrl = Uri.parse(
        '${dotenv.env['BASE_API']}${dotenv.env['GET_BUS_JOB_INFO_LIST']}${queryStringCancel}');
    var resCancel = await getHttpWithToken(getBusInfoListCancelUrl, token);

    busList = (jsonDecode(res)['resultData'] as List)
        .map((i) => ResultDatum.fromJson(i))
        .toList();

    busListCancel = (jsonDecode(resCancel)['resultData'] as List)
        .map((i) => ResultDatum.fromJson(i))
        .toList();
    busList = [...busList, ...busListCancel];
    setState(() {
      busList = ChangeDateFormatBusInfoList(busList);

      Comparator<ResultDatum> sortByCreatedAt =
          (b, a) => a.completedAt.compareTo(b.completedAt);
      busList.sort(sortByCreatedAt);
      /*   busList = busList.reversed.toList(); */
      /* busList = []; */
      isLoading = false;
      if (busList.length == 0) {
        isEmpty = true;
      }
    });
  }

  void _goHistoryInfo(busJobId) {
    setState(() {
      notiCounts = "0";
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryInfo(),
        settings: RouteSettings(
          arguments: busJobId,
        ),
      ),
    ).then((value) async {
      _checkInternet();
    });
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
      await _getBusInfoList();
    }
  }
}

Container _headerWidget(imagePath, headerText) {
  return Container(
      padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 20),
      child: Row(
        children: <Widget>[
          Image.asset(
            imagePath,
            height: 20,
            width: 20,
          ),
          SizedBox(width: 10),
          Text(
            headerText,
            style: commonHeaderLabelStyle,
          )
        ],
      ));
}
