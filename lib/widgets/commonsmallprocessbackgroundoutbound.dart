import 'package:flutter/material.dart';
import 'package:pgc/utilities/constants.dart';

class CommonSmallProcessBackgroundOutBound extends StatelessWidget {
  String locationName;
  String checkinTime;
  String status;
  int passengerMaxCount;
  int passengerCounts;

  CommonSmallProcessBackgroundOutBound(this.locationName, this.checkinTime,
      this.status, this.passengerMaxCount, this.passengerCounts);
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
          if (this.status == "CHECKED-IN")
            _symbolInProgress()
          else if (this.status == "FINISHED")
            _symbolFinished()
          else if (this.status == "IDLE")
            _symbolIdle()
          else
            _symbol(),
          SizedBox(
            width: 10,
          ),
          Flexible(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${this.locationName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: commonSmallCheckinBoxTextStyle),
              SizedBox(
                height: 3,
              ),
              Text(
                  'รับแล้ว ${this.passengerCounts} คน จาก ${this.passengerMaxCount} คน',
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
                'Checkin ${this.checkinTime}',
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

  Container _symbolInProgress() {
    return Container(
      width: 37.5,
      height: 37.5,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
          color: Color.fromRGBO(240, 173, 78, 1), shape: BoxShape.circle),
      child: Container(
        child: Image.asset(
          'assets/images/hourglass.png',
        ),
      ),
    );
  }

  Container _symbolFinished() {
    return Container(
      width: 37.5,
      height: 37.5,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
      child: Container(
        child: Image.asset(
          'assets/images/correct.png',
        ),
      ),
    );
  }

  Container _symbolIdle() {
    return Container(
      width: 37.5,
      height: 37.5,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
          color: Color.fromRGBO(240, 173, 78, 1), shape: BoxShape.circle),
      child: Container(
        child: Image.asset(
          'assets/images/hourglass.png',
        ),
      ),
    );
  }

  Container _symbol() {
    return Container(
      width: 37.5,
      height: 37.5,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
    );
  }
}
