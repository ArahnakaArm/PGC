import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pgc/model/passData.dart';
import 'package:pgc/screens/scanandlist.dart';
import 'package:pgc/services/http/getHttpWithToken.dart';
import 'package:pgc/services/http/putHttpWithToken.dart';
import 'package:pgc/services/utils/common.dart';
import 'package:pgc/widgets/background.dart';
import 'package:pgc/widgets/backpressincontainer.dart';
import 'package:pgc/widgets/dialogbox/loadingDialogBox.dart';
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
  PassDataModel passedData;
  var locationName = "";
  var checkInTime = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        passedData = ModalRoute.of(context).settings.arguments == null
            ? ''
            : ModalRoute.of(context).settings.arguments as PassDataModel;

        locationName = passedData.locationName;
        status = passedData.status;
      });
      _checkInternet(passedData.busJobPoiId);
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
                      CommonSmallCheckInBackground(context, locationName),
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
                      _checkInButton(context, passedData)
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

  GestureDetector _checkInButton(context, passedData) {
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

  void _backPress(context) {
    Navigator.pop(context);
  }

  Future<void> _goScanAndList(context, PassDataModel passedData) async {
    await _updateJobPoiStatus(passedData.busJobPoiId);
  }

  Future<void> _updateJobPoiStatus(busJobPoiId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return LoadingDialogBox();
      },
    );
    ///////// GET BUSJOBPOI ID //////////
    final storage = new FlutterSecureStorage();
    String token = await storage.read(key: 'token');
    String userId = await storage.read(key: 'userId');
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
        "status": "CHECKED-IN"
      };
      var putPoiResObj =
          await putHttpWithToken(updatebusPoiUrl, token, updateBusPoiObj);
      Navigator.pop(context); //pop dial
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScanAndList(),
          settings: RouteSettings(
            arguments: passedData,
          ),
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${dotenv.env['NO_INTERNET_CONNECTION']}')),
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
