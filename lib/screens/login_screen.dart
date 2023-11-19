import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pgc/responseModel/permissionList.dart';
import 'package:pgc/services/http/getHttpWithToken.dart';
import 'package:pgc/services/http/postHttp.dart';
import 'package:pgc/utilities/constants.dart';
import 'package:pgc/screens/mainmenu_screen.dart';
import 'package:pgc/widgets/background.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:http/http.dart' as http;

class LogInScreen extends StatefulWidget {
  @override
  _LogInScreenState createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  bool _showPassword = false;
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              BackGround(),
              Container(
                  height: double.infinity,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: 25.0,
                      vertical: 60.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          'assets/images/pcglogo.png',
                          height: 75,
                        ),
                        SizedBox(height: 30.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.0,
                              ),
                              child: Text(
                                'บัญชีผู้ใช้',
                                style: loginLabelStyle,
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Container(
                              alignment: Alignment.centerLeft,
                              decoration: loginDecorationStyle,
                              height: 58.0,
                              child: TextField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 18),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.only(left: 18.0),
                                  hintText: 'บัญชีผู้ใช้',
                                ),
                              ),
                            ),
                            SizedBox(height: 15.0),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.0,
                              ),
                              child: Text(
                                'รหัสผ่าน',
                                style: loginLabelStyle,
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Container(
                              alignment: Alignment.centerLeft,
                              decoration: loginDecorationStyle,
                              height: 58.0,
                              child: TextField(
                                controller: passwordController,
                                textAlign: TextAlign.left,
                                textAlignVertical: TextAlignVertical.center,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(left: 18),
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _showPassword = !_showPassword;
                                      });
                                    },
                                    child: Icon(_showPassword
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                  ),
                                  border: InputBorder.none,
                                  hintText: 'รหัสผ่าน',
                                ),
                                obscureText: !_showPassword,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 34.0,
                        ),
                        RoundedLoadingButton(
                          color: Color.fromRGBO(240, 173, 78, 1),
                          height: 58,
                          borderRadius: 18,
                          child: Text('เข้าสู่ระบบ',
                              style: TextStyle(color: Colors.white)),
                          controller: _btnController,
                          onPressed: () {
                            _validate(emailController.text,
                                passwordController.text, context);
                          },
                        )
                        /*  GestureDetector(
                          onTap: () {
                            _validate(emailController.text,
                                passwordController.text, context);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: loginSubmitDecorationStyle,
                            height: 58.0,
                            child: Text(
                              'เข้าสู่ระบบ',
                              style: submitTextStyle,
                            ),
                          ),
                        ), */
                        ,
                        SizedBox(
                          height: 28.0,
                        ),
                        Text(
                          'หากลืมรหัสผ่านโปรดติดต่อผู้ดูแลระบบ',
                          style: forgotPasswordTextStyle,
                        ),
                      ],
                    ),
                  ))
            ],
          ),
        ));
  }

  void _doSomething() async {
    Timer(Duration(seconds: 3), () {
      _btnController.error();
      _btnController.reset();
    });
  }

  void _completeLogin(context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainMenuScreen()),
    );
  }

  void _validate(username, pass, ctx) async {
    FocusScope.of(context).unfocus();
    bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(username);

    if (username == '') {
      popped('กรุณากรอกอีเมล์', ctx);
      _btnController.reset();
    } else if (!emailValid) {
      popped('กรุณากรอกอีเมล์ให้ถูกต้อง', ctx);
      _btnController.reset();
    } else if (pass == '') {
      popped('กรุณากรอกพาสเวิส', ctx);
      _btnController.reset();
    } else if ((username != '') && (pass != '') && (emailValid)) {
      _logIn(username, pass, ctx);
    }
  }

  Future<void> _logIn(username, pass, ctx) async {
    ///////////// AUTH /////////////////
    var authUrl =
        Uri.parse('${dotenv.env['BASE_API']}${dotenv.env['AUTH_USER_PATH']}');
    try {
      var authRes =
          await postHttp(authUrl, {"email": username, "password": pass});

      Map<String, dynamic> authResObj = jsonDecode(authRes);

      print("Prod Debug" + authResObj.toString());

      ///////////// END AUTH /////////////////

      if (authResObj['resultCode'] == '40101' ||
          authResObj['resultCode'] == '40000') {
        /* EasyLoading.showError(
          'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง หากจำไม่ได้โปรดติดต่อผู้ดูแลระบบ'); */
        popped(
            'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง หากจำไม่ได้โปรดติดต่อผู้ดูแลระบบ',
            ctx);
        _btnController.reset();
      } else if (authResObj['resultCode'] == '20000') {
        /////////////// GET_USER_BY_ME //////////////
        Map<String, dynamic> authResObj = jsonDecode(authRes);
        var token = authResObj['resultData']['access_token'];

        var getUserByMeUrl = Uri.parse(
            '${dotenv.env['BASE_API']}${dotenv.env['GET_USER_BY_ME_PATH']}');

        var userByMeRes = await getHttpWithToken(getUserByMeUrl, token);

        Map<String, dynamic> getUserByMeResObj = jsonDecode(userByMeRes);

        /////////////// END GET_USER_BY_ME //////////////
        print("Prod Debug" + getUserByMeResObj.toString());
        /////////////// GET_USER_PERMISSION //////////////
        var userId = getUserByMeResObj['resultData']['user_id'];
        var profileImageUrl =
            getUserByMeResObj['resultData']['image_profile_file'];
        var firstName = getUserByMeResObj['resultData']['firstname_th'];
        var lastName = getUserByMeResObj['resultData']['lastname_th'];
        var department = getUserByMeResObj['resultData']['emp_info']
            ['emp_department_info']['emp_department_name_th'];

        var getUserPermissionUrl = Uri.parse(
            '${dotenv.env['BASE_API']}${dotenv.env['GET_USER_PERMISSION_PATH']}?user_id=${userId}');

        var getUserPermissionRes =
            await getHttpWithToken(getUserPermissionUrl, token);
        print("Prod Debug LIST" + getUserPermissionRes.toString());
        List<PermissionResult> permissionList = [];

        print("Prod Debug" + permissionList.toString());
        permissionList =
            (jsonDecode(getUserPermissionRes)['resultData'] as List)
                .map((i) => PermissionResult.fromJson(i))
                .toList();

        print("Prod Debug LIST" + permissionList.toString());

        var permissionListCheck = permissionList.where((item) =>
            item.permissionId == "BUS_BOOKING_SYS" &&
            item.permissionRoleId == "BUS_BOOKING_SYS:DRIVER");

        print("Prod Debug LIST " + permissionListCheck.length.toString());

/* 
        var userPermissionId = getUserPermissionObj['resultData'][1]
            ['permission_info']['permission_id'];

        var userPermissionRoleId = getUserPermissionObj['resultData'][1]
            ['permission_role_info']['permission_role_id'];
 */
        /////////////// END GET_USER_PERMISSION //////////////

        if (getUserByMeResObj['resultData']['user_state_id'] != 'ACTIVE') {
          EasyLoading.showError(
              'บัญชีของของท่านถูกระงับ โปรดติดต่อผู้ดูแลระบบ');
          popped('บัญชีของของท่านถูกระงับ โปรดติดต่อผู้ดูแลระบบ', ctx);
          _btnController.reset();
        } else if (permissionListCheck.length == 0) {
          /*   EasyLoading.showError(
            'บัญชีของท่านไม่มีสิทธิ์การใช้งาน โปรดติดต่อผู้ดูแลระบบ'); */
          popped('บัญชีของท่านไม่มีสิทธิ์การใช้งาน โปรดติดต่อผู้ดูแลระบบ', ctx);
          _btnController.reset();
        } else {
          final storage = new FlutterSecureStorage();
          await storage.write(key: 'token', value: token);
          await storage.write(key: 'userId', value: userId);
          await storage.write(key: 'profileUrl', value: profileImageUrl ?? "");
          await storage.write(key: 'firstName', value: firstName);
          await storage.write(key: 'lastName', value: lastName);
          await storage.write(key: 'department', value: department);
          _btnController.success();
          Timer(Duration(seconds: 1), () {
            _completeLogin(ctx);
          });
        }
      } else if (authResObj['resultCode'] == '40302') {
        /*   EasyLoading.showError('บัญชีของของท่านถูกระงับ โปรดติดต่อผู้ดูแลระบบ'); */
        popped('บัญชีของของท่านถูกระงับ โปรดติดต่อผู้ดูแลระบบ', ctx);
        _btnController.reset();
      } else {
        /*    EasyLoading.showError('เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง'); */
        popped('เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง', ctx);
        _btnController.reset();
      }
    } catch (e) {
      print("Prod Debug LIST" + e.toString());
      popped('${dotenv.env['NO_INTERNET_CONNECTION']}', ctx);
      _btnController.reset();
    }
  }

  Future<void> popped(text, ctx) async {
    FToast fToast = FToast();
    fToast.init(ctx);

    /*     Fluttertoast.showToast(
          msg: "กดย้อนกลับอีกครั้งเพื่อปิด", toastLength: Toast.LENGTH_SHORT); */
    fToast.showToast(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 1, horizontal: 10),
          decoration: BoxDecoration(
              color: Color.fromRGBO(75, 132, 241, 1),
              borderRadius: BorderRadius.circular(20)),
          child: Center(
            child: Text(
              text,
              style: toastTextStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        toastDuration: Duration(seconds: 2));
  }
}
