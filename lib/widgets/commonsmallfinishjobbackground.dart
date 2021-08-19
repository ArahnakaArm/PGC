import 'package:flutter/material.dart';
import 'package:pgc/utilities/constants.dart';

class CommonSmallFinishJobBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 10.0, right: 10.0),
      margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
      height: 60,
      decoration: commonSmallBackgroundStyle,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            width: 37.5,
            height: 37.5,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration:
                BoxDecoration(color: Colors.red, shape: BoxShape.circle),
            child: Container(
              child: Image.asset(
                'assets/images/flag.png',
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('ต้นทาง',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: commonSmallCheckinBoxTextStyle),
              SizedBox(height: 3),
              Text('ปลายทาง',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: commonSmallCheckinBoxTextStyle)
            ],
          )),
        ],
      ),
    );
  }
}
