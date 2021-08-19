import 'package:flutter/material.dart';
import 'package:pgc/screens/scanandlist.dart';
import 'package:pgc/widgets/background.dart';
import 'package:pgc/widgets/backpressincontainer.dart';
import 'package:pgc/widgets/profilebar.dart';
import 'package:pgc/utilities/constants.dart';
import 'package:pgc/model/histories.dart';
import 'package:pgc/widgets/tabbutton.dart';
import 'package:pgc/widgets/commonsmallcheckinbackground.dart';

class CheckIn extends StatefulWidget {
  const CheckIn({Key key, this.value}) : super(key: key);
  final String value;

  @override
  _CheckInState createState() => _CheckInState();
}

class _CheckInState extends State<CheckIn> {
  String status = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        status = ModalRoute.of(context).settings.arguments;
      });
      print(status);
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
                      CommonSmallCheckInBackground(context),
                      SizedBox(
                        height: 40,
                      ),
                      Text(
                        'โปรด Checkin ก่อนรับผู้โดยสาร',
                        style: checkInReminderTextStyle,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      _checkInButton(context, this.status)
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
}

GestureDetector _checkInButton(context, status) {
  return GestureDetector(
    onTap: () {
      _goScanAndList(context, status);
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

void _backPress(context) {
  Navigator.pop(context);
}

void _goScanAndList(context, status) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => ScanAndList(),
      settings: RouteSettings(
        arguments: status,
      ),
    ),
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
