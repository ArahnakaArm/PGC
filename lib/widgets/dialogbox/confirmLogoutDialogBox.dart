import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pgc/responseModel/deviceToken.dart';
import 'package:pgc/screens/login_screen.dart';
import 'package:pgc/services/http/deleteHttpWithToken.dart';
import 'package:pgc/services/http/getHttpWithToken.dart';
import 'package:pgc/utilities/constants.dart';

class ConfirmLogoutDialogBox extends StatelessWidget {
  List<DeviceTokenArray> deviceTokenArr;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          alignment: Alignment.topCenter,
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: 200, left: 40, right: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 30,
                      ),
                      FittedBox(
                        child: Text(
                          'ยืนยันการออกจากระบบ ?',
                          style: callDialogBlueTextStyle,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  child: Row(
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
                                child: FittedBox(
                                  child: Text(
                                    'ปิด',
                                    style: buttonDialogTextStyle,
                                  ),
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
                                child: FittedBox(
                              child: Text(
                                'ตกลง',
                                style: buttonDialogTextStyle,
                              ),
                            )),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
