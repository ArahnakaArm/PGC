import 'package:flutter/material.dart';
import 'package:pgc/screens/processwork.dart';
import 'package:pgc/utilities/constants.dart';

class ConfirmWorkDialogBox extends StatelessWidget {
  String reserveId;
  ConfirmWorkDialogBox(this.reserveId);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          alignment: Alignment.topCenter,
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: 125, left: 40, right: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 30,
                      ),
                      Text(
                        'ตรวจสอบเลขไมล์ก่อนเปิดงาน',
                        style: callDialogBlueTextStyle,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        'ทะเบียนรถ: TEST',
                        style: callDialogBlackTextStyle,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        'เลขไมล์เริ่มต้น: TEST',
                        style: callDialogBlackTextStyle,
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
                            Navigator.of(context, rootNavigator: true).pop();
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
                          Navigator.of(context, rootNavigator: true).pop();
                          _goProgess(context);
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
                              'เริ่มทำงาน',
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
    );
  }

  void _goProgess(context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProcessWork()),
    );
  }
}
