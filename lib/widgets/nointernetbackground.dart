import 'package:flutter/material.dart';
import 'package:pgc/utilities/constants.dart';

class NoInternetBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 40, horizontal: 30),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/images/no-internet.png'),
            SizedBox(
              height: 10,
            ),
            Text(
              'ไม่มีสัญญาณอินเตอร์เน็ต',
              style: notInternetText,
            )
          ],
        ),
      ),
    );
  }
}
