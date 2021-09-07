import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pgc/screens/mainmenu_screen.dart';
import 'package:pgc/widgets/background.dart';
import 'package:pgc/widgets/profilebar.dart';
import 'package:pgc/utilities/constants.dart';
import 'package:pgc/model/histories.dart';
import 'package:pgc/widgets/profilebarwithdepartment.dart';

class SuccessFinishJob extends StatefulWidget {
  const SuccessFinishJob({Key key}) : super(key: key);

  @override
  _SuccessFinishJobState createState() => _SuccessFinishJobState();
}

class _SuccessFinishJobState extends State<SuccessFinishJob> {
  DateTime current;
  String docNo;

  Future<bool> popped() {
    _goMainMenu(context);
    /*  FToast fToast = FToast();
    fToast.init(context);

    DateTime now = DateTime.now();
    if (current == null || now.difference(current) > Duration(seconds: 2)) {
      current = now;
      /*     Fluttertoast.showToast(
          msg: "กดย้อนกลับอีกครั้งเพื่อปิด", toastLength: Toast.LENGTH_SHORT); */
      fToast.showToast(
          child: Container(
        padding: EdgeInsets.symmetric(vertical: 1, horizontal: 10),
        decoration: BoxDecoration(
            color: Color.fromRGBO(75, 132, 241, 1),
            borderRadius: BorderRadius.circular(20)),
        child: Text(
          'กดปุ่มกลับอีกครั้ง เพื่อออกจากแอป',
          style: toastTextStyle,
        ),
      ));
      return Future.value(false);
    } else {
      Fluttertoast.cancel();
      _goMainMenu(context);
      return Future.value(true);
    } */
  }

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        docNo = ModalRoute.of(context).settings.arguments == null
            ? ''
            : ModalRoute.of(context).settings.arguments;
      });

      /*  _getBusJobPoiInfo(passedData.busJobPoiId); */
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => popped(),
      child: Scaffold(
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
              width: double.infinity,
              margin: EdgeInsets.only(
                  left: 25.0, right: 25.0, bottom: 20.0, top: 90),
              decoration: commonBackgroundStyle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 45,
                  ),
                  Text(
                    docNo == null ? "" : docNo,
                    style: jobTitleSuccessTextStyle,
                  ),
                  SizedBox(
                    height: 45,
                  ),
                  Image.asset(
                    'assets/images/success.png',
                    height: 175,
                    width: 175,
                  ),
                  SizedBox(
                    height: 45,
                  ),
                  Text(
                    'ให้บริการสำเร็จ !',
                    style: successTextStyle,
                  ),
                  SizedBox(
                    height: 45,
                  ),
                  _backToFirstPageButton(context)
                ],
              ),
            )
          ],
        ),
      )),
    );
  }
}

GestureDetector _backToFirstPageButton(context) {
  return GestureDetector(
    onTap: () {
      _goMainMenu(context);
    },
    child: Container(
      height: 40,
      margin: EdgeInsets.only(
        left: 20.0,
        right: 20.0,
      ),
      decoration: BoxDecoration(color: Color.fromRGBO(2, 117, 216, 1)),
      child: Center(
        child: Text(
          'กลับไปยังหน้าแรก',
          style: confirmFinishJobButtonTextStyle,
        ),
      ),
    ),
  );
}

void _goMainMenu(context) {
  Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => MainMenuScreen()),
      (Route<dynamic> route) => false);
}
