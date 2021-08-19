import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pgc/responseModel/user.dart';
import 'package:pgc/screens/setting_screen.dart';
import 'package:pgc/services/http/getHttpWithToken.dart';
import 'package:pgc/utilities/constants.dart';
import 'package:badges/badges.dart';

class ProfileBarWithDepartment extends StatefulWidget {
  @override
  _ProfileBarWithDepartmentState createState() =>
      _ProfileBarWithDepartmentState();
}

class _ProfileBarWithDepartmentState extends State<ProfileBarWithDepartment>
    with WidgetsBindingObserver {
  User user;
  String baseProfileUrl;
  bool haveImage = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getProfile();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {}
  }

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 23.0,
                  backgroundImage: haveImage
                      ? NetworkImage(baseProfileUrl ?? "")
                      : AssetImage(
                          'assets/images/user.png',
                        ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          /*    Text(
                        user?.resultData?.firstnameTh ?? "",
                        style: profileNameStyle,
                      ), */

                          Text(
                            user?.resultData?.firstnameTh ?? "",
                            style: profileNameStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            user?.resultData?.lastnameTh ?? "",
                            style: profileNameStyle,
                            overflow: TextOverflow.ellipsis,
                          )
                        ],
                      ),
                      SizedBox(
                        height: 1,
                      ),
                      /* Text(
                    "แผนก: ${user?.resultData?.empInfo?.empDepartmentInfo?.empDepartmentNameTh ?? ""}",
                    style: profileNameStyle,
                  ) */
                      Text(
                        "แผนก: ${user?.resultData?.empInfo?.empDepartmentInfo?.empDepartmentNameTh ?? ""}",
                        style: profileNameStyle,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          Row(
            children: [
              Badge(
                position: BadgePosition.topEnd(top: -5, end: -6),
                toAnimate: false,
                shape: BadgeShape.circle,
                badgeColor: Color.fromRGBO(255, 0, 0, 1),
                borderRadius: BorderRadius.circular(8),
                badgeContent: Container(
                  width: 10,
                  height: 10,
                  alignment: Alignment.center,
                  child: Text(
                    '14',
                    style: TextStyle(color: Colors.white, fontSize: 7),
                  ),
                ),
                child: Icon(
                  Icons.add_alert,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  _goSettingScreen(context);
                },
                child: Icon(
                  Icons.settings,
                  color: Colors.white,
                  size: 35,
                ),
              )
            ],
          ),
        ]);
  }

  Future<void> _getProfile() async {
    final storage = new FlutterSecureStorage();
    String token = await storage.read(key: 'token');
    var getUserByMeUrl = Uri.parse(
        '${dotenv.env['BASE_API']}${dotenv.env['GET_USER_BY_ME_PATH']}');

    /*    var userByMeRes = await getHttpWithToken(getUserByMeUrl, token); */
    var res = await http.get(getUserByMeUrl, headers: {
      HttpHeaders.authorizationHeader: token,
    });
    setState(() {
      user = userFromJson(res.body) ?? '';
    });

    print(user.resultData.imageProfileFile);

    if (user.resultData.imageProfileFile != null) {
      var checkImage = await http.get(Uri.parse(
          dotenv.env['BASE_URL_PROFILE'] + user.resultData.imageProfileFile));

      if (checkImage.statusCode != 200) {
        setState(() {
          haveImage = false;
        });
      } else {
        setState(() {
          haveImage = true;
          baseProfileUrl =
              dotenv.env['BASE_URL_PROFILE'] + user.resultData.imageProfileFile;
        });
      }
    } else {
      haveImage = false;
    }
  }
}

void _goSettingScreen(context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => SettingScreen()),
  );
}
