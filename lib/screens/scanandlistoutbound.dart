import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pgc/model/passData.dart';
import 'package:pgc/responseModel/passengerList.dart';
import 'package:pgc/services/http/getHttpWithToken.dart';
import 'package:pgc/services/http/putHttpWithToken.dart';
import 'package:pgc/services/utils/common.dart';
import 'package:pgc/widgets/background.dart';
import 'package:pgc/widgets/commonsmallprocessbackgroundoutbound.dart';
import 'package:pgc/widgets/dialogbox/errorScanDialogBox.dart';
import 'package:pgc/widgets/dialogbox/loadingDialogBox.dart';
import 'package:pgc/widgets/dialogbox/notiScanDialogBox.dart';
import 'package:pgc/utilities/constants.dart';
import 'package:pgc/model/passenger.dart';
import 'package:pgc/widgets/tabbutton.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class ScanAndListOutBound extends StatefulWidget {
  @override
  _ScanAndListOutBoundState createState() => _ScanAndListOutBoundState();
}

class _ScanAndListOutBoundState extends State<ScanAndListOutBound> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  int _selectedPage = 0;
  PageController? _pageController = PageController();
  PassDataModel? passedData;
  List<PassengerModel> passengers = [
    PassengerModel('นาย A', 'เข็นรถ', '12.00 น.'),
    PassengerModel('นาย B', 'ทำครัว', '10.00 น.'),
  ];
  List<ResultDataPassengerList> usedPassengerList = [];
  var locationName = "";
  var checkInTime = "";
  var routePoiId = "";
  var busJobInfoId = "";
  var routeInfoId = "";
  var unFormatCheckIntime = "";
  var busPoiInfoStatus = "";
  var poiInfoStatus = "";
  var reserveCount = 0;
  int passengerCounts = 0;
  int passengerMaxCount = 0;
  var notiCounts = "0";

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }
    controller?.resumeCamera();
  }

  @override
  void initState() {
    passengerCounts = usedPassengerList.length;
    /*  Future.delayed(Duration.zero, () {
      setState(() {
        status = ModalRoute.of(context).settings.arguments;
      });
      print(status);
    }); */

    /*  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (mounted) {
        final storage = new FlutterSecureStorage();

        notiCounts = (int.parse(notiCounts) + 1).toString();
        await storage.write(key: 'notiCounts', value: notiCounts);
        var notiCountss = await storage.read(key: 'notiCounts');
      }
    }); */
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        passedData = ModalRoute.of(context)?.settings.arguments == null
            ? PassDataModel('', '', '', 0, 0)
            : ModalRoute.of(context)?.settings.arguments as PassDataModel;

        locationName = passedData!.locationName;
        poiInfoStatus = passedData!.status;
        passengerMaxCount = passedData!.passengerCount;
      });

      _checkInternet(passedData!.busJobPoiId);
      print("check-outbound");
      /*  _getBusJobPoiInfo(passedData.busJobPoiId); */
    });

    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('resume');
    }
  }

  @override
  void dispose() {
    _pageController?.dispose();
    controller?.dispose();
    super.dispose();
  }

  void _getNotiCounts() async {
    final storage = new FlutterSecureStorage();
    String? notiCountsStorage = await storage.read(key: 'notiCounts');
    print("NOTIC FROM " + notiCounts);

    if (notiCountsStorage != null) {
      setState(() {
        notiCounts = notiCountsStorage;
      });
    }
  }

  void _changePage(int pageNum) {
    if (mounted) {
      setState(() {
        _selectedPage = pageNum;

        if (_pageController!.hasClients) {
          _pageController?.animateToPage(pageNum,
              duration: Duration(milliseconds: 500),
              curve: Curves.fastLinearToSlowEaseIn);
        }
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (poiInfoStatus == 'IDLE') {
      Navigator.pop(context);
    } else if (poiInfoStatus == 'non-success') {
      Navigator.pop(context);
    } else if (poiInfoStatus == "ManualCheckin") {
      Navigator.pop(context);
      Navigator.pop(context);
      /* Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ConfirmFinishJob()),
      ); */
    } else {
      Navigator.pop(context);
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
            body: SafeArea(
          child: Stack(
            children: <Widget>[
              BackGround(),
              Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 20),
                  ),
                  SizedBox(height: 15),
                  Expanded(
                      child: Container(
                    decoration: commonBackgroundStyle,
                    margin:
                        EdgeInsets.only(left: 25.0, right: 25.0, bottom: 20.0),
                    child: Container(
                      child: Column(
                        children: <Widget>[
                          CommonSmallProcessBackgroundOutBound(
                              locationName,
                              checkInTime,
                              busPoiInfoStatus,
                              reserveCount,
                              passengerCounts),
                          Container(
                            height: 50,
                            decoration: tabbuttonBackground,
                            margin: EdgeInsets.only(
                                left: 10.0, right: 10.0, top: 15),
                            padding: EdgeInsets.only(left: 7.0, right: 7.0),
                            child: Container(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Expanded(
                                      child: GestureDetector(
                                    onTap: () {
                                      _changePage(0);
                                    },
                                    child: TabButton(
                                        text: 'สแกน',
                                        fontSize: 15,
                                        pageNumber: 0,
                                        selectedPage: _selectedPage,
                                        onPressed: () {},
                                        haveNumText: false,
                                        numText: '0'),
                                  )),
                                  Expanded(
                                      child: GestureDetector(
                                    onTap: () {
                                      _changePage(1);
                                    },
                                    child: TabButton(
                                        text: 'ขึ้นรถแล้ว',
                                        fontSize: 15,
                                        pageNumber: 1,
                                        selectedPage: _selectedPage,
                                        onPressed: () {},
                                        haveNumText: true,
                                        numText: passengerCounts.toString()),
                                  ))
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: PageView(
                              controller: _pageController,
                              children: [
                                _scanPage(context, poiInfoStatus),
                                _arrivedPassengerListPage(passengers)
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ))
                ],
              ),
            ],
          ),
        )));

    ;
  }

  void _checkInternet(busJobPoiId) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${dotenv.env['NO_INTERNET_CONNECTION']}')),
      );
    } //
    else {
      _getNotiCounts();

      await _getBusJobPoiInfo(busJobPoiId);
      await _getBusJobInfo();
      await _getUsedPassengerInit(routePoiId);
    }
  }

  Future<void> _getBusJobPoiInfo(busJobPoiId) async {
    final storage = new FlutterSecureStorage();
    String? token = await storage.read(key: 'token');
    String? userId = await storage.read(key: 'userId');

    var getBusPoiUrl = Uri.parse(
        '${dotenv.env['BASE_API']}${dotenv.env['GET_BUS_JOB_POI']}/${busJobPoiId}');

    var getBusPoiRes = await getHttpWithToken(getBusPoiUrl, token);
    Map<String, dynamic> getBusPoiResObj = jsonDecode(getBusPoiRes);

    var busJobPoiCheckinTime =
        getBusPoiResObj['resultData']['checkin_datetime'];

    unFormatCheckIntime = busJobPoiCheckinTime;
    routePoiId = getBusPoiResObj['resultData']['route_poi_info_id'];
    busJobInfoId = getBusPoiResObj['resultData']['bus_job_info_id'];
    routeInfoId = getBusPoiResObj['resultData']['route_info_id'];

    if (mounted) {
      setState(() {
        busPoiInfoStatus = getBusPoiResObj['resultData']['status'];
        checkInTime = ChangeFormateDateTimeToTime(busJobPoiCheckinTime);
      });
    }
  }

  Future<void> _getBusJobInfo() async {
    final storage = new FlutterSecureStorage();
    String? token = await storage.read(key: 'token');
    String? userId = await storage.read(key: 'userId');

    var getBusJobInfoUrl = Uri.parse(
        '${dotenv.env['BASE_API']}${dotenv.env['GET_BUS_JOB_INFO']}/${busJobInfoId}');

    var getBusJobRes = await getHttpWithToken(getBusJobInfoUrl, token);
    Map<String, dynamic> getBusJobResObj = jsonDecode(getBusJobRes);

    setState(() {
      reserveCount = getBusJobResObj['resultData']['number_of_reserved'];
    });

    print("check-outbound" + reserveCount.toString());
    print("check-outbound" + busJobInfoId.toString());
  }

  Future<void> _getUsedPassenger(routePoiId) async {
    final storage = new FlutterSecureStorage();
    String? token = await storage.read(key: 'token');
    String? userId = await storage.read(key: 'userId');
    var status = "USED";
    var queryString =
        '?passenger_status_id=${status}&bus_job_info_id=${busJobInfoId}';
    var getPassengerListUrl = Uri.parse(
        '${dotenv.env['BASE_API']}${dotenv.env['GET_USED_PASSENGER_LIST']}${queryString}');

    var res = await getHttpWithToken(getPassengerListUrl, token);

    setState(() {
      usedPassengerList = (jsonDecode(res)['resultData'] as List)
          .map((i) => ResultDataPassengerList.fromJson(i))
          .toList();
      passengerCounts = usedPassengerList.length;
    });

    print("data ID and Type " + passengerCounts.toString());
    print("data ID and Type " + busJobInfoId);

    if (passengerCounts == reserveCount) {
      if (busPoiInfoStatus != "FINISHED") {
        await _updateBusPoiInfo();
      }
      var textError = '';
      print("What Happen " + usedPassengerList.length.toString());
      print("What Happen " + passengerMaxCount.toString());
      if (passengerMaxCount == usedPassengerList.length) {
        textError = 'ผู้โดยสารขึ้นครบถ้วนแล้ว';
      } else {
        textError = 'ผู้โดยสารขึ้นครบถ้วนแล้ว';
      }

      await showGeneralDialog(
        barrierLabel: "Barrier",
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: Duration(milliseconds: 250),
        context: context,
        pageBuilder: (_, __, ___) {
          return NotiScanDialogBox('${textError}');
        },
      ).then((val) {
        if (poiInfoStatus == 'IDLE') {
          Navigator.pop(context);
        } else if (poiInfoStatus == 'non-success') {
          Navigator.pop(context);
        } else if (poiInfoStatus == "ManualCheckin") {
          Navigator.pop(context);
          Navigator.pop(context);
        } else {
          Navigator.pop(context);
        }
      });
      ;
    }
  }

  Future<void> _getUsedPassengerInit(routePoiId) async {
    final storage = new FlutterSecureStorage();
    String? token = await storage.read(key: 'token');
    String? userId = await storage.read(key: 'userId');
    var status = "USED";
    var queryString =
        '?passenger_status_id=${status}&bus_job_info_id=${busJobInfoId}';
    var getPassengerListUrl = Uri.parse(
        '${dotenv.env['BASE_API']}${dotenv.env['GET_USED_PASSENGER_LIST']}${queryString}');

    var res = await getHttpWithToken(getPassengerListUrl, token);

    setState(() {
      usedPassengerList = (jsonDecode(res)['resultData'] as List)
          .map((i) => ResultDataPassengerList.fromJson(i))
          .toList();
      passengerCounts = usedPassengerList.length;
    });

    print("data ID and Type " + passengerCounts.toString());
    print("data ID and Type " + busJobInfoId);
  }

  Future<void> playLocalAsset() async {
    final player = AudioPlayer();
    await player.play(AssetSource('success.wav'));
  }

  Future<void> playLocalAssetFail() async {
    final player = AudioPlayer();
    await player.play(AssetSource('fail.wav'));
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 250.0
        : 200.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.blue,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.resumeCamera();
    controller.scannedDataStream.listen((scanData) {
      print("SCAN DATA " + scanData.code.toString());
      // setState(() async {
      //   result = scanData;

      //   controller.pauseCamera();

      //   await _putEmployee(result?.code);
      // });

      _putEmployee(scanData.code);
    });
  }

  Future<void> _putEmployee(data) async {
    controller?.pauseCamera();

    var dataId = "";
    var dataType = "";
    try {
      data = json.decode(data);
      if (data['id'] != null) {
        dataId = data['id'];
      }
      if (data['type'] != null) {
        dataType = data['type'];
      }
    } catch (e) {
      controller?.resumeCamera();
      print("data ID and Type " + e.toString());
    }

    print("data ID and Type " + dataId);
    print("data ID and Type " + dataType);

    if (dataId != "" && dataType != "") {
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

      final storage = new FlutterSecureStorage();
      String? token = await storage.read(key: 'token');
      String? userId = await storage.read(key: 'userId');

      var envUsedPassenger = "";
      var updateUsedPassenger;

      ///////////////////////// TICKET //////////////////////////
      if (dataType == "TICKET") {
        envUsedPassenger = dotenv.env['PUT_USED_PASSENGER']!
            .replaceFirst('bus_job_info_id', busJobInfoId);
        envUsedPassenger =
            envUsedPassenger.replaceFirst('passenger_id', dataId);
        updateUsedPassenger = Uri.parse(envUsedPassenger);

        var putPassengerListUrl =
            Uri.parse('${dotenv.env['BASE_API']}${updateUsedPassenger}');

        var updateObj = {};
        var putRes =
            await putHttpWithToken(putPassengerListUrl, token, updateObj);

        print("envUsedPassengerDebug " + putPassengerListUrl.toString());

        print("envUsedPassengerDebug " + putRes);

        Map<String, dynamic> getBusPoiResObj = jsonDecode(putRes);

        if (getBusPoiResObj['resultCode'] == "40900") {
          Navigator.pop(context); //pop dialog

          await playLocalAssetFail();
          showGeneralDialog(
            barrierLabel: "Barrier",
            barrierDismissible: true,
            barrierColor: Colors.black.withOpacity(0.5),
            transitionDuration: Duration(milliseconds: 250),
            context: context,
            pageBuilder: (_, __, ___) {
              return ErrorScanDialogBox('QR Code นี้แสกนแล้ว');
            },
          ).then((val) {
            if (val != null) {
              controller?.resumeCamera();
            }
            controller?.resumeCamera();
          });
        } else if (getBusPoiResObj['resultCode'] == "40401") {
          Navigator.pop(context); //pop dialog

          await playLocalAssetFail();
          showGeneralDialog(
            barrierLabel: "Barrier",
            barrierDismissible: true,
            barrierColor: Colors.black.withOpacity(0.5),
            transitionDuration: Duration(milliseconds: 250),
            context: context,
            pageBuilder: (_, __, ___) {
              return ErrorScanDialogBox('ไม่พบข้อมูลผู้โดยสาร');
            },
          ).then((val) {
            if (val != null) {
              controller?.resumeCamera();
            }
            controller?.resumeCamera();
          });
        } else if (getBusPoiResObj['resultCode'] == "40902") {
          Navigator.pop(context); //pop dialog

          await playLocalAssetFail();
          showGeneralDialog(
            barrierLabel: "Barrier",
            barrierDismissible: true,
            barrierColor: Colors.black.withOpacity(0.5),
            transitionDuration: Duration(milliseconds: 250),
            context: context,
            pageBuilder: (_, __, ___) {
              return ErrorScanDialogBox('ไม่พบข้อมูลผู้โดยสาร');
            },
          ).then((val) {
            if (val != null) {
              controller?.resumeCamera();
            }
            controller?.resumeCamera();
          });
        } else if (getBusPoiResObj['resultCode'] == "40000") {
          Navigator.pop(context); //pop dialog

          await playLocalAssetFail();
          showGeneralDialog(
            barrierLabel: "Barrier",
            barrierDismissible: true,
            barrierColor: Colors.black.withOpacity(0.5),
            transitionDuration: Duration(milliseconds: 250),
            context: context,
            pageBuilder: (_, __, ___) {
              return ErrorScanDialogBox('ไม่พบข้อมูลผู้โดยสาร');
            },
          ).then((val) {
            if (val != null) {
              controller?.resumeCamera();
            }
            controller?.resumeCamera();
          });
        } else {
          await playLocalAsset();
          Navigator.pop(context);
          await _getUsedPassenger(routePoiId);

          //pop dialog
          controller?.resumeCamera();
        }
      }

      ///////////////////////////////////////////////////////////

      ///////////////////////// USER ////////////////////////////

      else if (dataType == "EMP") {
        /////////// VERIFY ////////////

        var envUserVerify = dotenv.env['VERIFY_USER']
            ?.replaceFirst('bus_job_info_id', busJobInfoId);

        envUserVerify = envUserVerify?.replaceFirst('user_id', dataId);
        var userVerify = Uri.parse(envUserVerify!);

        var userVerifyUrl = Uri.parse('${dotenv.env['BASE_API']}${userVerify}');

        var userVerifyRes = await putHttpWithToken(userVerifyUrl, token, {});
        print("SOCKEH" + userVerifyRes.toString());
        Map<String, dynamic> userVerifyResObj = jsonDecode(userVerifyRes);

        if (userVerifyResObj['resultCode'] == "20000") {
          Navigator.pop(context);
          var empName = userVerifyResObj['resultData']['firstname_th'] +
              " " +
              userVerifyResObj['resultData']['lastname_th'];

          var empId =
              userVerifyResObj['resultData']['emp_info']['emp_code'] != null
                  ? userVerifyResObj['resultData']['emp_info']['emp_code']
                  : "";

          var empDepartment = userVerifyResObj['resultData']['emp_info']
                      ['emp_department_info']['emp_department_name_th'] !=
                  null
              ? userVerifyResObj['resultData']['emp_info']
                  ['emp_department_info']['emp_department_name_th']
              : "";

          var empImage = userVerifyResObj['resultData']['image_profile_file'];

          if (empImage == null) {
            empImage = "";
          }

          if (empImage != null && empImage != "") {
            var checkImage = await http.get(
                Uri.parse(/* dotenv.env['BASE_URL_PROFILE'] + */ empImage));

            if (checkImage.statusCode != 200) {
              empImage = "";
            }
          }

          showGeneralDialog(
            barrierLabel: "Barrier",
            barrierDismissible: false,
            barrierColor: Colors.black.withOpacity(0.5),
            transitionDuration: Duration(milliseconds: 250),
            context: context,
            pageBuilder: (_, __, ___) {
              return _employeeInfoDialogBox(
                  empName, empId, empDepartment, empImage);
            },
          ).then((value) async {
            controller?.resumeCamera();
            print("SOCKEHH" + value.toString());
            if (value != null) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return LoadingDialogBox();
                },
              );

              print("TEST USER : USER WORK");
              envUsedPassenger = dotenv.env['PUT_USED_USER']!
                  .replaceFirst('bus_job_info_id', busJobInfoId);
              envUsedPassenger =
                  envUsedPassenger.replaceFirst('user_id', dataId);
              updateUsedPassenger = Uri.parse(envUsedPassenger);

              var putPassengerListUrl =
                  Uri.parse('${dotenv.env['BASE_API']}${updateUsedPassenger}');

              var updateObj = {};

              updateObj = {...updateObj, "route_poi_info_id": routePoiId};

              var putRes =
                  await putHttpWithToken(putPassengerListUrl, token, updateObj);

              print("envUsedPassengerDebug " + putPassengerListUrl.toString());

              print("envUsedPassengerDebug " + putRes);

              Map<String, dynamic> getBusPoiResObj = jsonDecode(putRes);

              if (getBusPoiResObj['resultCode'] == "40900") {
                Navigator.pop(context); //pop dialog
                await playLocalAssetFail();
                var textErr = "";

                textErr = "QR Code นี้แสกนแล้ว";
                showGeneralDialog(
                  barrierLabel: "Barrier",
                  barrierDismissible: true,
                  barrierColor: Colors.black.withOpacity(0.5),
                  transitionDuration: Duration(milliseconds: 250),
                  context: context,
                  pageBuilder: (_, __, ___) {
                    return ErrorScanDialogBox(textErr);
                  },
                ).then((val) {
                  if (val != null) {
                    controller?.resumeCamera();
                  }
                  controller?.resumeCamera();
                });
              } else if (getBusPoiResObj['resultCode'] == "40401") {
                Navigator.pop(context); //pop dialog

                await playLocalAssetFail();
                showGeneralDialog(
                  barrierLabel: "Barrier",
                  barrierDismissible: true,
                  barrierColor: Colors.black.withOpacity(0.5),
                  transitionDuration: Duration(milliseconds: 250),
                  context: context,
                  pageBuilder: (_, __, ___) {
                    return ErrorScanDialogBox('ไม่พบข้อมูลผู้โดยสาร');
                  },
                ).then((val) {
                  if (val != null) {
                    controller?.resumeCamera();
                  }
                  controller?.resumeCamera();
                });
              } else if (getBusPoiResObj['resultCode'] == "40000") {
                Navigator.pop(context); //pop dialog

                await playLocalAssetFail();
                showGeneralDialog(
                  barrierLabel: "Barrier",
                  barrierDismissible: true,
                  barrierColor: Colors.black.withOpacity(0.5),
                  transitionDuration: Duration(milliseconds: 250),
                  context: context,
                  pageBuilder: (_, __, ___) {
                    return ErrorScanDialogBox('ไม่พบข้อมูลผู้โดยสาร');
                  },
                ).then((val) {
                  if (val != null) {
                    controller?.resumeCamera();
                  }
                  controller?.resumeCamera();
                });
              } else {
                await playLocalAsset();
                setState(() {
                  passengerMaxCount = passengerMaxCount + 1;
                });
                Navigator.pop(context);
                await _getUsedPassengerInit(routePoiId);

                //pop dialog
                controller?.resumeCamera();
              }
            } else {
              controller?.resumeCamera();
            }
            controller?.resumeCamera();
          });
        } else if (userVerifyResObj['resultCode'] == "40900") {
          Navigator.pop(context); //pop dialog
          await playLocalAssetFail();
          var textErr = "";
          if (userVerifyResObj['errorMessage'] == "FULLY_SEATS") {
            textErr = "ไม่สามารถให้บริการได้ (รถเต็ม)";
          } else {
            textErr = "QR Code นี้แสกนแล้ว";
          }

          showGeneralDialog(
            barrierLabel: "Barrier",
            barrierDismissible: true,
            barrierColor: Colors.black.withOpacity(0.5),
            transitionDuration: Duration(milliseconds: 250),
            context: context,
            pageBuilder: (_, __, ___) {
              return ErrorScanDialogBox(textErr);
            },
          ).then((val) {
            if (val != null) {
              controller?.resumeCamera();
            }
            controller?.resumeCamera();
          });
        } else if (userVerifyResObj['resultCode'] == "40401") {
          Navigator.pop(context); //pop dialog

          await playLocalAssetFail();
          showGeneralDialog(
            barrierLabel: "Barrier",
            barrierDismissible: true,
            barrierColor: Colors.black.withOpacity(0.5),
            transitionDuration: Duration(milliseconds: 250),
            context: context,
            pageBuilder: (_, __, ___) {
              return ErrorScanDialogBox('ไม่พบข้อมูลผู้โดยสาร');
            },
          ).then((val) {
            if (val != null) {
              controller?.resumeCamera();
            }
            controller?.resumeCamera();
          });
        } else if (userVerifyResObj['resultCode'] == "40000") {
          Navigator.pop(context); //pop dialog
          await playLocalAssetFail();
          showGeneralDialog(
            barrierLabel: "Barrier",
            barrierDismissible: true,
            barrierColor: Colors.black.withOpacity(0.5),
            transitionDuration: Duration(milliseconds: 250),
            context: context,
            pageBuilder: (_, __, ___) {
              return ErrorScanDialogBox('ไม่พบข้อมูลผู้โดยสาร');
            },
          ).then((val) {
            if (val != null) {
              controller?.resumeCamera();
            }
            controller?.resumeCamera();
          });
        } else {
          Navigator.pop(context); //pop dialog
          await playLocalAssetFail();
          showGeneralDialog(
            barrierLabel: "Barrier",
            barrierDismissible: true,
            barrierColor: Colors.black.withOpacity(0.5),
            transitionDuration: Duration(milliseconds: 250),
            context: context,
            pageBuilder: (_, __, ___) {
              return ErrorScanDialogBox('เกิดข้อผิดพลาด');
            },
          ).then((val) {
            if (val != null) {
              controller?.resumeCamera();
            }
            controller?.resumeCamera();
          });
        }

        ///////////////////////////////
      } else {
        Navigator.pop(context);
        await playLocalAssetFail();
        showGeneralDialog(
          barrierLabel: "Barrier",
          barrierDismissible: true,
          barrierColor: Colors.black.withOpacity(0.5),
          transitionDuration: Duration(milliseconds: 250),
          context: context,
          pageBuilder: (_, __, ___) {
            return ErrorScanDialogBox('รูปแบบ QR Code ไม่ถูกต้อง');
          },
        ).then((val) {
          if (val != null) {
            controller?.resumeCamera();
          }
          controller?.resumeCamera();
        });
      }

      ///////////////////////////////////////////////////////////
    } else {
      await playLocalAssetFail();
      showGeneralDialog(
        barrierLabel: "Barrier",
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: Duration(milliseconds: 250),
        context: context,
        pageBuilder: (_, __, ___) {
          return ErrorScanDialogBox('รูปแบบ QR Code ไม่ถูกต้อง');
        },
      ).then((val) {
        if (val != null) {
          controller?.resumeCamera();
        }
        controller?.resumeCamera();
      });
    }
  }

  void _showDialog(context, text) async {
    /*   bool shouldUpdate = await showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 250),
      context: context,
      pageBuilder: (_, __, ___) {
        return _employeeInfoDialogBox(context, text);
      },
    );

    print(shouldUpdate); */
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    print('object');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${dotenv.env['NO_PERMISSION_SCAN']}')),
      );
    }
  }

  Container _scanPage(context, status) {
    return Container(
        padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            Expanded(flex: 4, child: _buildQrView(context)),
            /*       Expanded(
              flex: 1,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    if (result != null)
                      Text(
                          'Barcode Type: ${describeEnum(result.format)}   Data: ${result.code}')
                    else
                      Text('Scan a code'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.all(8),
                          /*  child: ElevatedButton(
                              onPressed: () async {
                                await controller?.toggleFlash();
                                setState(() {});
                              },
                              child: FutureBuilder(
                                future: controller?.getFlashStatus(),
                                builder: (context, snapshot) {
                                  return Text('Flash: ${snapshot.data}');
                                },
                              )) */
                        ),
                        Container(
                          margin: EdgeInsets.all(8),
                          /*   child: ElevatedButton(
                              onPressed: () async {
                                await controller?.flipCamera();
                                setState(() {});
                              },
                              child: FutureBuilder(
                                future: controller?.getCameraInfo(),
                                builder: (context, snapshot) {
                                  if (snapshot.data != null) {
                                    return Text(
                                        'Camera facing ${describeEnum(snapshot.data)}');
                                  } else {
                                    return Text('loading');
                                  }
                                },
                              )), */
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.all(8),
                          child: ElevatedButton(
                            onPressed: () async {
                              await controller?.pauseCamera();
                            },
                            child:
                                Text('pause', style: TextStyle(fontSize: 20)),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(8),
                          child: ElevatedButton(
                            onPressed: () async {
                              await controller?.resumeCamera();
                            },
                            child:
                                Text('resume', style: TextStyle(fontSize: 20)),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ), */
            SizedBox(
              height: 10,
            ),
            _endScanButton(context, status)
          ],
        ));
  }

  Container _employeeInfoDialogBox(empName, empId, empDepartment, empImage) {
    bool haveImage = false;
/*     String baseImageUrl = dotenv.env['BASE_URL_PROFILE']; */
    if (empImage != "") {
      haveImage = true;
      empImage = /* baseImageUrl + */ empImage;
    }
    print("SOCKEHH" + empImage);
    return Container(
      alignment: Alignment.topCenter,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: 100, left: 40, right: 40, bottom: 120),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            Text(
              'ข้อมูลพนักงาน',
              style: employeeInfoDialogHeaderTextStyle,
            ),
            SizedBox(
              height: 10,
            ),
            haveImage
                ? Expanded(
                    child: Container(
                      child: haveImage
                          ? Image.network(
                              empImage,
                            )
                          : Container(),
                      margin: EdgeInsets.only(
                          left: 60, right: 60, top: 20, bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                    ),
                  )
                : Expanded(
                    child: Container(
                      child: haveImage
                          ? Image.network(
                              empImage,
                            )
                          : Container(),
                      margin: EdgeInsets.only(
                          left: 60, right: 60, top: 20, bottom: 40),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(218, 218, 218, 1),
                        image: DecorationImage(
                          image: AssetImage("assets/images/user.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
            Text(
              '${empName}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: callDialogBlackTextStyle,
            ),
            SizedBox(
              height: 2,
            ),
            Text(
              'รหัสพนักงาน: ${empId}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: callDialogBlackTextStyle,
            ),
            SizedBox(
              height: 2,
            ),
            Text(
              '${empDepartment}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: callDialogBlackTextStyle,
            ),
            SizedBox(
              height: 30,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context, false);
                        /*     _onCancel(context);
                        controller?.resumeCamera(); */
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
                            'ไม่ยืนยัน',
                            style: buttonDialogTextStyle,
                          ),
                        ),
                      )),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context, true);
                      /*      controller?.resumeCamera();
                      _onConfirm(context); */
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
                          'ยืนยัน',
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
    );
  }

  GestureDetector _endScanButton(context, status) {
    return GestureDetector(
      onTap: () {
/*       passengers.add(PassengerModel('นาย A', 'เข็นรถ', '12.00 น.')); */
        _goConfirmFinishJob(context, status);
        /*   _showDialog(context); */
        /*     _showDialogError(context); */
        /*  _showDialogSuccess(context); */
        /*   _showDialogSaved(context); */
      },
      child: Container(
        height: 60,
        decoration: endScanButtonStyle,
        child: Center(
          child: Text(
            'สิ้นสุดการสแกน',
            style: endScanTextStyle,
          ),
        ),
      ),
    );
  }

  void _goConfirmFinishJob(context, status) async {
    await _updateBusPoiInfo();
    if (status == 'IDLE') {
      Navigator.pop(context);
    } else if (status == 'non-success') {
      Navigator.pop(context);
    } else if (status == "ManualCheckin") {
      Navigator.pop(context);
      Navigator.pop(context);
      /* Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ConfirmFinishJob()),
      ); */
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _updateBusPoiInfo() async {
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

    final storage = new FlutterSecureStorage();
    String? token = await storage.read(key: 'token');
    String? userId = await storage.read(key: 'userId');
    var busJopPoiId = passedData?.busJobPoiId;

    var updatebusPoiUrl = Uri.parse(
        '${dotenv.env['BASE_API']}${dotenv.env['PUT_BUS_JOB_POI']}/${busJopPoiId}');
    var updateBusPoiObj = {
      "bus_job_info_id": busJobInfoId,
      "route_info_id": routeInfoId,
      "route_poi_info_id": routePoiId,
      "checkin_datetime": unFormatCheckIntime.toString(),
      "status": "FINISHED"
    };
    // var putPoiResObj =
    await putHttpWithToken(updatebusPoiUrl, token, updateBusPoiObj);

    Navigator.pop(context);
  }

/* 
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
  } */

  Container _arrivedPassengerListPage(passengers) {
    return Container(
        child: Container(
            margin: EdgeInsets.only(top: 10, right: 10, left: 10),
            child: Padding(
                padding: const EdgeInsets.only(left: 0, right: 0),
                child: ListView.builder(
                    key: PageStorageKey<String>('arrivedPassengerListPage'),
                    itemCount: usedPassengerList.length,
                    itemBuilder: (BuildContext context, int index) {
                      ResultDataPassengerList passengersList =
                          usedPassengerList[index];
                      return Column(
                        children: <Widget>[
                          Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border(
                                  top: BorderSide(
                                      width: 1.5,
                                      color: Color.fromRGBO(242, 242, 242, 1)),
                                ),
                              ),
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.only(
                                      top: 2.0,
                                      left: 4.0,
                                      right: 5.0,
                                      bottom: 8.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Expanded(
                                            child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              '${passengersList.userInfo.firstnameTh} ${passengersList.userInfo.lastnameTh} ',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  arrivedPassengerListNameTextStyle,
                                            ),
                                            SizedBox(
                                              height: 3,
                                            ),
                                            Text(
                                              passengersList
                                                          .empInfo
                                                          .empDepartmentInfo
                                                          .empDepartmentNameTh ==
                                                      null
                                                  ? ""
                                                  : passengersList
                                                      .empInfo
                                                      .empDepartmentInfo
                                                      .empDepartmentNameTh,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  arrivedPassengerListDepartmentTextStyle,
                                            )
                                          ],
                                        )),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              passengersList.usedAt == null
                                                  ? ''
                                                  : ChangeFormateDateTimeToTimeAddHour(
                                                      passengersList.usedAt),
                                              style:
                                                  arrivedPassengerListTimeTextStyle,
                                            ),
                                            SizedBox(
                                              height: 3,
                                            ),
                                            Text('',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style:
                                                    arrivedPassengerListDepartmentTextStyle)
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              )),
                        ],
                      );
                    }))));
  }
}
