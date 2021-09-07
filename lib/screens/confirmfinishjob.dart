import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pgc/model/passDataFinishJob.dart';
import 'package:pgc/responseModel/busJobInfo.dart';
import 'package:pgc/responseModel/busRef.dart';
import 'package:pgc/screens/successfinishjob.dart';
import 'package:pgc/screens/take_photo.dart';
import 'package:pgc/services/http/getHttpWithToken.dart';
import 'package:pgc/services/http/putHttpWithToken.dart';
import 'package:pgc/services/utils/common.dart';
import 'package:pgc/widgets/background.dart';
import 'package:pgc/widgets/backpressincontainer.dart';
import 'package:pgc/widgets/dialogbox/loadingDialogBox.dart';
import 'package:pgc/widgets/profilebar.dart';
import 'package:pgc/utilities/constants.dart';
import 'package:pgc/model/passenger.dart';
import 'dart:async';
import 'package:pgc/widgets/tabbutton.dart';
import 'package:pgc/widgets/commonsmallfinishjobbackground.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class ConfirmFinishJob extends StatefulWidget {
  const ConfirmFinishJob({Key key}) : super(key: key);

  @override
  _ConfirmFinishJobState createState() => _ConfirmFinishJobState();
}

class _ConfirmFinishJobState extends State<ConfirmFinishJob> {
  BusRef busRef;
  PassDataFinishJobModel passedData;
  String routeId = '';
  String originLocation = '';
  String destinationLocation = '';
  String currentDateTime = '';
  CameraDescription _cameraDescription;
  String _imagePath = "";
  TextEditingController milesEdit = new TextEditingController();
  String busJobInfoId = "";
  String finishDocNo = "";
  int mileStart;

  @override
  void initState() {
    availableCameras().then((cameras) {
      final camera = cameras
          .where((camera) => camera.lensDirection == CameraLensDirection.back)
          .toList()
          .first;
      setState(() {
        _cameraDescription = camera;
      });
    }).catchError((err) {
      print(err);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        passedData = ModalRoute.of(context).settings.arguments == null
            ? PassDataFinishJobModel('', '', '', '', 0)
            : ModalRoute.of(context).settings.arguments
                as PassDataFinishJobModel;

        busJobInfoId = passedData.busJobInfoId;
      });

      _checkInternet(passedData.busJobInfoId);
      _setCurrentTime();
      /*  _getBusJobPoiInfo(passedData.busJobPoiId); */
    });

    super.initState();
  }

  void _checkInternet(busJobInfoId) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${dotenv.env['NO_INTERNET_CONNECTION']}')),
      );
    } //
    else {
      await _getBusJobInfo(busJobInfoId);
    }
  }

  Future<void> _getBusJobInfo(busJobInfoId) async {
    final storage = new FlutterSecureStorage();
    String token = await storage.read(key: 'token');
    String userId = await storage.read(key: 'userId');
    try {
      var getBusJobInfoUrl = Uri.parse(
          '${dotenv.env['BASE_API']}${dotenv.env['GET_BUS_JOB_INFO']}/${busJobInfoId}');

      var res = await getHttpWithToken(getBusJobInfoUrl, token);

      BusJobInfo busJobInfo = busJobInfoFromJson(res);
      routeId = busJobInfo.resultData.routeInfo.routeInfoId;

      setState(() {
        originLocation = busJobInfo.resultData.routeInfo.originRouteNameTh;
        destinationLocation =
            busJobInfo.resultData.routeInfo.destinationRouteNameTh;
        mileStart = busJobInfo.resultData.carMileageStart;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${dotenv.env['NO_INTERNET_CONNECTION']}')),
      );
    }
  }

  void _setCurrentTime() {
    DateTime now = new DateTime.now();
    var dateTimeFormated = ChangeFormatDateToTHLocal(now.toString());
    setState(() {
      currentDateTime = dateTimeFormated;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
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
                          margin: EdgeInsets.only(
                              left: 25.0, right: 25.0, bottom: 20.0),
                          decoration: commonBackgroundStyle,
                          child: SingleChildScrollView(
                            child: Container(
                                child: Column(children: <Widget>[
                              CommonSmallFinishJobBackground(
                                  originLocation, destinationLocation),
                              SizedBox(height: 18),
                              Text(
                                'ตรวจสอบเลขไมล์ก่อนปิดงาน',
                                style: finishJobTextStyle,
                              ),
                              SizedBox(height: 12),
                              Text('เลขไมล์สิ้นสุด', style: finishJobTextStyle),
                              SizedBox(height: 12),
                              Container(
                                margin: EdgeInsets.only(
                                  left: 20.0,
                                  right: 20.0,
                                ),
                                height: 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        width: 2.0,
                                        color:
                                            Color.fromRGBO(143, 144, 144, 1))),
                                child: TextField(
                                  controller: milesEdit,
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 18),
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding:
                                          EdgeInsets.only(left: 18.0),
                                      hintText: 'โปรดกรอกเลขไมล์สิ้นสุด',
                                      hintStyle: finishJobHintTextStyle),
                                ),
                              ),
                              SizedBox(height: 12),
                              Text('วันที่-เวลาปิดงาน',
                                  style: finishJobTextStyle),
                              SizedBox(height: 12),
                              _dateTimeTextField(),
                              SizedBox(height: 20),
                              Text('ถ่ายภาพ', style: finishJobTextStyle),
                              SizedBox(height: 10),
                              if (_imagePath != '')
                                Container(
                                  width: 120,
                                  height: 160,
                                  decoration:
                                      BoxDecoration(color: Colors.white),
                                  child: Image.file(File(_imagePath)),
                                )
                              else
                                Container(),
                              SizedBox(height: 10),
                              GestureDetector(
                                onTap: () async {
                                  var status = await Permission.camera.status;

                                  if (status.isDenied ||
                                      status.isPermanentlyDenied ||
                                      status.isRestricted) {
                                    if (await Permission.camera
                                        .request()
                                        .isGranted) {
                                      final String imagePath =
                                          await Navigator.of(context)
                                              .push(MaterialPageRoute(
                                                  builder: (_) => TakePhoto(
                                                        camera:
                                                            _cameraDescription,
                                                      )));
                                      print('imagepath: $imagePath');
                                      if (imagePath != null) {
                                        setState(() {
                                          _imagePath = imagePath;
                                        });
                                      }
                                      /*  await _callHttpImage(_imagePath); */
                                    }
                                  } else if (status.isGranted) {
                                    final String imagePath =
                                        await Navigator.of(context)
                                            .push(MaterialPageRoute(
                                                builder: (_) => TakePhoto(
                                                      camera:
                                                          _cameraDescription,
                                                    )));
                                    print('imagepath: $imagePath');
                                    if (imagePath != null) {
                                      setState(() {
                                        _imagePath = imagePath;
                                      });
                                    }
                                    /*    await _callHttpImage(_imagePath); */
                                  }
                                },
                                child: Image.asset(
                                  'assets/images/camera.png',
                                  height: 35,
                                  width: 35,
                                ),
                              ),
                              SizedBox(height: 20),
                              GestureDetector(
                                onTap: () async {
                                  _milesValidate(milesEdit.text);
                                },
                                child: Container(
                                  height: 40,
                                  margin: EdgeInsets.only(
                                      left: 20.0, right: 20.0, bottom: 20),
                                  decoration: BoxDecoration(
                                      color: Color.fromRGBO(92, 184, 92, 1)),
                                  child: Center(
                                    child: Text(
                                      'ยืนยันปิดงาน',
                                      style: confirmFinishJobButtonTextStyle,
                                    ),
                                  ),
                                ),
                              ),
                            ])),
                          )))
                ],
              ),
            ],
          ),
        ));
  }

  void _milesValidate(miles) async {
    print("RESPONSE WITH HTTP " + miles);
    if (miles == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณากรอกเลขไมล์')),
      );
    } else if (mileStart > int.parse(miles)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('กรุณากรอกเลขไมล์สิ้นสุดให้มากกว่าเลขไมล์เริ่มต้น')),
      );
    } else {
      if (_imagePath == "") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('กรุณาถ่ายรูป')),
        );
      } else {
        await _callHttpImage(_imagePath, miles);
        _goSuccessFinishJob(context);
      }
    }
  }

  GestureDetector _finishJobButton(context, miles) {
    return GestureDetector(
      onTap: () async {
        _milesValidate(miles);
/*       _goSuccessFinishJob(context); */
      },
      child: Container(
        height: 40,
        margin: EdgeInsets.only(
          left: 20.0,
          right: 20.0,
        ),
        decoration: BoxDecoration(color: Color.fromRGBO(92, 184, 92, 1)),
        child: Center(
          child: Text(
            'ยืนยันปิดงาน',
            style: confirmFinishJobButtonTextStyle,
          ),
        ),
      ),
    );
  }

  Container _milesTextField() {
    return Container(
      margin: EdgeInsets.only(
        left: 20.0,
        right: 20.0,
      ),
      height: 50,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border:
              Border.all(width: 2.0, color: Color.fromRGBO(143, 144, 144, 1))),
      child: TextField(
        controller: milesEdit,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: TextStyle(color: Colors.black, fontSize: 18),
        decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.only(left: 18.0),
            hintText: 'โปรดกรอกเลขไมล์สิ้นสุด',
            hintStyle: finishJobHintTextStyle),
      ),
    );
  }

  Future<void> _callHttpImage(String path, endMiles) async {
    final storage = new FlutterSecureStorage();
    String token = await storage.read(key: 'token');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return LoadingDialogBox();
      },
    );
    try {
      Map<String, String> headers = {HttpHeaders.authorizationHeader: token};
      Uri uri =
          Uri.parse('${dotenv.env['BASE_API']}${dotenv.env['POST_IMAGE']}');
      http.MultipartRequest request = http.MultipartRequest('POST', uri);

      request.files.add(await http.MultipartFile.fromPath(
        'file',
        path,
      ));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      var responseImageUpload = await http.Response.fromStream(response);
      /*   var responseBytes = await response.stream.toBytes();
    var responseString = utf8.decode(responseBytes); */
      print("RESPONSE WITH HTTP " + responseImageUpload.toString());

      Map<String, dynamic> uploadImageObjRes =
          jsonDecode(responseImageUpload.body);

      var imagePath = uploadImageObjRes['resultData']['path'];

      /////////////////// GET BUSREF //////////////////

      //////////// GET REF INFO ///////////////////
      var queryString = '?bus_job_info_id=${busJobInfoId}';

      var busRefUrl = Uri.parse(
          '${dotenv.env['BASE_API']}${dotenv.env['GET_REF_BUS_JOB_RESERVE']}${queryString}');

      var busRefRes = await getHttpWithToken(busRefUrl, token);

      busRef = busRefFromJson(busRefRes);

      String busReserveInfoId = busRef.resultData[0].busReserveInfoId;

      var updateBusJobObj = {
        "doc_no": busRef.resultData[0].busJobInfoInfo.docNo,
        "car_mileage_start":
            busRef.resultData[0].busJobInfoInfo.carMileageStart,
        "car_mileage_end": int.parse(endMiles),
        "destination_image_path": imagePath == null ? '' : imagePath,
        "route_info_id": busRef.resultData[0].busJobInfoInfo.routeInfoId,
        "trip_datetime":
            busRef.resultData[0].busJobInfoInfo.tripDatetime.toString(),
        "driver_id": busRef.resultData[0].busJobInfoInfo.driverId,
        "car_info_id": busRef.resultData[0].busJobInfoInfo.carInfoId,
        "number_of_seat": busRef.resultData[0].busJobInfoInfo.numberOfSeat,
        "number_of_reserved":
            busRef.resultData[0].busJobInfoInfo.numberOfReserved,
        "bus_reserve_status_id": "COMPLETED"
      };

      finishDocNo = busRef.resultData[0].busJobInfoInfo.docNo;

      var updateBusReserveObj = {
        "doc_no": busRef.resultData[0].busReserveInfoInfo.docNo,
        "route_info_id": busRef.resultData[0].busReserveInfoInfo.routeInfoId,
        "trip_datetime":
            busRef.resultData[0].busReserveInfoInfo.tripDatetime.toString(),
        "is_normal_time": busRef.resultData[0].busReserveInfoInfo.isNormalTime,
        "emp_department_id":
            busRef.resultData[0].busReserveInfoInfo.empDepartmentId,
        "bus_reserve_status_id": "COMPLETED",
        "bus_reserve_reason_text":
            busRef.resultData[0].busReserveInfoInfo.busReserveReasonText == null
                ? ''
                : busRef.resultData[0].busReserveInfoInfo.busReserveReasonText
      };

      var updateJobUrl = Uri.parse(
          '${dotenv.env['BASE_API']}${dotenv.env['PUT_BUS_JOB_INFO']}/${busJobInfoId}');
      var updateReserveJobUrl = Uri.parse(
          '${dotenv.env['BASE_API']}${dotenv.env['PUT_BUS_RESERVE_INFO']}/${busReserveInfoId}');

      var updateJobInfo =
          await putHttpWithToken(updateJobUrl, token, updateBusJobObj);

      var updateReserveJob = await putHttpWithToken(
          updateReserveJobUrl, token, updateBusReserveObj);
      Navigator.pop(context);
    } catch (e) {
      Navigator.pop(context); //pop dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${dotenv.env['NO_INTERNET_CONNECTION']}')),
      );
    }
    //pop dialog
    /////////////////// END GET BUSREF //////////////////
  }

  void _goSuccessFinishJob(context) {
/*   Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => SuccessFinishJob()),
  ); */
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SuccessFinishJob(),
        settings: RouteSettings(arguments: finishDocNo),
      ),
    );
  }

  Container _dateTimeTextField() {
    return Container(
      margin: EdgeInsets.only(
        left: 20.0,
        right: 20.0,
      ),
      height: 50,
      decoration: BoxDecoration(
          color: Color.fromRGBO(220, 220, 220, 1),
          borderRadius: BorderRadius.circular(8),
          border:
              Border.all(width: 2.0, color: Color.fromRGBO(143, 144, 144, 1))),
      child: TextField(
        readOnly: true,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.text,
        style: TextStyle(color: Colors.black, fontSize: 18),
        decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.only(left: 18.0),
            hintText: currentDateTime,
            hintStyle: finishJobHintTextStyle),
      ),
    );
  }
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

void _backPress(context) {
  Navigator.pop(context);
}
