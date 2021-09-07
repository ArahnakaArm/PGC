import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pgc/model/passData.dart';
import 'package:pgc/model/passDataFinishJob.dart';
import 'package:pgc/model/process.dart';
import 'package:pgc/responseModel/busJobInfo.dart';
import 'package:pgc/responseModel/busPoi.dart';
import 'package:pgc/responseModel/busRef.dart';

import 'package:pgc/responseModel/routeInfo.dart';
import 'package:pgc/screens/checkin.dart';
import 'package:pgc/screens/confirmfinishjob.dart';
import 'package:pgc/screens/scanandlist.dart';
import 'package:pgc/services/http/getHttpWithToken.dart';
import 'package:pgc/services/http/putHttpWithToken.dart';
import 'package:pgc/services/utils/common.dart';
import 'package:pgc/services/utils/currentLocation.dart';
import 'package:pgc/widgets/background.dart';

import 'package:pgc/widgets/commonloadingsmall.dart';
import 'package:pgc/widgets/dialogbox/confirmCheckinDialogBox.dart';
import 'package:pgc/widgets/dialogbox/errorEmployeeInfoDialogBox.dart';
import 'package:pgc/widgets/dialogbox/loadingDialogBox.dart';
import 'package:pgc/widgets/notfoundbackground.dart';
import 'package:pgc/widgets/profilebarwithdepartment.dart';
import 'package:pgc/utilities/constants.dart';
import 'package:pgc/model/histories.dart';

class ProcessWork extends StatefulWidget {
  const ProcessWork({Key key}) : super(key: key);

  @override
  _ProcessWorkState createState() => _ProcessWorkState();
}

class _ProcessWorkState extends State<ProcessWork> {
  String busJobInfoId = '';
  BusRef busRef;
  String routeId = '';
  List<RoutePoiInfo> routePoi = [];
  var isLoading = true;
  var isEmpty = false;
  var tripName = '';
  var originDestination = '';
  var carPlate = '';
  var beginMiles = 0;
  var startDate = '';
  var tripType = '';
  var tripStatus = '';
  var currentBusJobInfoId = '';
  var currentRouteInfoId = '';
  var currentRoutePoiId = '';
  var currentBusReserveInfoId = '';
  bool canFinishJob = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        busJobInfoId = ModalRoute.of(context).settings.arguments;
      });
      print(busJobInfoId);
    });
    // TODO: implement initState
    _checkInternet();

    super.initState();
  }

  @override
  void dispose() {
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
                  ProfileBarWithDepartment(),
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
                  _workInfoBox(110.0),
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

  Future<void> _getBusJobInfo() async {
    setState(() {
      isLoading = true;
    });

    final storage = new FlutterSecureStorage();
    String token = await storage.read(key: 'token');
    String userId = await storage.read(key: 'userId');
    var getBusJobInfoUrl = Uri.parse(
        '${dotenv.env['BASE_API']}${dotenv.env['GET_BUS_JOB_INFO']}/${busJobInfoId}');

    try {
      var res = await getHttpWithToken(getBusJobInfoUrl, token);

      BusJobInfo busJobInfo = busJobInfoFromJson(res);
      routeId = busJobInfo.resultData.routeInfo.routeInfoId;

      setState(() {
        tripName = busJobInfo.resultData.docNo;
        originDestination = busJobInfo.resultData.routeInfo.originRouteNameTh;
        carPlate = busJobInfo.resultData.carInfo.carPlate;
        beginMiles = busJobInfo.resultData.carMileageStart;
        startDate = ChangeFormatDateToTH(busJobInfo.resultData.tripDatetime);
        tripType = busJobInfo.resultData.routeInfo.tripType;
        tripStatus = busJobInfo.resultData.busReserveStatusId;
      });

      //////// GET REF ///////
      var queryString = '?bus_job_info_id=${busJobInfoId}';

      var busRefUrl = Uri.parse(
          '${dotenv.env['BASE_API']}${dotenv.env['GET_REF_BUS_JOB_RESERVE']}${queryString}');

      var busRefRes = await getHttpWithToken(busRefUrl, token);

      busRef = busRefFromJson(busRefRes);

      currentBusReserveInfoId = busRef.resultData[0].busReserveInfoId;

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
      for (int i = 0; i < routePoi.length; i++) {
        var routePoiId = routePoi[i].routePoiInfoId;
        var queryString =
            '?route_poi_info_id=${routePoiId}&bus_job_info_id=${busJobInfoId}&route_info_id=${routeId}';

        var busPoiUrl = Uri.parse(
            '${dotenv.env['BASE_API']}${dotenv.env['GET_BUS_JOB_POI']}${queryString}');

        var busPoiResObj = await getHttpWithToken(busPoiUrl, token);

        Map<String, dynamic> busPoiRes = jsonDecode(busPoiResObj);

        routePoi[i].status = busPoiRes['resultData'][0]['status'];

        if (i < routePoi.length - 1) {
          if (routePoi[i].status == "FINISHED") {
            canFinishJob = true;
          } else {
            canFinishJob = false;
          }
          print("CHECK CAN FINISH" + canFinishJob.toString());
        }

        if (busPoiRes['resultData'][0]['checkin_datetime'].toString() ==
            "0001-01-01T00:00:00.000Z") {
          routePoi[i].checkInTime = "";
        } else {
          routePoi[i].checkInTime = ChangeFormateDateTimeToTime(
              busPoiRes['resultData'][0]['checkin_datetime'].toString());
        }

        var queryStringPassengerCount =
            '?bus_reserve_info_id=${currentBusReserveInfoId}&route_poi_info_id=${routePoiId}';

        var busPoiPassengerCountUrl = Uri.parse(
            '${dotenv.env['BASE_API']}${dotenv.env['GET_PASSENGER_COUNT']}${queryStringPassengerCount}');

        /*  print("RESPONSE WITH HTTP " + busPoiPassengerCountUrl.toString());
 */
        var busPoiPassengerCountResObj =
            await getHttpWithToken(busPoiPassengerCountUrl, token);

        Map<String, dynamic> busPoiPassengerCountRes =
            jsonDecode(busPoiPassengerCountResObj);

        if (busPoiPassengerCountRes['resultData'].length != 0) {
          print("RESPONSE WITH HTTP " +
              busPoiPassengerCountRes['resultData'][0]['route_poi_info_count']
                  .toString());
          routePoi[i].passengerCount = busPoiPassengerCountRes['resultData'] !=
                  []
              ? busPoiPassengerCountRes['resultData'][0]['route_poi_info_count']
              : 0;
        } else {
          routePoi[i].passengerCount = 0;
        }

        var statusgUsedPassenger = "USED";
        var queryStringUsedPassenger =
            '?route_poi_info_id=${routePoiId}&passenger_status_id=${statusgUsedPassenger}';
        var getPassengerListUrl = Uri.parse(
            '${dotenv.env['BASE_API']}${dotenv.env['GET_USED_PASSENGER_LIST']}${queryStringUsedPassenger}');

        var resUsedPassenger =
            await getHttpWithToken(getPassengerListUrl, token);

        routePoi[i].passengerCountUsed =
            (jsonDecode(resUsedPassenger)['rowCount'] as int);
      }
      currentBusJobInfoId = busJobInfoId;
      currentRouteInfoId = routeId;

      setState(() {
        routePoi = routePoi.toList();
        /*    routePoi.sort(sortByOrder); */
        isLoading = false;
        if (routePoi.length == 0) {
          isEmpty = true;
        }
      });
    } catch (e) {
      print("RESPONSE WITH HTTP " + e.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${dotenv.env['NO_INTERNET_CONNECTION']}')),
        );
      }

      isLoading = false;
      isEmpty = true;
    }
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
                    Expanded(
                        child: Text(
                      tripType == 'inbound'
                          ? '• รับเข้า ${originDestination}' ?? ""
                          : '• รับออก ${originDestination}' ?? "",
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
                    Expanded(
                        child: Text('• ทะเบียนรถ: ${carPlate}' ?? "",
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
                    Expanded(
                        child: Text('• วันที่ปฏิบัติงาน: ${startDate}' ?? "",
                            style: workInfoTextStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis))
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
      await _getBusJobInfo();
    }
  }

  void _goCheckIn(context, RoutePoiInfo content, status) async {
    if (!canFinishJob && content.order == routePoi.length - 1) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ErrorEmployeeInfoDialogBox(
              "กรุณาเช็คอินสถานที่ก่อนหน้าให้หมด");
        },
      );
    } else if (canFinishJob && content.status != "FINISHED") {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ConfirmCheckinDialogBox(content.locationNameTh);
        },
      ).then((val) async {
        if (val) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return LoadingDialogBox();
            },
          );
          print("deBugStatus " + content.status);
          if (status == "success") {
            var busJobPoiId = await _getJobPoi(content);
            Navigator.pop(context); //pop dialog
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
                      content.passengerCount),
                ),
              ),
            ).then((value) async {
              await _checkInternet();
            });
          } else if (content.status == 'IDLE' && status != "success") {
            Position pos = await GetCurrentPosition();
            double diffDistance = Geolocator.distanceBetween(
                pos.latitude,
                pos.longitude,
                double.parse(content.latitude),
                double.parse(content.longitude));
            if (diffDistance < int.parse(dotenv.env['DISTANCE_LIMIT_METER'])) {
              var busJobPoiId = await _updateJobPoiStatus(content);
              Navigator.pop(context); //pop dialog
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScanAndList(),
                  settings: RouteSettings(
                    arguments: PassDataModel(busJobPoiId, status,
                        content.locationNameTh, content.passengerCount),
                  ),
                ),
              ).then((value) async {
                await _checkInternet();
              });
            } else {
              print("deBugStatus " + status);
              var busJobPoiId = await _getJobPoi(content);
              Navigator.pop(context); //pop dialog
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CheckIn(),
                  settings: RouteSettings(
                    arguments: PassDataModel(busJobPoiId, "ManualCheckin",
                        content.locationNameTh, content.passengerCount),
                  ),
                ),
              ).then((value) async {
                await _checkInternet();
              });
            }
          } else {
            if (status == "success") {
              var busJobPoiId = await _getJobPoi(content);
              Navigator.pop(context); //pop dialog
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
                        content.passengerCount),
                  ),
                ),
              ).then((value) async {
                await _checkInternet();
              });
            } else {
              print("deBugStatus " + status);
              var busJobPoiId = await _getJobPoi(content);
              Navigator.pop(context); //pop dialog
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScanAndList(),
                  settings: RouteSettings(
                    arguments: PassDataModel(busJobPoiId, status,
                        content.locationNameTh, content.passengerCount),
                  ),
                ),
              ).then((value) async {
                await _checkInternet();
              });
            }
          }
        } else {}
      });
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingDialogBox();
        },
      );
      print("deBugStatus " + content.status);
      if (status == "success") {
        var busJobPoiId = await _getJobPoi(content);
        Navigator.pop(context); //pop dialog
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
      } else if (content.status == 'IDLE' && status != "success") {
        Position pos = await GetCurrentPosition();
        double diffDistance = Geolocator.distanceBetween(
            pos.latitude,
            pos.longitude,
            double.parse(content.latitude),
            double.parse(content.longitude));
        if (diffDistance < int.parse(dotenv.env['DISTANCE_LIMIT_METER'])) {
          var busJobPoiId = await _updateJobPoiStatus(content);
          Navigator.pop(context); //pop dialog
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScanAndList(),
              settings: RouteSettings(
                arguments: PassDataModel(busJobPoiId, status,
                    content.locationNameTh, content.passengerCount),
              ),
            ),
          ).then((value) async {
            await _checkInternet();
          });
        } else {
          print("deBugStatus " + status);
          var busJobPoiId = await _getJobPoi(content);
          Navigator.pop(context); //pop dialog
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CheckIn(),
              settings: RouteSettings(
                arguments: PassDataModel(busJobPoiId, "ManualCheckin",
                    content.locationNameTh, content.passengerCount),
              ),
            ),
          ).then((value) async {
            await _checkInternet();
          });
        }
      } else {
        if (status == "success") {
          var busJobPoiId = await _getJobPoi(content);
          Navigator.pop(context); //pop dialog
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
                    content.passengerCount),
              ),
            ),
          ).then((value) async {
            await _checkInternet();
          });
        } else {
          print("deBugStatus " + status);
          var busJobPoiId = await _getJobPoi(content);
          Navigator.pop(context); //pop dialog
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScanAndList(),
              settings: RouteSettings(
                arguments: PassDataModel(busJobPoiId, status,
                    content.locationNameTh, content.passengerCount),
              ),
            ),
          ).then((value) async {
            await _checkInternet();
          });
        }
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

  Future<String> _updateJobPoiStatus(RoutePoiInfo content) async {
    ///////// GET BUSJOBPOI ID //////////
    final storage = new FlutterSecureStorage();
    String token = await storage.read(key: 'token');
    String userId = await storage.read(key: 'userId');
    var routePoiId = content.routePoiInfoId;
    var queryString =
        '?route_poi_info_id=${routePoiId}&bus_job_info_id=${currentBusJobInfoId}&route_info_id=${currentRouteInfoId}';

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
    var updateBusPoiObj = {
      "bus_job_info_id": currentBusJobInfoId,
      "route_info_id": currentRouteInfoId,
      "route_poi_info_id": routePoiId,
      "checkin_datetime": isoDate,
      "status": "CHECKED-IN"
    };
    var putPoiResObj =
        await putHttpWithToken(updatebusPoiUrl, token, updateBusPoiObj);

    ///   END UPDATE BUSJOBPOI ///////

    return busJobPoiId;
  }

  Future<String> _getJobPoi(RoutePoiInfo content) async {
    ///////// GET BUSJOBPOI ID //////////
    final storage = new FlutterSecureStorage();
    String token = await storage.read(key: 'token');
    String userId = await storage.read(key: 'userId');
    var routePoiId = content.routePoiInfoId;
    var queryString =
        '?route_poi_info_id=${routePoiId}&bus_job_info_id=${currentBusJobInfoId}&route_info_id=${currentRouteInfoId}';

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
            _processInfo(content),
            _processTime(content.checkInTime)
          ],
        ),
      ),
    );
  }

  GestureDetector _finishedBoxLast(context, RoutePoiInfo content) {
    return GestureDetector(
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
            _processTime(content.checkInTime)
          ],
        ),
      ),
    );
  }

  GestureDetector _finishedBox(context, RoutePoiInfo content) {
    return GestureDetector(
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

  GestureDetector _todoBoxFirst(context, RoutePoiInfo content) {
    return GestureDetector(
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
            _processTime(content.checkInTime)
          ],
        ),
      ),
    );
  }

  GestureDetector _successBox(context, RoutePoiInfo content) {
    return GestureDetector(
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
            'รับ ${content.passengerCountUsed} คน จาก ${content.passengerCount} คน',
            style: processBoxSubHeaderTextStyle,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
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
        ],
      ),
    ));
  }

  Container _processTime(time) {
    return Container(
      padding: EdgeInsets.only(top: 16),
      child: Text(
        time != "00:00" ? 'Checkin: ${time}' : "",
        style: timeTextStyle,
      ),
    );
  }

  void _goScanAndList(context, status) {
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
