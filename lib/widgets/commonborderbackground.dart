import 'package:flutter/material.dart';

class CommonBorderBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(left: 20.0, right: 20.0, top: 85),
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(0, 95, 177, 1),
                  Color.fromRGBO(2, 117, 216, 0)
                ])),
        );
  }
}
