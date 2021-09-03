import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pgc/model/process.dart';
import 'package:pgc/responseModel/busJobInfo.dart';
import 'package:pgc/responseModel/routeInfo.dart';
import 'package:pgc/screens/checkin.dart';
import 'package:pgc/screens/scanandlist.dart';
import 'package:pgc/services/http/getHttpWithToken.dart';
import 'package:pgc/services/utils/common.dart';
import 'package:pgc/widgets/background.dart';

import 'package:pgc/widgets/commonloadingsmall.dart';
import 'package:pgc/widgets/notfoundbackground.dart';
import 'package:pgc/widgets/profilebarwithdepartment.dart';
import 'package:pgc/utilities/constants.dart';
import 'package:pgc/model/histories.dart';

class HistoryInfo extends StatefulWidget {
  const HistoryInfo({Key key}) : super(key: key);

  @override
  _HistoryInfoState createState() => _HistoryInfoState();
}

class _HistoryInfoState extends State<HistoryInfo> {
  String busJobInfoId = '';
/*   String busJobInfoId = '4286e0d5-0d14-4f09-b73a-1e32bb48e3c0'; */
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

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        busJobInfoId = ModalRoute.of(context).settings.arguments;
      });
    });
    // TODO: implement initState
    _checkInternet();
    _getBusJobInfo();
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

  void _checkInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${dotenv.env['NO_INTERNET_CONNECTION']}')),
      );
      setState(() {});
    } //
    else {
      await _getBusJobInfo();
    }
  }

  Future<void> _getBusJobInfo() async {
    final storage = new FlutterSecureStorage();
    String token = await storage.read(key: 'token');
    String userId = await storage.read(key: 'userId');
    var getBusJobInfoUrl = Uri.parse(
        '${dotenv.env['BASE_API']}${dotenv.env['GET_BUS_JOB_INFO']}/${busJobInfoId}');
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
    Comparator<RoutePoiInfo> sortByOrder = (a, b) => a.order.compareTo(b.order);
    routePoi.sort(sortByOrder);
    setState(() {
      routePoi = routePoi.toList();

      isLoading = false;
      if (routePoi.length == 0) {
        isEmpty = true;
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
                _statusBar('ให้บริการสำเร็จ', Color.fromRGBO(192, 192, 192, 1))
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
      return _finishedBoxFirst(context, content);
    } else if (content.order == routePoi.length - 1) {
      return _finishedBoxLast(context, content);
    } else {
      return _finishedBox(context, content);
    }

    /*  return _waitingBox(context, content); */
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

GestureDetector _finishedBox(context, content) {
  return GestureDetector(
    onTap: () {
      _goScanAndList(context, 'finished');
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
          _processTime()
        ],
      ),
    ),
  );
}

GestureDetector _finishedBoxFirst(context, content) {
  return GestureDetector(
    onTap: () {
      _goScanAndList(context, 'finished');
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
          _processTime()
        ],
      ),
    ),
  );
}

GestureDetector _finishedBoxLast(context, content) {
  return GestureDetector(
    onTap: () {
      _goScanAndList(context, 'finished');
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
              _verticleWhiteLine(),
            ],
          ),
          _processInfo(content),
          _processTime()
        ],
      ),
    ),
  );
}

GestureDetector _waitingBox(context, RoutePoiInfo content) {
  return GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () {
      _goCheckIn(context, 'non-success');
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
          _processTime()
        ],
      ),
    ),
  );
}

Container _todoBox(content) {
  return Container(
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
        _processTime()
      ],
    ),
  );
}

GestureDetector _successBox(context, content) {
  return GestureDetector(
    onTap: () {
      _goCheckIn(context, 'success');
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
          _processInfo(content),
          _processTime()
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
          'รับ 0 คน จาก 0 คน',
          style: processBoxSubHeaderTextStyle,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        )
      ],
    ),
  ));
}

Container _processTime() {
  return Container(
    padding: EdgeInsets.only(top: 16),
    child: Text(
      'Checkin: TEST',
      style: timeTextStyle,
    ),
  );
}

void _goCheckIn(context, status) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CheckIn(),
      settings: RouteSettings(
        arguments: status,
      ),
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
