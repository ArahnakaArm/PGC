import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pgc/responseModel/user.dart';
import 'package:pgc/screens/setting_screen.dart';
import 'package:pgc/utilities/constants.dart';
import 'package:badges/badges.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ProfileBarWithDepartment extends StatefulWidget {
  @override
  _ProfileBarWithDepartmentState createState() =>
      _ProfileBarWithDepartmentState();

  String notifinationCount;
  ProfileBarWithDepartment(this.notifinationCount);
}

class _ProfileBarWithDepartmentState extends State<ProfileBarWithDepartment>
    with WidgetsBindingObserver {
  User? user;
  String? baseProfileUrl;
  bool haveImage = false;
  var firstName;
  var lastName;
  var profileUrl = "";
  var department;
  bool isConnect = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _checkInternet();
/*     _getProfile(); */
    _getProfileStorage();
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
                GestureDetector(
                  onTap: () {
                    _uploadImage();
                  },
                  child: CircleAvatar(
                    radius: 23.0,
                    backgroundImage: isConnect
                        ? haveImage
                            ? NetworkImage(profileUrl ?? "")
                                as ImageProvider<Object> // Explicit cast
                            : AssetImage(
                                'assets/images/user.png',
                              ) // Explicit cast
                        : AssetImage(
                            'assets/images/user.png',
                          ), // Explicit cast
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
                            firstName ?? "",
                            style: profileNameStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            lastName ?? "",
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
                        "${department ?? ""}",
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
              widget.notifinationCount != "0"
                  ? badges.Badge(
                      position: BadgePosition.topEnd(top: -5, end: -6),
                      toAnimate: false,
                      shape: BadgeShape.circle,
                      badgeColor: Color.fromRGBO(255, 0, 0, 1),
                      borderRadius: BorderRadius.circular(8),
                      badgeContent: Container(
                        alignment: Alignment.center,
                        child: Text(
                          int.parse(widget.notifinationCount) > 99
                              ? '99+'
                              : '${widget.notifinationCount}',
                          style: TextStyle(color: Colors.white, fontSize: 8),
                        ),
                      ),
                      child: Icon(
                        Icons.add_alert,
                        color: Colors.white,
                        size: 32,
                      ),
                    )
                  : Icon(
                      Icons.add_alert,
                      color: Colors.white,
                      size: 32,
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

  void _checkInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      // I am connected to a mobile network.
    } else if (connectivityResult == ConnectivityResult.wifi) {
      //
    } else {
      isConnect = false;
    }
  }

  void _uploadImage() {
    print("UploadImage" + "object");
  }

  Future<void> _getProfile() async {
    final storage = new FlutterSecureStorage();

/*     setState(() {
      user.resultData.firstnameTh = storage.read(key: 'firstName');
    }); */

    /* final storage = new FlutterSecureStorage();
    String? token = await storage.read(key: 'token');
    var getUserByMeUrl = Uri.parse(
        '${dotenv.env['BASE_API']}${dotenv.env['GET_USER_BY_ME_PATH']}');

    /*    var userByMeRes = await getHttpWithToken(getUserByMeUrl, token); */
    var res = await http.get(getUserByMeUrl, headers: {
      HttpHeaders.authorizationHeader: token,
    });
    setState(() {
      user = userFromJson(res.body) ?? '';
    });

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
  } */
  }

  void _getProfileStorage() async {
    final storage = new FlutterSecureStorage();
    var firstNameTh = await storage.read(key: 'firstName');
    var lastNameTh = await storage.read(key: 'lastName');
    var profileUrlTh = await storage.read(key: 'profileUrl');
    var departmentTh = await storage.read(key: 'department');

    if (profileUrlTh == null || profileUrlTh == '') {
      setState(() {
        firstName = firstNameTh;
        lastName = lastNameTh;
        department = departmentTh;
        haveImage = false;
      });
    } else {
      setState(() {
        firstName = firstNameTh;
        lastName = lastNameTh;
        department = departmentTh;

        if (profileUrlTh != null || profileUrlTh != '') {
          haveImage = true;
          profileUrl = /* dotenv.env['BASE_URL_PROFILE'] + */ profileUrlTh;
        } else {
          haveImage = false;
          profileUrl = "";
        }
      });
    }
    /*    setState(() {
      firstName = firstNameTh;
      lastName = lastNameTh;
      department = departmentTh;

      if (profileUrlTh != null || profileUrlTh != '') {
        haveImage = true;
        profileUrl = dotenv.env['BASE_URL_PROFILE'] + profileUrlTh;
      } else {
        haveImage = false;
        profileUrl = "";
      }
    }); */

    /*   setState(() async {
      firstName = await storage.read(key: 'firstName');
      print(firstName);
      lastName = await storage.read(key: 'lastName');
      profileUrl = await storage.read(key: 'profileUrl');

      if (profileUrl != null) {
        haveImage = true;
        profileUrl = dotenv.env['BASE_URL_PROFILE'] + profileUrl;
      } else {
        haveImage = false;
        profileUrl = "";
      }

      department = await storage.read(key: 'department');
    }); */
  }
}

void _goSettingScreen(context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => SettingScreen()),
  );
}
