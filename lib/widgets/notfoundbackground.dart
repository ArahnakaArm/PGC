import 'package:flutter/material.dart';
import 'package:pgc/utilities/constants.dart';

class NotFoundBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 40, horizontal: 30),
      child: Center(
        child: Column(
          children: <Widget>[
            Image.asset('assets/images/not-found.png'),
            SizedBox(
              height: 10,
            ),
            Text(
              'ไม่พบข้อมูล',
              style: notFoundText,
            )
          ],
        ),
      ),
    );
  }
}
