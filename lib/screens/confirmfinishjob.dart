import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:exif/exif.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
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
import 'package:image/image.dart' as img;

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
  File imageFile;
  var notiCounts = "0";
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    /*   FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (mounted) {
        final storage = new FlutterSecureStorage();

        notiCounts = (int.parse(notiCounts) + 1).toString();
        await storage.write(key: 'notiCounts', value: notiCounts);
        var notiCountss = await storage.read(key: 'notiCounts');
      }
    }); */
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
      _getNotiCounts();
      await _getBusJobInfo(busJobInfoId);
    }
  }

  void _getNotiCounts() async {
    final storage = new FlutterSecureStorage();
    String notiCountsStorage = await storage.read(key: 'notiCounts');
    print("NOTIC FROM " + notiCounts);
    setState(() {
      notiCounts = notiCountsStorage;
    });
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
    var dateTimeFormated = ChangeFormatDateToTHLocal(now).toString();
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
                              if (_imagePath != "")
                                Container(
                                  width: 250,
                                  height: 200,
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
                                      final XFile image =
                                          await _picker.pickImage(
                                              source: ImageSource.camera,
                                              maxWidth: 700,
                                              maxHeight: 1200);
                                      if (image != null) {
                                        var imagePath = image.path;
                                        print('imagepath: $imagePath');
                                        File rotateImage =
                                            await fixExifRotation(imagePath);
                                        setState(() {
                                          _imagePath = imagePath;
                                          imageFile = rotateImage;
                                        });
                                      }
                                      /*  await _callHttpImage(_imagePath); */
                                    }
                                  } else if (status.isGranted) {
                                    final XFile image = await _picker.pickImage(
                                        source: ImageSource.camera,
                                        maxWidth: 700,
                                        maxHeight: 1200);

                                    if (image != null) {
                                      var imagePath = image.path;
                                      print('imagepath: $imagePath');
                                      File rotateImage =
                                          await fixExifRotation(imagePath);
                                      setState(() {
                                        _imagePath = imagePath;
                                        imageFile = rotateImage;
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

  Future<File> fixExifRotation(String imagePath) async {
    final originalFile = File(imagePath);
    List<int> imageBytes = await originalFile.readAsBytes();

    final originalImage = img.decodeImage(imageBytes);

    final height = originalImage.height;
    final width = originalImage.width;

    // Let's check for the image size
    if (height >= width) {
      print("CAMARA DEBUG " +
          "YES " +
          height.toString() +
          " " +
          width.toString());
      // I'm interested in portrait photos so
      // I'll just return here
      return originalFile;
    }

    // We'll use the exif package to read exif data
    // This is map of several exif properties
    // Let's check 'Image Orientation'
    final exifData = await readExifFromBytes(imageBytes);

    img.Image fixedImage;

    if (height < width) {
      // rotate
      /*   if (exifData['Image Orientation'].printable.contains('Horizontal')) {
        fixedImage = img.copyRotate(originalImage, 180);
        print("CAMARA DEBUG " +
            "CASE  1 " +
            height.toString() +
            " " +
            width.toString());
      } else if (exifData['Image Orientation'].printable.contains('180')) {
        fixedImage = img.copyRotate(originalImage, -90);
        print("CAMARA DEBUG " +
            "CASE  2 " +
            height.toString() +
            " " +
            width.toString());
      } else {
        fixedImage = img.copyRotate(originalImage, 0);
        print("CAMARA DEBUG " +
            "CASE  3 " +
            height.toString() +
            " " +
            width.toString());
      } */

      if (exifData['Image Orientation'].printable.contains('Horizontal')) {
        fixedImage = img.copyRotate(originalImage, 0);
        print("CAMARA DEBUG " +
            "CASE  1 " +
            height.toString() +
            " " +
            width.toString());
      } else if (exifData['Image Orientation'].printable.contains('180')) {
        fixedImage = img.copyRotate(originalImage, -90);
      } else if (exifData['Image Orientation'].printable.contains('CCW')) {
        fixedImage = img.copyRotate(originalImage, 180);
        print("CAMARA DEBUG " +
            "CASE  2 " +
            height.toString() +
            " " +
            width.toString());
      } else {
        fixedImage = img.copyRotate(originalImage, 0);
        print("CAMARA DEBUG " +
            "CASE  3 " +
            height.toString() +
            " " +
            width.toString());
      }
    }

    print("CAMARA DEBUG " + "NO " + height.toString() + " " + width.toString());

    // Here you can select whether you'd like to save it as png
    // or jpg with some compression
    // I choose jpg with 100% quality
    final fixedFile =
        await originalFile.writeAsBytes(img.encodeJpg(fixedImage));

    /*   setState(() {
      imageFile = fixedFile;
    }); */
    return fixedFile;
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

      var imagePath = uploadImageObjRes['resultData']['location'];

      /////////////////// GET BUSREF //////////////////

      //////////// GET REF INFO ///////////////////

      var getUserByMeUrl = Uri.parse(
          '${dotenv.env['BASE_API']}${dotenv.env['GET_USER_BY_ME_PATH']}');

      var userByMeRes = await getHttpWithToken(getUserByMeUrl, token);

      Map<String, dynamic> getUserByMeResObj = jsonDecode(userByMeRes);

      /////////////// END GET_USER_BY_ME //////////////
      print("Prod Debug" + getUserByMeResObj.toString());
      /////////////// GET_USER_PERMISSION //////////////
      var userId = getUserByMeResObj['resultData']['user_id'];

      var queryString = '?bus_job_info_id=${busJobInfoId}';

      var busRefUrl = Uri.parse(
          '${dotenv.env['BASE_API']}${dotenv.env['GET_REF_BUS_JOB_RESERVE']}${queryString}');

      var busRefRes = await getHttpWithToken(busRefUrl, token);

      busRef = busRefFromJson(busRefRes);

      String busReserveInfoId = busRef.resultData[0].busReserveInfoId;
      final sevenHourAgo =
          (new DateTime.now()).subtract(new Duration(minutes: 60 * 7));

      String isoDate = sevenHourAgo.toIso8601String() + 'Z';
      print("TEST NEW NUM " + endMiles);
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
        "bus_reserve_status_id": "COMPLETED",
        "completed_at": isoDate,
        "completed_by": userId
      };

      finishDocNo = busRef.resultData[0].busJobInfoInfo.docNo;

      var updateJobUrl = Uri.parse(
          '${dotenv.env['BASE_API']}${dotenv.env['PUT_BUS_JOB_INFO']}/${busJobInfoId}');

      var updateJobInfo =
          await putHttpWithToken(updateJobUrl, token, updateBusJobObj);

      for (int i = 0; i < busRef.resultData.length; i++) {
        var updateReserveJobUrl = Uri.parse(
            '${dotenv.env['BASE_API']}${dotenv.env['PUT_BUS_RESERVE_INFO']}/${busRef.resultData[i].busReserveInfoId}');
        var updateBusReserveObj = {
          "doc_no": busRef.resultData[i].busReserveInfoInfo.docNo,
          "route_info_id": busRef.resultData[i].busReserveInfoInfo.routeInfoId,
          "trip_datetime":
              busRef.resultData[i].busReserveInfoInfo.tripDatetime.toString(),
          "is_normal_time":
              busRef.resultData[i].busReserveInfoInfo.isNormalTime,
          "emp_department_id":
              busRef.resultData[i].busReserveInfoInfo.empDepartmentId,
          "bus_reserve_status_id": "COMPLETED",
          "bus_reserve_reason_text": busRef
                      .resultData[i].busReserveInfoInfo.busReserveReasonText ==
                  null
              ? ''
              : busRef.resultData[i].busReserveInfoInfo.busReserveReasonText,
          "car_mileage": int.parse(endMiles),
        };

        var updateReserveJob = await putHttpWithToken(
            updateReserveJobUrl, token, updateBusReserveObj);
      }

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
