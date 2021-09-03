import 'package:flutter/material.dart';
import 'package:pgc/utilities/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class CallDialogBox extends StatelessWidget {
  String textCall;

  CallDialogBox(this.textCall);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(top: 125, left: 40, right: 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 30,
              ),
              Text(
                'ติดต่อเจ้าหน้าที่',
                style: callDialogTextStyle,
              ),
              Text(
                'โทร. ${textCall}',
                style: callDialogTextStyle,
              ),
              SizedBox(
                height: 30,
              ),
              GestureDetector(
                onTap: () {
                  _makePhoneCall('tel:${textCall}');
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                      border: Border(
                          top: BorderSide(width: 0.75, color: Colors.black))),
                  child: Center(
                      child: Text('โทร',
                          style:
                              callDialogTextStyle) /* Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          'assets/images/viber.png',
                          height: 27,
                          width: 35,
                        ),
                        /*         Text('โทร', style: callDialogTextStyle), */
                      ],
                    ), */
                      ),
                ),
              )
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
