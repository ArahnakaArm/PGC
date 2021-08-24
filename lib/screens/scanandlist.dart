import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pgc/screens/confirmfinishjob.dart';
import 'package:pgc/widgets/background.dart';
import 'package:pgc/widgets/backpressincontainer.dart';
import 'package:pgc/widgets/dialogbox/employeeInfoDialogBox.dart';
import 'package:pgc/widgets/dialogbox/errorEmployeeInfoDialogBox.dart';
import 'package:pgc/widgets/dialogbox/savedEmployeeInfoDialogBox.dart';
import 'package:pgc/widgets/dialogbox/successEmployeeInfoDialogBox.dart';
import 'package:pgc/widgets/profilebar.dart';
import 'package:pgc/utilities/constants.dart';
import 'package:pgc/model/passenger.dart';
import 'package:pgc/widgets/tabbutton.dart';
import 'package:pgc/widgets/commonsmallprocessbackground.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanAndList extends StatefulWidget {
  @override
  _ScanAndListState createState() => _ScanAndListState();
}

class _ScanAndListState extends State<ScanAndList> {
  Barcode result;
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  int _selectedPage = 0;
  PageController _pageController;
  String status = '';
  List<PassengerModel> passengers = [
    PassengerModel('นาย A', 'เข็นรถ', '12.00 น.'),
    PassengerModel('นาย B', 'ทำครัว', '10.00 น.'),
  ];

  void _changePage(int pageNum) {
    setState(() {
      _selectedPage = pageNum;
      _pageController.animateToPage(pageNum,
          duration: Duration(milliseconds: 500),
          curve: Curves.fastLinearToSlowEaseIn);
    });
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    }
    controller.resumeCamera();
  }

  @override
  void initState() {
    _pageController = PageController();
    /*  Future.delayed(Duration.zero, () {
      setState(() {
        status = ModalRoute.of(context).settings.arguments;
      });
      print(status);
    }); */
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        status = ModalRoute.of(context).settings.arguments;
      });
      print(status);
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
    _pageController.dispose();
    controller?.dispose();
    super.dispose();
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
                      CommonSmallProcessBackground(),
                      Container(
                        height: 50,
                        decoration: tabbuttonBackground,
                        margin:
                            EdgeInsets.only(left: 10.0, right: 10.0, top: 15),
                        padding: EdgeInsets.only(left: 7.0, right: 7.0),
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                  child: TabButton(
                                      text: 'สแกน',
                                      fontSize: 15,
                                      pageNumber: 0,
                                      selectedPage: _selectedPage,
                                      onPressed: () {
                                        _changePage(0);
                                      },
                                      haveNumText: false,
                                      numText: '0')),
                              Expanded(
                                  child: TabButton(
                                      text: 'ขึ้นรถแล้ว',
                                      fontSize: 15,
                                      pageNumber: 1,
                                      selectedPage: _selectedPage,
                                      onPressed: () {
                                        _changePage(1);
                                      },
                                      haveNumText: true,
                                      numText: '15'))
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          children: [
                            _scanPage(context, status),
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
    ));
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 250.0
        : 300.0;
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
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        print(result);
        controller?.pauseCamera();
        _showDialog(context, result.code);
      });
    });
  }

  void _showDialog(context, text) async {
    bool shouldUpdate = await showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 250),
      context: context,
      pageBuilder: (_, __, ___) {
        return _employeeInfoDialogBox(context, text);
      },
    );

    print(shouldUpdate);
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    print('object');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('no Permission')),
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

  Container _employeeInfoDialogBox(context, text) {
    bool haveImage = false;
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
            Expanded(
              child: Container(
                child: haveImage ? NetworkImage('' ?? "") : Container(),
                margin:
                    EdgeInsets.only(left: 50, right: 50, top: 15, bottom: 60),
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
              'นาย: ${text}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: callDialogBlackTextStyle,
            ),
            SizedBox(
              height: 2,
            ),
            Text(
              'รหัสพนักงาน: TEST',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: callDialogBlackTextStyle,
            ),
            SizedBox(
              height: 2,
            ),
            Text(
              'แผนก: TEST',
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
                        _onCancel(context);
                        controller?.resumeCamera();
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
                      controller?.resumeCamera();
                      _onConfirm(context);
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
}

Container _arrivedPassengerListPage(passengers) {
  return Container(
      margin: EdgeInsets.only(top: 10, right: 10, left: 10),
      child: Padding(
          padding: const EdgeInsets.only(left: 0, right: 0),
          child: ListView.builder(
              key: PageStorageKey<String>('arrivedPassengerListPage'),
              itemCount: passengers.length,
              itemBuilder: (BuildContext context, int index) {
                PassengerModel passengersList = passengers[index];
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
                                        '${passengersList.fullname}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style:
                                            arrivedPassengerListNameTextStyle,
                                      ),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      Text(
                                        '${passengersList.department}',
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
                                        '${passengersList.arriveTime}',
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
              })));
}

GestureDetector _endScanButton(context, status) {
  return GestureDetector(
    onTap: () {
      /* _goConfirmFinishJob(context, status); */
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

void _backPress(context) {
  Navigator.pop(context);
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

void _goConfirmFinishJob(context, status) {
  if (status == 'finished') {
    Navigator.pop(context);
  } else if (status == 'non-success') {
    Navigator.pop(context);
  } else {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ConfirmFinishJob()),
    );
  }
}

void _showDialogError(context) async {
  bool shouldUpdate = await showGeneralDialog(
    barrierLabel: "Barrier",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: Duration(milliseconds: 250),
    context: context,
    pageBuilder: (_, __, ___) {
      return ErrorEmployeeInfoDialogBox('ไม่พบข้อมูลผู้โดยสารในเที่ยวนี้');
    },
  );

  print(shouldUpdate);
}

void _showDialogSaved(context) async {
  bool shouldUpdate = await showGeneralDialog(
    barrierLabel: "Barrier",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: Duration(milliseconds: 250),
    context: context,
    pageBuilder: (_, __, ___) {
      return SavedEmployeeInfoDialogBox('ระบบบันทึกข้อมูลแล้ว');
    },
  );

  print(shouldUpdate);
}

void _showDialogSuccess(context) async {
  bool shouldUpdate = await showGeneralDialog(
    barrierLabel: "Barrier",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: Duration(milliseconds: 250),
    context: context,
    pageBuilder: (_, __, ___) {
      return SuccessEmployeeInfoDialogBox('ผู้โดยสารขึ้นครบถ้วนแล้ว');
    },
  );

  print(shouldUpdate);
}

void _onConfirm(context) {
  print('Confirm');
}

void _onCancel(context) {
  print('Cancel');
}
