import 'package:flutter/material.dart';
import 'package:pgc/utilities/constants.dart';

class CircularLoadingSmall extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 30,
          ),
          SizedBox(
              child: CircularProgressIndicator(
                strokeWidth: 8,
              ),
              width: 70,
              height: 65),
          SizedBox(
            height: 25,
          ),
          Text(
            'กำลังโหลด...',
            style: loadingText,
          )
        ],
      ),
    );
  }
}
