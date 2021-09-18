import 'package:flutter/material.dart';
import 'package:pgc/utilities/constants.dart';

class ErrorScanDialogBox extends StatelessWidget {
  String errorMessage;

  ErrorScanDialogBox(this.errorMessage);

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
                          'คำเตือน',
                          style: callDialogRedTextStyle,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        '${errorMessage}',
                        style: callDialogBlackTextStyle,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context, true);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(
                        border: Border(
                            top: BorderSide(width: 0.75, color: Colors.black))),
                    child: Center(
                      child: Text('ปิด', style: callDialogTextStyle),
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
}
