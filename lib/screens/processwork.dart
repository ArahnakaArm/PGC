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
import 'package:pgc/services/http/postHttpWithToken.dart';
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
import 'package:pgc/utilities/constants.dart';
import 'package:pgc/widgets/profilebarwithdepartmentnoalarm.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ProcessWork extends StatefulWidget {
  const ProcessWork({Key? key}) : super(key: key);

  @override
  _ProcessWorkState createState() => _ProcessWorkState();
}

class _ProcessWorkState extends State<ProcessWork> {
  IO.Socket? socket;
  static const String _kLocationServicesDisabledMessage =
      'Location services are disabled.';
  static const String _kPermissionDeniedMessage = 'Permission denied.';
  static const String _kPermissionDeniedForeverMessage =
      'Permission denied forever.';
  static const String _kPermissionGrantedMessage = 'Permission granted.';

  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;

  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<ServiceStatus>? _serviceStatusStreamSubscription;
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
  var arriveNumber = 0;
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
    // TODO: implement initState
    /*   FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
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
    var aTime = 0;
    var bTime = 0;
    var cTime = 0;

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

    print("TOKEN :" + busJobInfoId);

    try {
      var nowAStart = new DateTime.now();
      var nowAStartSecond = new DateTime.now().millisecondsSinceEpoch / 1000;
      var reqASec = 0.00;
      var res = await getHttpWithToken(getBusJobInfoUrl, token);
      var nowAEndSecond = new DateTime.now().millisecondsSinceEpoch / 1000;
      reqASec = reqASec + nowAEndSecond - nowAStartSecond;
      BusJobInfo busJobInfo = busJobInfoFromJson(res);
      routeId = busJobInfo.resultData.routeInfo.routeInfoId;
      var nowAEnd = new DateTime.now();

/*  */

      setState(() {
        tripName = busJobInfo.resultData.docNo;
        originDestination = busJobInfo.resultData.routeInfo.originRouteNameTh;
        destination = busJobInfo.resultData.routeInfo.destinationRouteNameTh;
        carPlate = busJobInfo.resultData.carInfo.carPlate;
        beginMiles = busJobInfo.resultData.carMileageStart;
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

      var nowBStart = new DateTime.now();

      var nowBStartSecond = new DateTime.now().millisecondsSinceEpoch / 1000;
      var reqBSec = 0.00;

      var routeInfoRes = await getHttpWithToken(getRouteInfoUrl, token);

      var nowBEndSecond = new DateTime.now().millisecondsSinceEpoch / 1000;
      reqBSec = reqBSec + nowBEndSecond - nowBStartSecond;

      RouteInfoByPath routeInfo = routeInfoByPathFromJson(routeInfoRes);

      routePoi =
          (jsonDecode(routeInfoRes)['resultData']['route_poi_info'] as List)
              .map((i) => RoutePoiInfo.fromJson(i))
              .toList();

      Comparator<RoutePoiInfo> sortByOrder =
          (a, b) => a.order.compareTo(b.order);
      routePoi.sort(sortByOrder);
      var reqCSec = 0.00;
      var reqDSec = 0.00;
      var reqESec = 0.00;
      arriveNumber = 0;
      for (int i = 0; i < routePoi.length; i++) {
        var routePoiId = routePoi[i].routePoiInfoId;
        var queryStringPassengerCount =
            '?bus_job_info_id=${busJobInfoId}&route_poi_info_id=${routePoiId}&exclude_passenger_status_id=CANCELED&limit=0';

        var busPoiPassengerCountUrl = Uri.parse(
            '${dotenv.env['BASE_API']}${dotenv.env['GET_PASSENGER_COUNT']}${queryStringPassengerCount}');

        var nowDStartSecond = new DateTime.now().millisecondsSinceEpoch / 1000;

        var busPoiPassengerCountResObj =
            await getHttpWithToken(busPoiPassengerCountUrl, token);

        var nowDEndSecond = new DateTime.now().millisecondsSinceEpoch / 1000;
        reqDSec = reqDSec + nowDEndSecond - nowDStartSecond;

        var busPoiPassengerCountRes =
            jsonDecode(busPoiPassengerCountResObj)['rowCount'] as int;

        routePoi[i].passengerCount = 0;

        if (busPoiPassengerCountRes != 0) {
          routePoi[i].passengerCount = busPoiPassengerCountRes;
        } else {
          routePoi[i].passengerCount = 0;
        }
        if (routePoi[i].passengerCount != 0) {
          var statusgUsedPassenger = "USED";
          var queryStringUsedPassenger =
              '?route_poi_info_id=${routePoiId}&passenger_status_id=${statusgUsedPassenger}&bus_job_info_id=${busJobInfoId}&limit=0';
          var getPassengerListUrl = Uri.parse(
              '${dotenv.env['BASE_API']}${dotenv.env['GET_USED_PASSENGER_LIST']}${queryStringUsedPassenger}');

          var nowEStartSecond =
              new DateTime.now().millisecondsSinceEpoch / 1000;

          var resUsedPassenger =
              await getHttpWithToken(getPassengerListUrl, token);

          var nowEEndSecond = new DateTime.now().millisecondsSinceEpoch / 1000;
          reqESec = reqESec + nowEEndSecond - nowEStartSecond;

          routePoi[i].passengerCountUsed =
              (jsonDecode(resUsedPassenger)['rowCount'] as int);
        } else {
          routePoi[i].passengerCountUsed = 0;
        }

        arriveNumber = arriveNumber + routePoi[i].passengerCountUsed;

        if (i < routePoi.length - 1 && routePoi[i].passengerCount != 0) {
          arrStatus.add(routePoi[i].status);
        } else if (i == 0 && tripType == "outbound") {
          arrStatus.add(routePoi[i].status);
        }
      }

      var nowBEnd = new DateTime.now();

      arrayOldLength = routePoi.length;

      var nowCStart = new DateTime.now();

      if (tripType == "inbound") {
        routePoi.removeWhere((item) =>
            (item.passengerCount == 0 && item.order != (routePoi.length - 1)));
      } else if (tripType == "outbound") {
        routePoi.removeWhere((item) => (item.passengerCount == 0 &&
            item.order != (routePoi.length - 1) &&
            item.order != 0));
      }
      var nowCEnd = new DateTime.now();

      var queryString =
          '?bus_job_info_id=${busJobInfoId}&route_info_id=${routeId}';

      var busPoiUrl = Uri.parse(
          '${dotenv.env['BASE_API']}${dotenv.env['GET_BUS_JOB_POI']}${queryString}');
      print("DFWFWFWFWW 1 " + busPoiUrl.toString());
      var nowCStartSecond = new DateTime.now().millisecondsSinceEpoch / 1000;

      var busPoiResObj = await getHttpWithToken(busPoiUrl, token);

      var nowCEndSecond = new DateTime.now().millisecondsSinceEpoch / 1000;
      reqCSec = reqCSec + nowCEndSecond - nowCStartSecond;

/*       BusJobInfo busJob = busJobInfoFromJson(busPoiResObj); */

      Map<String, dynamic> busPoiRes = jsonDecode(busPoiResObj);

      var busPoiArr = busPoiRes['resultData'];

      var nowDStart = new DateTime.now();
      for (int i = 0; i < busPoiArr.length; i++) {
        routePoi = routePoi.map((poi) {
          if (busPoiArr[i]['route_poi_info_id'] == poi.routePoiInfoId) {
            poi.status = busPoiArr[i]['status'];

            DateTime dt = DateTime.parse(busPoiArr[i]['checkin_datetime'])
                .add(Duration(hours: 7));
            poi.checkInTime =
                ChangeFormateDateTimeToTime(dt.toString()).toString();
          } /* else {
            poi.status = 'IDLE';
            poi.checkInTime = ChangeFormateDateTimeToTime(
                    '2022-06-05T14:53:50.000Z'.toString())
                .toString();
          } */

          return poi;
        }).toList();
      }

      for (int i = 0; i < routePoi.length; i++) {
        routePoi[i].order = i;
      }

      var nowDEnd = new DateTime.now();
      /*  routePoi[i].status = busPoiRes['resultData'][0]['status'];
      if (busPoiRes['resultData'][0]['checkin_datetime'].toString() ==
          "2001-01-01T00:00:00.000Z") {
        routePoi[i].checkInTime = "";
      } else {
        DateTime dt =
            DateTime.parse(busPoiRes['resultData'][0]['checkin_datetime'])
                .add(Duration(hours: 7));

        routePoi[i].checkInTime = ChangeFormateDateTimeToTime(dt.toString());
      }
 */
      if (arrStatus.contains("IDLE") || arrStatus.contains("CHECKED-IN")) {
        canFinishJob = false;
      } else {
        canFinishJob = true;
      }

      /*      for (int i = 0; i < routePoi.length; i++) {
        routePoi[i].order = i;
      } */

/*       FToast fToast = FToast();
      fToast.init(context);

      fToast.showToast(
          toastDuration: Duration(seconds: 30),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 1, horizontal: 10),
            decoration: BoxDecoration(
                color: Color.fromRGBO(75, 132, 241, 1),
                borderRadius: BorderRadius.circular(20)),
            child: Text(
              'A : ' +
                  nowAStart.hour.toString() +
                  ':' +
                  nowAStart.minute.toString() +
                  ':' +
                  nowAStart.second.toString() +
                  ':' +
                  nowAStart.millisecond.toString() +
                  ' - ' +
                  nowAEnd.hour.toString() +
                  ':' +
                  nowAEnd.minute.toString() +
                  ':' +
                  nowAEnd.second.toString() +
                  ':' +
                  nowAEnd.millisecond.toString() +
                  '\n' +
                  'B : ' +
                  nowBStart.hour.toString() +
                  ':' +
                  nowBStart.minute.toString() +
                  ':' +
                  nowBStart.second.toString() +
                  ':' +
                  nowBStart.millisecond.toString() +
                  ' - ' +
                  nowBEnd.hour.toString() +
                  ':' +
                  nowBEnd.minute.toString() +
                  ':' +
                  nowBEnd.second.toString() +
                  ':' +
                  nowBEnd.millisecond.toString() +
                  '\n' +
                  'C : ' +
                  nowCStart.hour.toString() +
                  ':' +
                  nowCStart.minute.toString() +
                  ':' +
                  nowCStart.second.toString() +
                  ':' +
                  nowCStart.millisecond.toString() +
                  ' - ' +
                  nowCEnd.hour.toString() +
                  ':' +
                  nowCEnd.minute.toString() +
                  ':' +
                  nowCEnd.second.toString() +
                  ':' +
                  nowCEnd.millisecond.toString() +
                  '\n' +
                  'D : ' +
                  nowDStart.hour.toString() +
                  ':' +
                  nowDStart.minute.toString() +
                  ':' +
                  nowDStart.second.toString() +
                  ':' +
                  nowDStart.millisecond.toString() +
                  ' - ' +
                  nowDEnd.hour.toString() +
                  ':' +
                  nowDEnd.minute.toString() +
                  ':' +
                  nowDEnd.second.toString() +
                  ':' +
                  nowDEnd.millisecond.toString() +
                  '\n' +
                  'Req Sec' +
                  '\n' +
                  'ReqA : ' +
                  reqASec.toString() +
                  '\n' +
                  'ReqB : ' +
                  reqBSec.toString() +
                  '\n' +
                  'ReqC : ' +
                  reqCSec.toString() +
                  '\n' +
                  'ReqD : ' +
                  reqDSec.toString() +
                  '\n' +
                  'ReqE : ' +
                  reqESec.toString(),
              style: toastTextStyle,
            ),
          ));
 */
      busJobInfoId = busJobInfoId;
      currentRouteInfoId = routeId;

      setState(() {
        routePoi = routePoi.toList();

        /*    routePoi.sort(sortByOrder); */
        isLoading = false;
        if (routePoi.length == 0) {
          isEmpty = true;
        }
        if (busPoiArr.length == 0) {
          routePoi = [];
          isEmpty = true;
        }
        if (routePoi.length != 0 && busPoiArr.length != 0) {
          isEmpty = false;
        }
      });

      await _getMaxRadius();
    } catch (e) {
      print("DFWFWFWFWW " + e.toString());
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

  Future<void> _toggleListening() async {
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
          int.parse(dotenv.env['SOCKET_INTERVAL_MINUTE']!) * 1000 * 60;
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
        socket?.connect();

        /*   busJobInfoId = "05a915ad-d8a6-4ad4-acf8-e72bc9a12b25"; */
        if (!isAuthSocket) {
          socket?.emit("auth", {"token": token});
          socket?.onConnect((data) {
            socket?.on("auth_success", (msg) {
              authResSocket = msg['code'];
              print("SOCKET: " + authResSocket.toString());
              isAuthSocket = true;

              socket?.emit("gps/pub", {
                "id": busJobInfoId,
                "data": {
                  "lng": position.longitude.toString(),
                  "lat": position.latitude.toString(),
                  "datetime": isoDate
                }
              });

              socket?.on("bus-job-info-id/${busJobInfoId}/gps-sub", (msgs) {
                print("SOCKET: " + msgs.toString());
                print("SOCKET ID: " + busJobInfoId);
              });
            });
          });
        }
        if (isAuthSocket) {
          print("SOCKET: " + "WROK " + busJobInfoId);
          socket?.emit("gps/pub", {
            "id": busJobInfoId,
            "data": {
              "lng": position.longitude.toString(),
              "lat": position.latitude.toString(),
              "datetime": isoDate
            }
          });

          socket?.on("bus-job-info-id/${busJobInfoId}/gps-sub", (msgs) {
            print("SOCKET: " + msgs.toString());
          });
        }

        socket?.onError((data) => print(data));
        socket?.onConnectError((data) => print(data));

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
      if (_positionStreamSubscription!.isPaused) {
        _positionStreamSubscription?.resume();
        statusDisplayValue = 'resumed';
      } else {
        _positionStreamSubscription?.pause();
        statusDisplayValue = 'paused';
      }
    });
  }

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
                  ? _notFoundBackgroundWithRefresh()
                  : Expanded(
                      child: Padding(
                          padding: const EdgeInsets.only(left: 0, right: 0),
                          child: ListView.builder(
                              key: PageStorageKey<String>('pageOne5'),
                              itemCount: routePoi.length,
                              itemBuilder: (BuildContext context, int index) {
                                RoutePoiInfo routePoiItem = routePoi[index];
                                if (routePoi.length != 0) {
                                  return routePoiItem == null
                                      ? Container()
                                      : Column(
                                          children: <Widget>[
                                            /*   Text(
                                              routePoiItem.status,
                                              style: commonHeaderLabelStyle,
                                            ), */
                                            /*           getBox(context, routePoiItem) */
                                            getBox(context, routePoiItem)
                                          ],
                                        );
                                }
                              })))
        ],
      ),
    ));
  }

  Widget getBox(context, RoutePoiInfo content) {
    /*  if (status == 'finished')
    return _finishedBox(context);
  else if (status == 'waiting')
    return _waitingBox(context);
  else if (status == 'todo')
    return _todoBox();
  else if (status == 'success') return _successBox(context); */

    if (content.order == 0) {
      if (content.status == 'IDLE') {
        return _todoBoxFirst(context, content);
      } else if (content.status == 'CHECKED-IN') {
        return _waitingBoxFirst(context, content);
      } else if (content.status == 'FINISHED') {
        return _finishedBoxFirst(context, content);
      } else if (content.status == 'SKIP') {
        return _skipingBoxFirst(context, content);
      } else {
        return _todoBoxFirst(context, content);
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
      } else {
        return _todoBox(context, content);
      }
    }

    /*  return _waitingBox(context, content); */
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
      await _toggleListening();
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
        socket?.close();
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
            arguments: PassDataFinishJobModel(busJobPoiId, status,
                content.locationNameTh, busJobInfoId, content.passengerCount),
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
        print("diffhhh" + diffDistance.toString());
        print("diffhhh" + maxRadius.toString());
        print("CHECK IN222 : " + status);
        if (diffDistance < maxRadius) {
          print("CHECK IN222 : " + status);
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
                      content.passengerCount,
                      content.passengerCountUsed),
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
                      content.passengerCount,
                      content.passengerCountUsed),
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
                        content.passengerCount,
                        content.passengerCountUsed),
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
                  content.passengerCount,
                  content.passengerCountUsed),
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
                  content.passengerCount,
                  content.passengerCountUsed),
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
    print("CHECK IN222 : " + status);
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
    String isoDate = now.subtract(Duration(hours: 7)).toIso8601String() + 'Z';
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

    print("++++++++++++++++++++++++" + putPoiResObj.toString());

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
        _goCheckIn(context, content, 'finished');
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
            _processTime(content)
          ],
        ),
      ),
    );
  }

  GestureDetector _finishedBoxLast(context, RoutePoiInfo content) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _goCheckIn(context, content, 'finished');
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
            _processTime(content)
          ],
        ),
      ),
    );
  }

  GestureDetector _finishedBox(context, RoutePoiInfo content) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _goCheckIn(context, content, 'finished');
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
            _processTime(content)
          ],
        ),
      ),
    );
  }

  GestureDetector _waitingBoxFirst(context, RoutePoiInfo content) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _goCheckIn(context, content, 'non-success');
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
            _processTime(content)
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
        _goCheckIn(context, content, 'non-success');
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
            _processTime(content)
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
        _goCheckIn(context, content, 'todo');
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
            _processTime(content)
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
          _processTime(content)
        ],
      ),
    );
  }

  GestureDetector _todoBox(context, RoutePoiInfo content) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _goCheckIn(context, content, 'non-success');
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
            _processTime(content)
          ],
        ),
      ),
    );
  }

  GestureDetector _successBox(context, RoutePoiInfo content) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _goCheckIn(context, content, 'success');
      },
      child: Container(
        height: 70,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              children: <Widget>[
                _verticleLine(),
                _circleImage(10.0, 10.0, 'assets/images/flag.png', Colors.red),
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

  Container _processTime(content) {
    print("CHECK IN222 : " + content.status);
    return Container(
      padding: EdgeInsets.only(top: 16),
      child: Text(
        content.status != "IDLE" ? 'Checkin: ${content.checkInTime}' : "",
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

  Container _notFoundBackgroundWithRefresh() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
      child: Center(
        child: Column(
          children: <Widget>[
            Image.asset(
              'assets/images/not-found.png',
              height: 175,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'ไม่พบข้อมูล',
              style: notFoundText,
            ),
            SizedBox(
              height: 10,
            ),
            Container(
                child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      await _retryPostBusPoi();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(240, 173, 78, 1),
                          borderRadius: BorderRadius.circular(8)),
                      padding: EdgeInsets.only(left: 7, right: 7, bottom: 1.5),
                      child: Text(
                        "ลองใหม่อีกครั้ง",
                        style: statusBarTextStyle,
                      ),
                    )))
          ],
        ),
      ),
    );
  }

  Future<void> _retryPostBusPoi() async {
    final storage = new FlutterSecureStorage();
    String? token = await storage.read(key: 'token');
    var postBusJobPoiUrl = Uri.parse(
        '${dotenv.env['BASE_API']}${dotenv.env['POST_BUS_JOB_POI']}/${busJobInfoId}/${routeId}');
    DateTime now = new DateTime.now();
    String isoDate = '0001-01-01T00:00:00.000' + 'Z';
    var array = [];
    var postBusJobPoiRes = await postHttpWithToken(postBusJobPoiUrl, token, {});

    var responseCode = jsonDecode(postBusJobPoiRes)['resultCode'];
    print("WWQDASDASD : " + postBusJobPoiUrl.toString());
    await _getBusJobInfo();
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
