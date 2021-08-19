import 'package:flutter/material.dart';
import 'package:pgc/utilities/constants.dart';

class CommonSmallProcessBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 10.0, right: 10.0),
      margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
      height: 60,
      decoration: commonSmallBackgroundStyle,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 37.5,
            height: 37.5,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration:
                BoxDecoration(color: Colors.green, shape: BoxShape.circle),
            child: Container(
              child: Image.asset(
                'assets/images/hourglass.png',
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Flexible(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Location',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: commonSmallCheckinBoxTextStyle),
              SizedBox(
                height: 3,
              ),
              Text('Status',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: commonSmallCheckinBoxTextStyle)
            ],
          )),
          SizedBox(
            width: 5,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Checkin :',
                style: checkinTimeTextStyle,
              ),
              SizedBox(height: 3),
              Text('')
            ],
          )
        ],
      ),
    );
  }
}
