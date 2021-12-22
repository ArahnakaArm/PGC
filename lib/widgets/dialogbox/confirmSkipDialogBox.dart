import 'package:flutter/material.dart';
import 'package:pgc/utilities/constants.dart';

class ConfirmDialogBox extends StatelessWidget {
  String errorMessage;

  ConfirmDialogBox(this.errorMessage);

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
                          Navigator.of(context, rootNavigator: true).pop(true);
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
                              'ข้าม',
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
}
