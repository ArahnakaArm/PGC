import 'package:flutter/material.dart';
import 'package:pgc/utilities/constants.dart';

class BackPressInContainer extends StatelessWidget {
  final BuildContext ctx;
  BackPressInContainer(this.ctx);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _backPress(ctx);
      },
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
            'กลับไปยังหน้ารายการ',
            style: backPressTextStyle,
          )
        ],
      ),
    );
  }

  void _backPress(context) {
    Navigator.pop(context);
  }
}
