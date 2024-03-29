import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pgc/responseModel/user.dart';
import 'package:pgc/screens/setting_screen.dart';
import 'package:pgc/services/http/getHttpWithToken.dart';
import 'package:pgc/services/http/patchHttpWithToken.dart';
import 'package:pgc/utilities/constants.dart';
import 'package:badges/badges.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as httpp;

class ProfileBarWithDepartmentNoAlarm extends StatefulWidget {
  @override
  _ProfileBarWithDepartmentNoAlarmState createState() =>
      _ProfileBarWithDepartmentNoAlarmState();

  String? notifinationCount;
}

class _ProfileBarWithDepartmentNoAlarmState
    extends State<ProfileBarWithDepartmentNoAlarm> with WidgetsBindingObserver {
  User? user;
  String? baseProfileUrl;
  bool haveImage = false;
  var firstName;
  var lastName;
  var profileUrl = "";
  var department;
  bool isConnect = true;
  final ImagePicker _picker = ImagePicker();
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
                      _openBottomSheet();
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
                    )),
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

  void _openBottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return _bottomSheet();
        });
  }

  Column _bottomSheet() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          leading: new Icon(Icons.photo),
          title: new Text('เลือกรูปภาพ'),
          onTap: () {
            Navigator.pop(context);
            _pickImage(ImageSource.gallery);
          },
        ),
        ListTile(
          leading: new Icon(Icons.camera_alt),
          title: new Text('ถ่ายรูป'),
          onTap: () {
            Navigator.pop(context);
            _pickImage(ImageSource.camera);
          },
        ),
        ListTile(
          leading: new Icon(Icons.cancel),
          title: new Text('ยกเลิก'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  void _pickImage(src) async {
    final storage = new FlutterSecureStorage();
    String? token = await storage.read(key: 'token');

    try {
      final XFile? photo = await _picker.pickImage(source: src);
      if (photo == null) {
        return;
      }
      Map<String, String> headers = {HttpHeaders.authorizationHeader: token!};
      Uri uri = Uri.parse(
          '${dotenv.env['BASE_API']}${dotenv.env['POST_IMAGE_USER']}');
      httpp.MultipartRequest request = httpp.MultipartRequest('POST', uri);

      request.files.add(await httpp.MultipartFile.fromPath(
        'file',
        photo.path,
      ));

      request.headers.addAll(headers);

      httpp.StreamedResponse response = await request.send();
      var responseImageUpload = await httpp.Response.fromStream(response);

      Map<String, dynamic> uploadImageObjRes =
          jsonDecode(responseImageUpload.body);

      var imagePath = uploadImageObjRes['resultData']['location'];

      //////////////////////// UPDATE USER //////////////////////////

      var meUrl = Uri.parse(
          '${dotenv.env['BASE_API']}${dotenv.env['GET_USER_BY_ME_PATH']}');

      var res = await patchHttpWithToken(
          meUrl, token, {"image_profile_file": imagePath.toString()});

      ///////////////////////////////////////////////////////////////
      setState(() {
        profileUrl = /* dotenv.env['BASE_URL_PROFILE'] +  */ imagePath;
      });

      await storage.write(key: 'profileUrl', value: imagePath);
    } catch (e) {
      print("RESPONSE WITH HTTP " + e.toString());
      if (e.toString() ==
          "PlatformException(camera_access_denied, The user did not allow camera access., null, null)") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('กรุณาอนุญาติการใช้กล้อง')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง')),
        );
      }
    }
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
          profileUrl = /*  dotenv.env['BASE_URL_PROFILE'] + */ profileUrlTh;
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
