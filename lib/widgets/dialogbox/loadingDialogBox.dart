import 'package:flutter/material.dart';
import 'package:pgc/utilities/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class LoadingDialogBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(top: 200, left: 40, right: 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              SizedBox(
                  child: CircularProgressIndicator(
                    strokeWidth: 7,
                  ),
                  width: 75,
                  height: 75),
              SizedBox(
                height: 25,
              ),
              Text(
                'กรุณารอสักครู่...',
                style: callDialogTextStyle,
              ),
              SizedBox(
                height: 25,
              ),
            ],
          ),
        )
      ],
    );
  }

  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
