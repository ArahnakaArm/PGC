import 'package:flutter/material.dart';
import 'package:pgc/utilities/constants.dart';

class EmployeeInfoDialogBox extends StatelessWidget {
  String imageUrl;
  String firstName;
  String lastName;
  String employeeId;
  String departmentName;
  bool haveImage = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: 100, left: 40, right: 40, bottom: 120),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            Text(
              'ข้อมูลพนักงาน',
              style: employeeInfoDialogHeaderTextStyle,
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: Container(
                child: haveImage ? NetworkImage('' ?? "") : Container(),
                margin:
                    EdgeInsets.only(left: 50, right: 50, top: 15, bottom: 60),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(218, 218, 218, 1),
                  image: DecorationImage(
                    image: AssetImage("assets/images/user.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Text(
              'นาย: TEST',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: callDialogBlackTextStyle,
            ),
            SizedBox(
              height: 2,
            ),
            Text(
              'รหัสพนักงาน: TEST',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: callDialogBlackTextStyle,
            ),
            SizedBox(
              height: 2,
            ),
            Text(
              'TEST',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: callDialogBlackTextStyle,
            ),
            SizedBox(
              height: 30,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context, true);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(137, 137, 137, 1),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.zero,
                            topRight: Radius.zero,
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.zero,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'ไม่ยืนยัน',
                            style: buttonDialogTextStyle,
                          ),
                        ),
                      )),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(1, 84, 155, 1),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.zero,
                          topRight: Radius.zero,
                          bottomLeft: Radius.zero,
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'ยืนยัน',
                          style: buttonDialogTextStyle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
