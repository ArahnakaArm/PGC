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
import 'package:pgc/utilities/constants.dart';

class ConfirmCheckinDialogBox extends StatelessWidget {
  String locationName;
  ConfirmCheckinDialogBox(this.locationName);

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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 30,
                        ),
                        Text(
                          'ยืนยันการเช็คอิน',
                          style: callDialogBlueTextStyle,
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          'คุณต้องการเช็คอิน ${this.locationName} หรือไม่ ?',
                          style: callDialogBlackTextStyle,
                        ),
                        SizedBox(
                          height: 15,
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
                            Navigator.of(context, rootNavigator: true)
                                .pop(true);
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
                                'ตกลง',
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
}
