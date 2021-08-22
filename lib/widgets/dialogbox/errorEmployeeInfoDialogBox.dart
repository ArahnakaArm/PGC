import 'package:flutter/material.dart';
import 'package:pgc/utilities/constants.dart';

class ErrorEmployeeInfoDialogBox extends StatelessWidget {
  String errorMessage;

  ErrorEmployeeInfoDialogBox(this.errorMessage);

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
                        height: 5,
                      ),
                      FittedBox(
                        child: Text(
                          'พบข้อผิดพลาด',
                          style: callDialogRedTextStyle,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      FittedBox(
                        child: Text(
                          '${errorMessage}',
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
