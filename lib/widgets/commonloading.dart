import 'package:flutter/material.dart';
import 'package:pgc/utilities/constants.dart';

class CircularLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 50,
          ),
          SizedBox(
              child: CircularProgressIndicator(
                strokeWidth: 10,
              ),
              width: 100,
              height: 100),
          SizedBox(
            height: 35,
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
