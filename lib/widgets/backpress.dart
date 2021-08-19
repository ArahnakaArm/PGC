import 'package:flutter/material.dart';
import 'package:pgc/utilities/constants.dart';

class BackPress extends StatelessWidget {
  final BuildContext ctx;
  BackPress(this.ctx);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _backPress(ctx);
      },
      child: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/backarrow.png',
              height: 25,
            ),
            SizedBox(
              width: 15,
            ),
            Text(
              'กลับไปก่อนหน้า',
              style: backPressTextStyle,
            )
          ],
        ),
      ),
    );
  }

  void _backPress(context) {
    Navigator.pop(context);
  }
}
