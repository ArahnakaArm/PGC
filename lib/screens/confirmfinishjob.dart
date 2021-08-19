import 'package:flutter/material.dart';
import 'package:pgc/screens/successfinishjob.dart';
import 'package:pgc/widgets/background.dart';
import 'package:pgc/widgets/backpressincontainer.dart';
import 'package:pgc/widgets/profilebar.dart';
import 'package:pgc/utilities/constants.dart';
import 'package:pgc/model/passenger.dart';
import 'dart:async';
import 'package:pgc/widgets/tabbutton.dart';
import 'package:pgc/widgets/commonsmallfinishjobbackground.dart';

class ConfirmFinishJob extends StatefulWidget {
  const ConfirmFinishJob({Key key}) : super(key: key);

  @override
  _ConfirmFinishJobState createState() => _ConfirmFinishJobState();
}

class _ConfirmFinishJobState extends State<ConfirmFinishJob> {
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
                          child: Container(
                              child: Column(children: <Widget>[
                            CommonSmallFinishJobBackground(),
                            SizedBox(height: 18),
                            Text(
                              'ตรวจสอบเลขไมล์ก่อนปิดงาน',
                              style: finishJobTextStyle,
                            ),
                            SizedBox(height: 12),
                            Text('เลขไมล์สิ้นสุด', style: finishJobTextStyle),
                            SizedBox(height: 12),
                            _milesTextField(),
                            SizedBox(height: 12),
                            Text('วันที่-เวลาปิดงาน',
                                style: finishJobTextStyle),
                            SizedBox(height: 12),
                            _dateTimeTextField(),
                            SizedBox(height: 12),
                            Text('ถ่ายภาพ', style: finishJobTextStyle),
                            SizedBox(height: 12),
                            Image.asset(
                              'assets/images/camera.png',
                              height: 35,
                              width: 35,
                            ),
                            SizedBox(height: 15),
                            _finishJobButton(context)
                          ]))))
                ],
              ),
            ],
          ),
        ));
  }
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
      textAlign: TextAlign.center,
      keyboardType: TextInputType.text,
      style: TextStyle(color: Colors.black, fontSize: 18),
      decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(left: 18.0),
          hintText: 'โปรดกรอกเลขไมล์สิ้นสุด',
          hintStyle: finishJobHintTextStyle),
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
          hintText: '20 ก.ค. 2564  20:00',
          hintStyle: finishJobHintTextStyle),
    ),
  );
}

GestureDetector _finishJobButton(context) {
  return GestureDetector(
    onTap: () {
      _goSuccessFinishJob(context);
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

void _goSuccessFinishJob(context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => SuccessFinishJob()),
  );
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
