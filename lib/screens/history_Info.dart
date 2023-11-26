import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pgc/model/passData.dart';
import 'package:pgc/model/passDataFinishJob.dart';
import 'package:pgc/responseModel/busJobInfo.dart';
import 'package:pgc/responseModel/busRef.dart';
import 'package:pgc/responseModel/routeInfo.dart';
import 'package:pgc/screens/confirmfinishjob.dart';
import 'package:pgc/screens/scanandlist.dart';
import 'package:pgc/screens/scanandlistoutbound.dart';
import 'package:pgc/screens/skip_screen.dart';
import 'package:pgc/services/http/getHttpWithToken.dart';
import 'package:pgc/services/http/putHttpWithToken.dart';
import 'package:pgc/services/utils/common.dart';
import 'package:pgc/widgets/background.dart';
import 'package:pgc/widgets/commonloadingsmall.dart';
import 'package:pgc/widgets/dialogbox/confirmSkipDialogBox.dart';
import 'package:pgc/widgets/dialogbox/errorEmployeeInfoDialogBox.dart';
import 'package:pgc/widgets/dialogbox/loadingDialogBox.dart';
import 'package:pgc/widgets/notfoundbackground.dart';
import 'package:pgc/utilities/constants.dart';
import 'package:pgc/widgets/profilebarwithdepartmentnoalarm.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class HistoryInfo extends StatefulWidget {
  const HistoryInfo({Key? key}) : super(key: key);

  @override
  _HistoryInfoState createState() => _HistoryInfoState();
}

class _HistoryInfoState extends State<HistoryInfo> {
  IO.Socket? socket;
  StreamSubscription<Position>? _positionStreamSubscription;
  String busJobInfoId = '';
  BusRef? busRef;
  String routeId = '';
  List<RoutePoiInfo> routePoi = [];
  var isLoading = true;
  var isEmpty = false;
  var tripName = '';
  var originDestination = '';
  var destination = "";
  var carPlate = '';
  var beginMiles = 0;
  var reserveNumber = 0;
  int arriveNumber = 0;
  var startDate = '';
  var tripType = '';
  var tripStatus = '';
  var currentBusJobInfoId = '';
  var currentRouteInfoId = '';
  var currentRoutePoiId = '';
  var currentBusReserveInfoId = '';
  bool canFinishJob = true;
  int maxRadius = 0;
  var authResSocket;
  var notiCounts = "0";
  var arrayOldLength = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        busJobInfoId = ModalRoute.of(context)!.settings.arguments as String;
      });
      print(busJobInfoId);
    });

    _checkInternet();

    super.initState();
  }

  @override
  void dispose() {
    if (_positionStreamSubscription != null) {
      _positionStreamSubscription?.cancel();
      _positionStreamSubscription = null;
    }

    // TODO: implement dispose
    super.dispose();
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _headerWidget('assets/images/list.png', 'ใบสั่งงาน'),
                  SizedBox(
                    height: 16,
                  ),
                  _workInfoBox(130.0),
                  SizedBox(
                    height: 10,
                  ),
                  _workListBox()
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

  Future<void> _getBusJobInfo() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    final storage = new FlutterSecureStorage();
    String? token = await storage.read(key: 'token');
    String? userId = await storage.read(key: 'userId');
    var getBusJobInfoUrl = Uri.parse(
        '${dotenv.env['BASE_API']}${dotenv.env['GET_BUS_JOB_INFO']}/${busJobInfoId}');
    var arrStatus = [];
    try {
      var res = await getHttpWithToken(getBusJobInfoUrl, token);

      BusJobInfo busJobInfo = busJobInfoFromJson(res);
      routeId = busJobInfo.resultData.routeInfo.routeInfoId;

      setState(() {
        tripName = busJobInfo.resultData.docNo;
        originDestination = busJobInfo.resultData.routeInfo.originRouteNameTh;
        destination = busJobInfo.resultData.routeInfo.destinationRouteNameTh;
        carPlate = busJobInfo.resultData.carInfo.carPlate;
        beginMiles = busJobInfo.resultData.carMileageStart ?? 0;
        startDate = ChangeFormatDateToTH(
            busJobInfo.resultData.tripDatetime.add(Duration(hours: 7)));
        tripType = busJobInfo.resultData.routeInfo.tripType;
        tripStatus = busJobInfo.resultData.busReserveStatusId;
        reserveNumber = busJobInfo.resultData.numberOfReserved;
      });

      //////// GET REF ///////
      /*    var queryString = '?bus_job_info_id=${busJobInfoId}';

      var busRefUrl = Uri.parse(
          '${dotenv.env['BASE_API']}${dotenv.env['GET_REF_BUS_JOB_RESERVE']}${queryString}');

      var busRefRes = await getHttpWithToken(busRefUrl, token);

      busRef = busRefFromJson(busRefRes);

      currentBusReserveInfoId = busRef.resultData[0].busReserveInfoId;
 */
      //////// END GET REF /////

      ////////// GET ROUTE ID /////////

      ///////// END GET ROUTE ID /////////
      var getRouteInfoUrl = Uri.parse(
          '${dotenv.env['BASE_API']}${dotenv.env['GET_ROUTE_INFO']}/${routeId}');

      var routeInfoRes = await getHttpWithToken(getRouteInfoUrl, token);

      RouteInfoByPath routeInfo = routeInfoByPathFromJson(routeInfoRes);

      routePoi =
          (jsonDecode(routeInfoRes)['resultData']['route_poi_info'] as List)
              .map((i) => RoutePoiInfo.fromJson(i))
              .toList();

      Comparator<RoutePoiInfo> sortByOrder =
          (a, b) => a.order.compareTo(b.order);
      routePoi.sort(sortByOrder);
      /*    routePoi.sort(sortByOrder); */
      arriveNumber = 0;
      for (int i = 0; i < routePoi.length; i++) {
        var routePoiId = routePoi[i].routePoiInfoId;
        var queryString =
            '?route_poi_info_id=${routePoiId}&bus_job_info_id=${busJobInfoId}&route_info_id=${routeId}';

        var busPoiUrl = Uri.parse(
            '${dotenv.env['BASE_API']}${dotenv.env['GET_BUS_JOB_POI']}${queryString}');

        var busPoiResObj = await getHttpWithToken(busPoiUrl, token);

        Map<String, dynamic> busPoiRes = jsonDecode(busPoiResObj);

        routePoi[i].status = busPoiRes['resultData'][0]['status'];

        if (busPoiRes['resultData'][0]['checkin_datetime'].toString() ==
            "2001-01-01T00:00:00.000Z") {
          routePoi[i].checkInTime = "";
        } else {
          DateTime dt =
              DateTime.parse(busPoiRes['resultData'][0]['checkin_datetime'])
                  .add(Duration(hours: 7));

          routePoi[i].checkInTime = ChangeFormateDateTimeToTime(dt.toString());
        }

        var queryStringPassengerCount =
            '?bus_job_info_id=${busJobInfoId}&route_poi_info_id=${routePoiId}&exclude_passenger_status_id=CANCELED';

        /*   print("+++++" + busJobInfoId);
        print("+++++" + routePoiId); */
        var busPoiPassengerCountUrl = Uri.parse(
            '${dotenv.env['BASE_API']}${dotenv.env['GET_PASSENGER_COUNT']}${queryStringPassengerCount}');

        var busPoiPassengerCountResObj =
            await getHttpWithToken(busPoiPassengerCountUrl, token);

        /*   print(
            "RESPONSE WITH HTTPssdad " + busPoiPassengerCountResObj.toString());
 */

        var busPoiPassengerCountRes =
            jsonDecode(busPoiPassengerCountResObj)['rowCount'] as int;
        routePoi[i].passengerCount = 0;
        print("RESPONSE WITH HTTPsssssCount " +
            busPoiPassengerCountRes.toString());
        if (busPoiPassengerCountRes != 0) {
          routePoi[i].passengerCount = busPoiPassengerCountRes;
        } else {
          routePoi[i].passengerCount = 0;
        }

        /*  print("RESPONSE WITH HTTPsssss " + routePoiId.toString());
        print("RESPONSE WITH HTTPsssss " + busPoiPassengerCountRes.toString()); */

        /*  print("RESPONSE WITH HTTPss " +
            busPoiPassengerCountRes['resultData'][0]['route_poi_info_count']); */
        /*  if (busPoiPassengerCountRes['resultData'].length != 0) {
          routePoi[i].passengerCount =
              busPoiPassengerCountRes['resultData'][0]['route_poi_info_count'];
        } else {
          routePoi[i].passengerCount = 0;
        }
 */
        /*    print("RESPONSE WITH HTTPss " + routePoi[i].passengerCount.toString()); */

        var statusgUsedPassenger = "USED";
        var queryStringUsedPassenger =
            '?route_poi_info_id=${routePoiId}&passenger_status_id=${statusgUsedPassenger}&bus_job_info_id=${busJobInfoId}';
        var getPassengerListUrl = Uri.parse(
            '${dotenv.env['BASE_API']}${dotenv.env['GET_USED_PASSENGER_LIST']}${queryStringUsedPassenger}');

        var resUsedPassenger =
            await getHttpWithToken(getPassengerListUrl, token);

        routePoi[i].passengerCountUsed =
            (jsonDecode(resUsedPassenger)['rowCount'] as int);

        arriveNumber = arriveNumber + (routePoi[i].passengerCountUsed ?? 0);

        print(
            "RESPONSE WITH HTTP " + routePoi[i].passengerCountUsed.toString());
        print("RESPONSE WITH HTTP " + routePoiId.toString());
        print("RESPONSE WITH HTTP " + busJobInfoId.toString());
        if (i < routePoi.length - 1 && routePoi[i].passengerCount != 0) {
          arrStatus.add(routePoi[i].status);
          /*  if (routePoi[i].status != "FINISHED") {
            canFinishJob = false;
          }

          print("CHECK CAN FINISH " + routePoi[i].status.toString());
          print("CHECK CAN FINISH " + canFinishJob.toString()); */
        } else if (i == 0 && tripType == "outbound") {
          arrStatus.add(routePoi[i].status);
        }

        print("DDASDADASDASD " + routePoi[i].order.toString());
      }

      arrayOldLength = routePoi.length;

      if (tripType == "inbound") {
        routePoi.removeWhere((item) =>
            (item.passengerCount == 0 && item.order != (routePoi.length - 1)));
      } else if (tripType == "outbound") {
        routePoi.removeWhere((item) => (item.passengerCount == 0 &&
            item.order != (routePoi.length - 1) &&
            item.order != 0));
      }

      if (arrStatus.contains("IDLE") || arrStatus.contains("CHECKED-IN")) {
        print("CHECK CAN FINISH " + "CANNOT");
        canFinishJob = false;
      } else {
        print("CHECK CAN FINISH " + "CAN");
        canFinishJob = true;
      }

      for (int i = 0; i < routePoi.length; i++) {
        routePoi[i].order = i;
      }
      busJobInfoId = busJobInfoId;
      currentRouteInfoId = routeId;

      setState(() {
        routePoi = routePoi.toList();
        /*    routePoi.sort(sortByOrder); */
        isLoading = false;
        if (routePoi.length == 0) {
          isEmpty = true;
        }
      });
      await _getMaxRadius();
    } catch (e) {
      print("RESPONSE WITH HTTP " + e.toString());
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${dotenv.env['ERROR_TEXT']}')),
        );
      }

      isLoading = false;
      isEmpty = true;
    }
  }

/* 
  void _toggleListening() async {
    bool isAuthSocket = false;
    socket = IO.io("${dotenv.env['PCG_SOCKET']}", <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": false,
    });

    if (_positionStreamSubscription == null) {
      final storage = new FlutterSecureStorage();
      String? token = await storage.read(key: 'token');
      String? userId = await storage.read(key: 'userId');
      int socketInterval =
          int.parse(dotenv.env['SOCKET_INTERVAL_MINUTE']) * 1000 * 60;
      final positionStream =
          _geolocatorPlatform.getPositionStream(timeInterval: socketInterval);
      _positionStreamSubscription = positionStream.handleError((error) {
        _positionStreamSubscription?.cancel();
        _positionStreamSubscription = null;
      }).listen((position) async {
        print(position.latitude.toString());
        print(position.longitude.toString());
        DateTime now = new DateTime.now();
        String isoDate = now.toIso8601String() + 'Z';
        //////////// FOR TEST GEO POST  ////////////
    /*     socket.connect(); */

        /*   busJobInfoId = "05a915ad-d8a6-4ad4-acf8-e72bc9a12b25"; */
      /*   if (!isAuthSocket) {
          socket.emit("auth", {"token": token});
          socket.onConnect((data) {
            socket.on("auth_success", (msg) {
              authResSocket = msg['code'];
              print("SOCKET: " + authResSocket.toString());
              isAuthSocket = true;

              socket.emit("gps/pub", {
                "id": busJobInfoId,
                "data": {
                  "lng": position.longitude.toString(),
                  "lat": position.latitude.toString(),
                  "datetime": isoDate
                }
              });

              socket.on("bus-job-info-id/${busJobInfoId}/gps-sub", (msgs) {
                print("SOCKET: " + msgs.toString());
                print("SOCKET ID: " + busJobInfoId);
              });
            });
          });
        }
        if (isAuthSocket) {
          print("SOCKET: " + "WROK " + busJobInfoId);
          socket.emit("gps/pub", {
            "id": busJobInfoId,
            "data": {
              "lng": position.longitude.toString(),
              "lat": position.latitude.toString(),
              "datetime": isoDate
            }
          });

          socket.on("bus-job-info-id/${busJobInfoId}/gps-sub", (msgs) {
            print("SOCKET: " + msgs.toString());
          });
        }

        socket.onError((data) => print(data));
        socket.onConnectError((data) => print(data)); */

        /*  socket = IO.io("http://192.168.1.118:5000", <String, dynamic>{
          "transports": ["websocket"],
          "autoConnect": false,
        });
        socket.io.options['auth'] = {'token': 'bar'};
        socket.connect();
        socket.emit("signin", "widget.sourchat.id");
        socket.onConnect((data) {
          print("Connected");
          socket.on("signin", (msg) {
            print(msg);
          });
        });
        socket.onError((data) => print(data)); */

        /*        final storage = new FlutterSecureStorage();
        String? token = await storage.read(key: 'token');
        String? userId = await storage.read(key: 'userId');

        var busStatus = "CONFIRMED";
        var queryString = '?bus_reserve_status_id=${busStatus}';
        var getBusInfoListUrl = Uri.parse(
            '${dotenv.env['BASE_API']}${dotenv.env['GET_BUS_JOB_INFO_LIST']}${queryString}&driver_id=${userId}');
        var res = await getHttpWithToken(getBusInfoListUrl, token);
   print("POSITION STEAM  " + res); */

        //////////// END FOR TEST GEO POST  ////////////
      });
      _positionStreamSubscription?.pause();
    }

    setState(() {
      if (_positionStreamSubscription == null) {
        return;
      }

      String statusDisplayValue;
      if (_positionStreamSubscription.isPaused) {
        _positionStreamSubscription.resume();
        statusDisplayValue = 'resumed';
      } else {
        _positionStreamSubscription.pause();
        statusDisplayValue = 'paused';
      }
    });
  }
 */
  Container _workInfoBox(heigth) {
    return Container(
      height: heigth,
      padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
      margin: EdgeInsets.only(left: 20.0, right: 20.0),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Image.asset(
                'assets/images/clipboard.png',
                height: 20,
                width: 20,
              ),
              SizedBox(
                width: 7,
              ),
              Expanded(
                  child: Text(
                tripName ?? "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: jobTitleProcessWordTextStyle,
              )),
              if (tripStatus == 'INPROGRESS')
                _statusBar('กำลังให้บริการ', Color.fromRGBO(51, 154, 223, 1))
              else if (tripStatus == 'CONFIRMED')
                _statusBar('รอให้บริการ', Color.fromRGBO(92, 184, 92, 1))
              else if (tripStatus == 'COMPLETED')
                _statusBar('ให้บริการสำเร็จ', Color.fromRGBO(137, 137, 137, 1))
            ],
          ),
          Container(
            padding: EdgeInsets.only(left: 15.0, right: 10.0, top: 6),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      '•',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Athiti',
                        color: tripType == 'inbound'
                            ? Color.fromRGBO(92, 184, 92, 1)
                            : Color.fromRGBO(255, 0, 0, 1),
                        fontSize: 13,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(
                      width: 3,
                    ),
                    tripType == 'inbound'
                        ? Image.asset(
                            'assets/images/in.png',
                            width: 17,
                            height: 15,
                          )
                        : Image.asset(
                            'assets/images/out.png',
                            width: 17,
                            height: 15,
                          ),
                    SizedBox(
                      width: 3,
                    ),
                    Expanded(
                        child: Text(
                      tripType == 'inbound'
                          ? ' ${originDestination} - ${destination}' ?? ""
                          : ' ${originDestination} - ${destination}' ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Athiti',
                        color: tripType == 'inbound'
                            ? Color.fromRGBO(92, 184, 92, 1)
                            : Color.fromRGBO(255, 0, 0, 1),
                        fontSize: 13,
                        height: 1.2,
                      ),
                    ))
                  ],
                ),
                SizedBox(
                  height: 3,
                ),
                Row(
                  children: <Widget>[
                    Text('•',
                        style: workInfoTextStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    SizedBox(
                      width: 3,
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 0),
                      child: Image.asset(
                        'assets/images/car-plate.png',
                        width: 18,
                        height: 18,
                      ),
                    ),
                    SizedBox(
                      width: 3,
                    ),
                    Expanded(
                        child: Text(' ${carPlate}' ?? "",
                            style: workInfoTextStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis))
                  ],
                ),
                SizedBox(
                  height: 3,
                ),
                Row(
                  children: <Widget>[
                    Text('•',
                        style: workInfoTextStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    SizedBox(
                      width: 3,
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 2),
                      child: Image.asset(
                        'assets/images/schedule.png',
                        width: 18,
                        height: 18,
                      ),
                    ),
                    SizedBox(
                      width: 3,
                    ),
                    Expanded(
                        child: Text(' ${startDate}' ?? "",
                            style: workInfoTextStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis))
                  ],
                ),
                SizedBox(
                  height: 3,
                ),
                Row(
                  children: <Widget>[
                    Text(
                      '•',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Athiti',
                      ),
                    ),
                    SizedBox(
                      width: 3,
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 2),
                      child: Image.asset(
                        'assets/images/man.png',
                        width: 18,
                        height: 18,
                      ),
                    ),
                    SizedBox(
                      width: 3,
                    ),
                    Expanded(
                        child: Text(
                      ' ${arriveNumber}/${reserveNumber} คน',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: workInfoTextStyle,
                    ))
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Expanded _workListBox() {
    return Expanded(
        child: Container(
      padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
      margin: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: <Widget>[
          Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('เลขไมล์เริ่มต้น : ${beginMiles.toString()}'),
                Container(
                  margin: EdgeInsets.only(top: 4, left: 5),
                  child: Image.asset(
                    'assets/images/pencil.png',
                    height: 12,
                    width: 12,
                  ),
                ),
              ],
            ),
          ),
          isLoading
              ? Expanded(child: CircularLoadingSmall())
              : isEmpty
                  ? Expanded(child: NotFoundBackground())
                  : Expanded(
                      child: Padding(
                          padding: const EdgeInsets.only(left: 0, right: 0),
                          child: ListView.builder(
                              key: PageStorageKey<String>('pageOne5'),
                              itemCount: routePoi.length,
                              itemBuilder: (BuildContext context, int index) {
                                RoutePoiInfo routePoiItem = routePoi[index];
                                return Column(
                                  children: <Widget>[
                                    getBox(context, routePoiItem)
                                  ],
                                );
                              })))
        ],
      ),
    ));
  }

  Widget getBox(context, RoutePoiInfo content) {
    if (content.order == 0) {
      if (content.status == 'IDLE') {
        return _todoBoxFirst(context, content);
      } else if (content.status == 'CHECKED-IN') {
        return _waitingBoxFirst(context, content);
      } else if (content.status == 'FINISHED') {
        return _finishedBoxFirst(context, content);
      } else if (content.status == 'SKIP') {
        return _skipingBoxFirst(context, content);
      }
    } else if (content.order == routePoi.length - 1) {
      return _successBox(context, content);
    } else {
      if (content.status == 'IDLE') {
        return _todoBox(context, content);
      } else if (content.status == 'CHECKED-IN') {
        return _waitingBox(context, content);
      } else if (content.status == 'FINISHED') {
        return _finishedBox(context, content);
      } else if (content.status == 'SKIP') {
        return _skipingBox(context, content);
      }
    }

    return Container();
  }

  Future<void> _checkInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${dotenv.env['NO_INTERNET_CONNECTION']}')),
      );
    } //
    else {
      /*   _getNotiCounts(); */
/*       await _toggleListening(); */
      await _getBusJobInfo();
    }
  }

  /* void _getNotiCounts() async {
    final storage = new FlutterSecureStorage();
    String notiCountsStorage = await storage.read(key: 'notiCounts');
    print("NOTIC FROM " + notiCountsStorage);

    setState(() {
      notiCounts = notiCountsStorage;
    });
  }
 */
  Future<void> _getMaxRadius() async {
    final storage = new FlutterSecureStorage();
    String? token = await storage.read(key: 'token');
    String? userId = await storage.read(key: 'userId');

    var getMaxRadiusUrl = Uri.parse(
        '${dotenv.env['BASE_API']}${dotenv.env['GET_APP_CONFIG_RADIUS']}');

    var maxRadiusRes = await getHttpWithToken(getMaxRadiusUrl, token);

    print(maxRadiusRes);

    var maxRadiusFomated = jsonDecode(maxRadiusRes);
    maxRadiusFomated = int.parse(maxRadiusFomated['resultData']['value']);
    maxRadius = maxRadiusFomated;

    print(maxRadius.toString());
  }

  void _goCheckIn(context, RoutePoiInfo content, status) async {
    if ((!canFinishJob && content.order == routePoi.length - 1)) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ErrorEmployeeInfoDialogBox(
              "โปรดเช็คอินทุกจุดรับ-ส่งให้ครบถ้วนก่อนปิดงาน");
        },
      );
    } else if (canFinishJob && content.order == routePoi.length - 1) {
      var busJobPoiId = await _getJobPoi(content);

      if (_positionStreamSubscription != null) {
        _positionStreamSubscription?.cancel();
        _positionStreamSubscription = null;
      }

      try {
        /*   socket.close(); */
      } catch (e) {}
      //pop dialog
      setState(() {
        notiCounts = "0";
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmFinishJob(),
          settings: RouteSettings(
            arguments: PassDataFinishJobModel(
                busJobPoiId,
                status,
                content.locationNameTh,
                busJobInfoId,
                content.passengerCount ?? 0),
          ),
        ),
      ).then((value) async {
        await _checkInternet();
      });
    } else if (content.status == "IDLE") {
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
      try {
        Position pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        double diffDistance = Geolocator.distanceBetween(
            pos.latitude,
            pos.longitude,
            double.parse(content.latitude),
            double.parse(content.longitude));
        if (diffDistance < maxRadius) {
          var busJobPoiId = await _updateJobPoiStatus(content, "CHECKED-IN");
          Navigator.pop(context); //pop dialog
          setState(() {
            notiCounts = "0";
          });
          if (tripType == "inbound") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ScanAndList(),
                settings: RouteSettings(
                  arguments: PassDataModel(
                      busJobPoiId,
                      status,
                      content.locationNameTh,
                      content.passengerCount ?? 0,
                      content.passengerCountUsed ?? 0),
                ),
              ),
            ).then((value) async {
              await _checkInternet();
            });
          } else if (tripType == "outbound") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ScanAndListOutBound(),
                settings: RouteSettings(
                  arguments: PassDataModel(
                      busJobPoiId,
                      status,
                      content.locationNameTh,
                      content.passengerCount ?? 0,
                      content.passengerCountUsed ?? 0),
                ),
              ),
            ).then((value) async {
              await _checkInternet();
            });
          }
        } else {
          print(diffDistance);
          print(maxRadius);
          Navigator.pop(context);

          showGeneralDialog(
            barrierLabel: "Barrier",
            barrierDismissible: true,
            barrierColor: Colors.black.withOpacity(0.5),
            transitionDuration: Duration(milliseconds: 250),
            context: context,
            pageBuilder: (_, __, ___) {
              return ConfirmDialogBox('ไม่อยู่ในระยะที่กำหนด');
            },
          ).then((value) async {
            if (value == true) {
              var busJobPoiId = await _getJobPoi(content);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SkipScreen(
                    value: '',
                  ),
                  settings: RouteSettings(
                    arguments: PassDataModel(
                        busJobPoiId,
                        status,
                        content.locationNameTh,
                        content.passengerCount ?? 0,
                        content.passengerCountUsed ?? 0),
                  ),
                ),
              ).then((value) async {
                await _checkInternet();
              });
            } else {}
          });

          /*    print("deBugStatus " + status);
          var busJobPoiId = await _getJobPoi(content);
          Navigator.pop(context); //pop dialog
          setState(() {
            notiCounts = "0";
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CheckIn(),
              settings: RouteSettings(
                arguments: PassDataModel(
                    busJobPoiId,
                    "ManualCheckin",
                    content.locationNameTh,
                    content.passengerCount,
                    content.passengerCountUsed),
              ),
            ),
          ).then((value) async {
            await _checkInternet();
          }); */
        }
      } catch (e) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${dotenv.env['NO_PERMISSION_GPS']}')),
        );
      }
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingDialogBox();
        },
      );

      print("deBugStatus " + status);
      var busJobPoiId = await _getJobPoi(content);
      Navigator.pop(context);
      setState(() {
        notiCounts = "0";
      }); //pop dialog

      if (tripType == "inbound") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScanAndList(),
            settings: RouteSettings(
              arguments: PassDataModel(
                  busJobPoiId,
                  status,
                  content.locationNameTh,
                  content.passengerCount ?? 0,
                  content.passengerCountUsed ?? 0),
            ),
          ),
        ).then((value) async {
          await _checkInternet();
        });
      } else if (tripType == "outbound") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScanAndListOutBound(),
            settings: RouteSettings(
              arguments: PassDataModel(
                  busJobPoiId,
                  status,
                  content.locationNameTh,
                  content.passengerCount ?? 0,
                  content.passengerCountUsed ?? 0),
            ),
          ),
        ).then((value) async {
          await _checkInternet();
        });
      }
    }

/*   Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CheckIn(),
      settings: RouteSettings(
        arguments: status,
      ),
    ),
  ); */
  }

  Future<String> _updateJobPoiStatus(RoutePoiInfo content, String status,
      [String? skipReason]) async {
    ///////// GET BUSJOBPOI ID //////////
    final storage = new FlutterSecureStorage();
    String? token = await storage.read(key: 'token');
    String? userId = await storage.read(key: 'userId');
    var routePoiId = content.routePoiInfoId;
    var queryString =
        '?route_poi_info_id=${routePoiId}&bus_job_info_id=${busJobInfoId}&route_info_id=${currentRouteInfoId}';

    var getbusPoiUrl = Uri.parse(
        '${dotenv.env['BASE_API']}${dotenv.env['GET_BUS_JOB_POI']}${queryString}');

    var busPoiResObj = await getHttpWithToken(getbusPoiUrl, token);

    Map<String, dynamic> busPoiRes = jsonDecode(busPoiResObj);

    var busJobPoiId = busPoiRes['resultData'][0]['bus_job_poi_id'];

    ///////// END GET BUSJOBPOI ID //////////

    ///   UPDATE BUSJOBPOI ///////
    ///
    DateTime now = new DateTime.now();
    String isoDate = now.toIso8601String() + 'Z';
    var updatebusPoiUrl = Uri.parse(
        '${dotenv.env['BASE_API']}${dotenv.env['PUT_BUS_JOB_POI']}/${busJobPoiId}');
    var statusToUpdate = status;
    var updateBusPoiObj = {
      "bus_job_info_id": busJobInfoId,
      "route_info_id": currentRouteInfoId,
      "route_poi_info_id": routePoiId,
      "checkin_datetime": isoDate,
      "status": statusToUpdate
    };
    if (statusToUpdate == "SKIP" && skipReason != null) {
      updateBusPoiObj["skip_reason"] = skipReason;
    }

    var putPoiResObj =
        await putHttpWithToken(updatebusPoiUrl, token, updateBusPoiObj);

    ///   END UPDATE BUSJOBPOI ///////

    return busJobPoiId;
  }

  Future<String> _getJobPoi(RoutePoiInfo content) async {
    ///////// GET BUSJOBPOI ID //////////
    final storage = new FlutterSecureStorage();
    String? token = await storage.read(key: 'token');
    String? userId = await storage.read(key: 'userId');
    var routePoiId = content.routePoiInfoId;
    var queryString =
        '?route_poi_info_id=${routePoiId}&bus_job_info_id=${busJobInfoId}&route_info_id=${currentRouteInfoId}';

    var getbusPoiUrl = Uri.parse(
        '${dotenv.env['BASE_API']}${dotenv.env['GET_BUS_JOB_POI']}${queryString}');

    var busPoiResObj = await getHttpWithToken(getbusPoiUrl, token);

    Map<String, dynamic> busPoiRes = jsonDecode(busPoiResObj);

    var busJobPoiId = busPoiRes['resultData'][0]['bus_job_poi_id'];

    ///////// END GET BUSJOBPOI ID //////////

    ///   UPDATE BUSJOBPOI ///////
    ///

    ///   END UPDATE BUSJOBPOI ///////

    return busJobPoiId;
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

  Container _statusBar(text, color) {
    return Container(
      padding: EdgeInsets.only(left: 7, right: 7, bottom: 1.5),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Center(
        child: Text(
          text,
          style: statusBarTextStyle,
        ),
      ),
    );
  }

  GestureDetector _finishedBoxFirst(context, RoutePoiInfo content) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        /*   _goCheckIn(context, content, 'finished'); */
      },
      child: Container(
        height: 70,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              children: <Widget>[
                _verticleWhiteLine(),
                _circleImage(10.0, 10.0, 'assets/images/correct.png',
                    Color.fromRGBO(92, 184, 92, 1)),
                _verticleLine(),
              ],
            ),
            if (content.order == 0 && tripType == "outbound")
              _processInfoFirstOutBound(content)
            else
              _processInfo(content),
            _processTime(content.checkInTime)
          ],
        ),
      ),
    );
  }

  GestureDetector _finishedBoxLast(context, RoutePoiInfo content) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        /*     _goCheckIn(context, content, 'finished'); */
      },
      child: Container(
        height: 70,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              children: <Widget>[
                _verticleWhiteLine(),
                _circleImage(10.0, 10.0, 'assets/images/correct.png',
                    Color.fromRGBO(92, 184, 92, 1)),
                _verticleLine()
              ],
            ),
            _processInfo(content),
            _processTime(content.checkInTime)
          ],
        ),
      ),
    );
  }

  GestureDetector _finishedBox(context, RoutePoiInfo content) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        /*       _goCheckIn(context, content, 'finished'); */
      },
      child: Container(
        height: 70,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              children: <Widget>[
                _verticleLine(),
                _circleImage(10.0, 10.0, 'assets/images/correct.png',
                    Color.fromRGBO(92, 184, 92, 1)),
                _verticleLine()
              ],
            ),
            _processInfo(content),
            _processTime(content.checkInTime)
          ],
        ),
      ),
    );
  }

  GestureDetector _waitingBoxFirst(context, RoutePoiInfo content) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
/*         _goCheckIn(context, content, 'non-success'); */
      },
      child: Container(
        height: 70,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              children: <Widget>[
                _verticleWhiteLine(),
                _circleImage(10.0, 10.0, 'assets/images/hourglass.png',
                    Color.fromRGBO(240, 173, 78, 1)),
                _verticleLine()
              ],
            ),
            if (content.order == 0 && tripType == "outbound")
              _processInfoFirstOutBound(content)
            else
              _processInfo(content),
            _processTime(content.checkInTime)
          ],
        ),
      ),
    );
  }

  GestureDetector _skipingBoxFirst(context, RoutePoiInfo content) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: Container(
        height: 70,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              children: <Widget>[
                _verticleWhiteLine(),
                _circleImage(9.0, 9.0, 'assets/images/skip.png',
                    Color.fromRGBO(92, 184, 92, 1)),
                _verticleLine()
              ],
            ),
            _processInfo(content),
            _processSkip()
          ],
        ),
      ),
    );
  }

  GestureDetector _waitingBox(context, RoutePoiInfo content) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        /*    _goCheckIn(context, content, 'non-success'); */
      },
      child: Container(
        height: 70,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              children: <Widget>[
                _verticleLine(),
                _circleImage(10.0, 10.0, 'assets/images/hourglass.png',
                    Color.fromRGBO(240, 173, 78, 1)),
                _verticleLine()
              ],
            ),
            _processInfo(content),
            _processTime(content.checkInTime)
          ],
        ),
      ),
    );
  }

  GestureDetector _skipingBox(context, RoutePoiInfo content) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: Container(
        height: 70,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              children: <Widget>[
                _verticleLine(),
                _circleImage(9.0, 9.0, 'assets/images/skip.png',
                    Color.fromRGBO(92, 184, 92, 1)),
                _verticleLine()
              ],
            ),
            _processInfo(content),
            _processSkip()
          ],
        ),
      ),
    );
  }

  GestureDetector _todoBoxFirst(context, RoutePoiInfo content) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        /*      _goCheckIn(context, content, 'todo'); */
      },
      child: Container(
        height: 70,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              children: <Widget>[
                _verticleWhiteLine(),
                _circleImage(10.0, 10.0, 'assets/images/pin.png', Colors.red),
                _verticleLine()
              ],
            ),
            if (content.order == 0 && tripType == "outbound")
              _processInfoFirstOutBound(content)
            else
              _processInfo(content),
            _processTime(content.checkInTime)
          ],
        ),
      ),
    );
  }

  Container _todoBoxLast(context, RoutePoiInfo content) {
    return Container(
      height: 70,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            children: <Widget>[
              _verticleLine(),
              _circleImage(10.0, 10.0, 'assets/images/pin.png', Colors.red),
              _verticleWhiteLine()
            ],
          ),
          _processInfo(content),
          _processTime(content.checkInTime)
        ],
      ),
    );
  }

  GestureDetector _todoBox(context, RoutePoiInfo content) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        /*       _goCheckIn(context, content, 'non-success'); */
      },
      child: Container(
        height: 70,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              children: <Widget>[
                _verticleLine(),
                _circleImage(10.0, 10.0, 'assets/images/pin.png', Colors.red),
                _verticleLine()
              ],
            ),
            _processInfo(content),
            _processTime(content.checkInTime)
          ],
        ),
      ),
    );
  }

  GestureDetector _successBox(context, RoutePoiInfo content) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        /*   _goCheckIn(context, content, 'success'); */
      },
      child: Container(
        height: 70,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              children: <Widget>[
                _verticleLine(),
                _circleImage(10.0, 10.0, 'assets/images/flag.png',
                    Color.fromRGBO(92, 184, 92, 1)),
                _verticleWhiteLine()
              ],
            ),
            _processInfoFinish(content),
            /*    _processTime(content.checkInTime) */
          ],
        ),
      ),
    );
  }

  Container _circleImage(horizontal, verticle, imagePath, color) {
    return Container(
      width: 32,
      height: 32,
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: verticle),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Container(
        child: Image.asset(
          imagePath,
        ),
      ),
    );
  }

  Expanded _verticleLine() {
    return Expanded(
        child: Container(
            child: VerticalDivider(
      color: Colors.black,
      thickness: 3,
    )));
  }

  Expanded _verticleWhiteLine() {
    return Expanded(
        child: Container(
            child: VerticalDivider(
      color: Colors.white,
      thickness: 3,
    )));
  }

  Expanded _processInfo(RoutePoiInfo content) {
    return Expanded(
        child: Container(
      padding: EdgeInsets.only(left: 10, top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            content.locationNameTh ?? '',
            style: processBoxHeaderTextStyle,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          Text(
            tripType == 'inbound'
                ? 'รับ ${content.passengerCountUsed} คน จาก ${content.passengerCount} คน'
                : 'ส่ง ${content.passengerCount} คน',
            style: processBoxSubHeaderTextStyle,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          )
        ],
      ),
    ));
  }

  Expanded _processInfoFirstOutBound(RoutePoiInfo content) {
    return Expanded(
        child: Container(
      padding: EdgeInsets.only(left: 10, top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            content.locationNameTh ?? '',
            style: processBoxHeaderTextStyle,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          FittedBox(
            child: Text(
              'จุดเริ่มต้น คลิกเพื่อสแกน',
              style: processBoxSubHeaderTextStyle,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          )
        ],
      ),
    ));
  }

  Expanded _processInfoFinish(RoutePoiInfo content) {
    return Expanded(
        child: Container(
      padding: EdgeInsets.only(left: 10, top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            content.locationNameTh ?? '',
            style: processBoxHeaderTextStyle,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          tripType == 'outbound'
              ? Text(
                  'ส่ง ${content.passengerCount} คน',
                  style: processBoxSubHeaderTextStyle,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                )
              : Container()
        ],
      ),
    ));
  }

  Container _processTime(time) {
    return Container(
      padding: EdgeInsets.only(top: 16),
      child: Text(
        time != "" ? 'Checkin: ${time}' : "",
        style: timeTextStyle,
      ),
    );
  }

  Container _processSkip() {
    return Container(
      padding: EdgeInsets.only(top: 16),
      child: Text(
        'ข้าม',
        style: timeTextStyle,
      ),
    );
  }

  void _goScanAndList(context, status) {
    setState(() {
      notiCounts = "0";
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanAndList(),
        settings: RouteSettings(
          arguments: status,
        ),
      ),
    );
  }
}
