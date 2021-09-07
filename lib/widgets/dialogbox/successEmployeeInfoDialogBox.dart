import 'package:flutter/material.dart';
import 'package:pgc/screens/processwork.dart';
import 'package:pgc/utilities/constants.dart';

class SuccessEmployeeInfoDialogBox extends StatelessWidget {
  String successMessage;

  SuccessEmployeeInfoDialogBox(this.successMessage);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          alignment: Alignment.topCenter,
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: 250, left: 40, right: 40),
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
                        height: 5,
                      ),
                      FittedBox(
                        child: Text(
                          'สำเร็จ',
                          style: callDialogGreenTextStyle,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      FittedBox(
                        child: Text(
                          '${successMessage}',
                          overflow: TextOverflow.ellipsis,
                          style: callDialogBlackTextStyle,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).pop(false);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(
                        border: Border(
                            top: BorderSide(width: 0.75, color: Colors.black))),
                    child: Center(
                      child: FittedBox(
                        child: Text('กลับไปหน้าข้อมูลเดินรถ',
                            style: callDialogTextStyle),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  void _goProcessWork(context) {
    var count = 0;
    Navigator.popUntil(context, (route) {
      return count++ == 2;
    });
  }
}
