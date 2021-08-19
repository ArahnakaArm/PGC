import 'package:flutter/material.dart';
import 'package:pgc/screens/scanandlist.dart';
import 'package:pgc/utilities/constants.dart';

class CommonSmallCheckInBackground extends StatelessWidget {
  final BuildContext ctx;

  CommonSmallCheckInBackground(this.ctx);

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
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration:
                BoxDecoration(color: Colors.red, shape: BoxShape.circle),
            child: Container(
              child: Image.asset(
                'assets/images/pin.png',
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
              Text(
                'Location',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: commonSmallCheckinBoxTextStyle,
              ),
              SizedBox(height: 3),
              Text(
                'Status',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: commonSmallCheckinBoxTextStyle,
              )
            ],
          )),
          _checkInButton(ctx)
        ],
      ),
    );
  }
}

GestureDetector _checkInButton(context) {
  return GestureDetector(
    onTap: () {
      _goScanAndList(context);
    },
    child: Container(
      width: 100,
      height: 25,
      decoration: BoxDecoration(color: Color.fromRGBO(51, 154, 223, 1)),
      child: Center(
          child: Text(
        'Checkin',
        style: checkInButtonTextStyle,
      )),
    ),
  );
}

void _goScanAndList(context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ScanAndList()),
  );
}
