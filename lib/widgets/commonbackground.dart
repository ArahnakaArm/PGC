import 'package:flutter/material.dart';
import 'package:pgc/widgets/commonsmallcheckinbackground.dart';
import 'package:pgc/utilities/constants.dart';

class CommonBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
      decoration: commonBackgroundStyle,
      margin: EdgeInsets.only(left: 25.0, right: 25.0, bottom: 20.0),
      child: Container(
        child: Column(
            /*  children: <Widget>[CommonSmallCheckInBackground()] */
            ),
      ),
    ));
  }
}
