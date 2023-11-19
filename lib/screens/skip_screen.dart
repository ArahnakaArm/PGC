import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pgc/model/passData.dart';
import 'package:pgc/services/http/getHttpWithToken.dart';
import 'package:pgc/services/http/putHttpWithToken.dart';
import 'package:pgc/widgets/background.dart';
import 'package:pgc/widgets/backpressincontainer.dart';
import 'package:pgc/widgets/dialogbox/loadingDialogBox.dart';
import 'package:pgc/utilities/constants.dart';
import 'package:pgc/widgets/commonsmallcheckinbackground.dart';

class SkipScreen extends StatefulWidget {
  const SkipScreen({Key? key, required this.value}) : super(key: key);
  final String value;

  @override
  _SkipScreenState createState() => _SkipScreenState();
}

class _SkipScreenState extends State<SkipScreen> {
  String dropdownValue = 'ผู้โดยสารไม่มาขึ้นรถ';
  int passengerMaxCounts = 0;
  int passengerUsedCounts = 0;
  String status = '';
  PassDataModel? passedData;
  String currentBusJobPoiId = '';
  var locationName = "";
  var checkInTime = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        passedData = (ModalRoute.of(context)?.settings.arguments == null
                ? ''
                : ModalRoute.of(context)?.settings.arguments as PassDataModel)
            as PassDataModel?;

        locationName = passedData!.locationName;
        status = passedData!.status;
        passengerMaxCounts = passedData!.passengerCount;
        passengerUsedCounts = passedData!.passengerCountUsed;
        currentBusJobPoiId = passedData!.busJobPoiId;
      });
      _checkInternet(passedData!.busJobPoiId);
      /*  _getBusJobPoiInfo(passedData.busJobPoiId); */
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Stack(
        children: <Widget>[
          BackGround(),
          Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 20),
                child: BackPressInContainer(context),
              ),
              SizedBox(height: 15),
              Expanded(
                  child: Container(
                decoration: commonBackgroundStyle,
                margin: EdgeInsets.only(left: 25.0, right: 25.0, bottom: 20.0),
                child: Container(
                  child: Column(
                    children: <Widget>[
                      CommonSmallCheckInBackground(context, locationName,
                          passengerMaxCounts, passengerUsedCounts),
                      SizedBox(
                        height: 40,
                      ),
                      Text(
                        'กรณีต้องการข้ามจุดรับ-ส่ง',
                        style: checkInReminderTextStyle,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'โปรดระบุเหตุผล : ',
                        style: checkInReminderTextStyle,
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      DropdownButton<String>(
                        value: dropdownValue,
                        icon: const Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        style: skipDropdownTextStyle,
                        underline: Container(
                          height: 2,
                          color: Color.fromRGBO(51, 154, 223, 1),
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownValue = newValue!;
                          });
                        },
                        items: <String>[
                          'ผู้โดยสารไม่มาขึ้นรถ',
                          'เจ้าหน้าที่ขนส่งยกเลิก',
                          'ไม่สามารถเข้าจอดได้'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Expanded(
                          child: Align(
                        alignment: Alignment.bottomCenter,
                        child: GestureDetector(
                          onTap: () async {
                            _updateJobPoiSkipStatus(
                                currentBusJobPoiId, dropdownValue.toString());
                          },
                          child: Container(
                            height: 40,
                            margin: EdgeInsets.only(
                                left: 20.0, right: 20.0, bottom: 20.0),
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(92, 184, 92, 1)),
                            child: Center(
                              child: Text(
                                'ยืนยันการข้ามงาน',
                                style: confirmFinishJobButtonTextStyle,
                              ),
                            ),
                          ),
                        ),
                      ))
                    ],
                  ),
                ),
              ))
            ],
          ),
        ],
      ),
    ));
  }

  void _checkInternet(busJobPoiId) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${dotenv.env['NO_INTERNET_CONNECTION']}')),
      );
    } //
    else {
      await _getBusJobPoiInfo(busJobPoiId);
    }
  }

  Future<void> _getBusJobPoiInfo(busJobPoiId) async {}

/*   GestureDetector _checkInButton(context, passedData) {
    return GestureDetector(
      onTap: () async {
        await _goScanAndList(context, passedData);
      },
      child: Container(
        width: 100,
        height: 25,
        decoration: BoxDecoration(color: Color.fromRGBO(51, 154, 223, 1)),
        child: Center(
            child: Text(
          'Checkin',
          style: checkInButtonTextStyle,
        )),
      ),
    );
  }
 */
  void _backPress(context) {
    Navigator.pop(context);
  }

/*   Future<void> _goScanAndList(context, PassDataModel passedData) async {
    await _updateJobPoiStatus(passedData.busJobPoiId);
  } */

  Future<void> _updateJobPoiSkipStatus(busJobPoiId, String skipReason) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return LoadingDialogBox();
      },
    );
    ///////// GET BUSJOBPOI ID //////////
    final storage = new FlutterSecureStorage();
    String? token = await storage.read(key: 'token');
    String? userId = await storage.read(key: 'userId');
    try {
      var getBusPoiUrl = Uri.parse(
          '${dotenv.env['BASE_API']}${dotenv.env['GET_BUS_JOB_POI']}/${busJobPoiId}');

      var getBusPoiRes = await getHttpWithToken(getBusPoiUrl, token);
      Map<String, dynamic> getBusPoiResObj = jsonDecode(getBusPoiRes);

      var currentBusJobInfoId =
          getBusPoiResObj['resultData']['bus_job_info_id'];
      var currentRouteInfoId = getBusPoiResObj['resultData']['route_info_id'];
      var routePoiId = getBusPoiResObj['resultData']['route_poi_info_id'];
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
        "status": "SKIP",
        "skip_reason": skipReason
      };
      var putPoiResObj =
          await putHttpWithToken(updatebusPoiUrl, token, updateBusPoiObj);
      Navigator.pop(context); //pop dial
      Navigator.pop(context);
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${dotenv.env['ERROR_TEXT']}')),
      );
    }

    ///   END UPDATE BUSJOBPOI ///////
  }

  GestureDetector _backButton(context) {
    return GestureDetector(
      onTap: () {
        _backPress(context);
      },
      child: Image.asset(
        'assets/images/backarrow.png',
        height: 25,
      ),
    );
  }
}
