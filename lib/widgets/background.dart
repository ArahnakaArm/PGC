import 'package:flutter/material.dart';

class BackGround extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
            Color.fromRGBO(0, 52, 97, 1),
            Color.fromRGBO(2, 117, 216, 1)
          ])),
    );
  }
}
