import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pgc/responseModel/busRef.dart';
import 'package:pgc/responseModel/routeInfo.dart';
import 'package:pgc/screens/processwork.dart';
import 'package:pgc/services/http/getHttpWithToken.dart';
import 'package:pgc/services/http/postHttpWithToken.dart';
import 'package:pgc/services/http/putHttpWithToken.dart';
import 'package:pgc/services/utils/common.dart';
import 'package:pgc/utilities/constants.dart';

class ConfirmWorkDialogBox extends StatelessWidget {
  String busJobId;
  String carPlate;
  String beginMiles;
  DateTime tripTime;
  FocusNode miles = FocusNode();
  BusRef busRef;
  List<ResultDatumBusRef> busCurrentList = [];
  String reserveId;
  String busJobDoc;
  String endMiles;
  TextEditingController milesController = new TextEditingController();
  ConfirmWorkDialogBox(this.busJobId, this.carPlate, this.beginMiles,
      this.endMiles, this.tripTime, this.busJobDoc);
  bool canPress = true;

  @override
  Widget build(BuildContext context) {
    /*  FocusScope.of(context).requestFocus(miles); */
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: EdgeInsets.zero,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            alignment: Alignment.topCenter,
            child: Container(
              width: double.infinity,
              /*  margin: EdgeInsets.only(top: 125, left: 40, right: 40), */
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 30,
                        ),
                        Text(
                          '${this.busJobDoc}',
                          style: callDialogBlueTextStyle,
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Text(
                          'วันที่: ${ChangeFormatDateToTHLocalNoTime(this.tripTime.add(Duration(hours: 7)))}',
                          style: callDialogBlackTextStyle,
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Text(
                          'เวลา: ${ChangeFormateDateTimeToTime(this.tripTime.add(Duration(hours: 7)))} น.',
                          style: callDialogBlackTextStyle,
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Text(
                          'ทะเบียนรถ: ${this.carPlate}',
                          style: callDialogBlackTextStyle,
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              'เลขไมล์เริ่มต้น: ',
                              style: callDialogBlackTextStyle,
                            ),
                            Container(
                                height: 40,
                                width: 55,
                                child: TextField(
                                  maxLines: 1,
                                  focusNode: miles,
                                  controller: milesController
                                    ..text = this.endMiles != null
                                        ? this.endMiles
                                        : 0,
                                  autofocus: true,
                                  keyboardType: TextInputType.number,
                                  decoration: new InputDecoration(
                                      border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                      hintText:
                                          "${this.endMiles != null ? this.endMiles : '0'}"),
                                )),
                            SizedBox(
                              width: 3,
                            ),
                            GestureDetector(
                              onTap: () {
                                _focusInputMiles(context);
                              },
                              child: Image.asset(
                                'assets/images/pencil.png',
                                width: 15,
                                height: 15,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: GestureDetector(
                            onTap: () {
                              Navigator.of(context, rootNavigator: true)
                                  .pop(false);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(137, 137, 137, 1),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.zero,
                                  topRight: Radius.zero,
                                  bottomLeft: Radius.circular(8),
                                  bottomRight: Radius.zero,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'ปิด',
                                  style: buttonDialogTextStyle,
                                ),
                              ),
                            )),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            _goProgess(context);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(1, 84, 155, 1),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.zero,
                                topRight: Radius.zero,
                                bottomLeft: Radius.zero,
                                bottomRight: Radius.circular(8),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'เริ่มทำงาน',
                                style: buttonDialogTextStyle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _focusInputMiles(context) {
    FocusScope.of(context).requestFocus(miles);
  }

  void _goProgess(context) async {
    Pattern pattern = r'[0-9]$';
    RegExp regex = new RegExp(pattern);
    if (milesController.text != "") {
      print("TEST NEW NUM " + milesController.text);
      if (!regex.hasMatch(milesController.text)) {
        print("TEST NEW NUM " + "DDDD");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('กรุณากรอกเฉพาะตัวเลข')),
        );
      } else {
        Navigator.of(context, rootNavigator: true).pop(milesController.text);
      }

/*       await _updateBus(context); */
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณากรอกเลขไมล์')),
      );
    }
  }

/*   Future<void> _updateBus(context) async {
    if (canPress) {
      canPress = false;
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
          "car_mileage_start": int.parse(milesController.text),
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

        var updateBusReserveObj = {
          "doc_no": busRef.resultData[0].busReserveInfoInfo.docNo,
          "route_info_id": busRef.resultData[0].busReserveInfoInfo.routeInfoId,
          "trip_datetime":
              busRef.resultData[0].busReserveInfoInfo.tripDatetime.toString(),
          "is_normal_time":
              busRef.resultData[0].busReserveInfoInfo.isNormalTime,
          "emp_department_id":
              busRef.resultData[0].busReserveInfoInfo.empDepartmentId,
          "bus_reserve_status_id": "INPROGRESS",
          "bus_reserve_reason_text": busRef
                      .resultData[0].busReserveInfoInfo.busReserveReasonText ==
                  null
              ? ''
              : busRef.resultData[0].busReserveInfoInfo.busReserveReasonText,
          "car_mileage": int.parse(milesController.text),
        };

        /////////// END GET REF INFO /////////////////
        ///
        ///
        ///
        /////////// UPDATE BUSJOB AND BUSRESERVE /////

        var updateJobUrl = Uri.parse(
            '${dotenv.env['BASE_API']}${dotenv.env['PUT_BUS_JOB_INFO']}/${busJobId}');
        var updateReserveJobUrl = Uri.parse(
            '${dotenv.env['BASE_API']}${dotenv.env['PUT_BUS_RESERVE_INFO']}/${busReserveInfoId}');

        var updateJobInfo =
            await putHttpWithToken(updateJobUrl, token, updateBusJobObj);

        var updateReserveJob = await putHttpWithToken(
            updateReserveJobUrl, token, updateBusReserveObj);

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

        Navigator.of(context, rootNavigator: true).pop(true);
      } catch (e) {
        canPress = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${dotenv.env['NO_INTERNET_CONNECTION']}')),
        );
        Navigator.of(context, rootNavigator: true).pop(false);
      }
    } else {}
  } */
}
