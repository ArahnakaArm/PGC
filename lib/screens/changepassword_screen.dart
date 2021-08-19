import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pgc/services/http/putHttpWithToken.dart';
import 'package:pgc/utilities/constants.dart';
import 'package:pgc/widgets/background.dart';
import 'package:pgc/widgets/backpress.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key key}) : super(key: key);

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool _showOldPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmNewPassword = false;
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  TextEditingController oldPasswordController = new TextEditingController();
  TextEditingController newPasswordController = new TextEditingController();
  TextEditingController confirmNewPasswordController =
      new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            BackGround(),
            Container(
                height: double.infinity,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          BackPress(context),
                          SizedBox(height: 25.0),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.0,
                            ),
                            child: Text(
                              'รหัสผ่านเดิม',
                              style: loginLabelStyle,
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Container(
                            alignment: Alignment.centerLeft,
                            decoration: loginDecorationStyle,
                            height: 58.0,
                            child: TextField(
                              controller: oldPasswordController,
                              textAlign: TextAlign.left,
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(left: 18),
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _showOldPassword = !_showOldPassword;
                                    });
                                  },
                                  child: Icon(_showOldPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                ),
                                border: InputBorder.none,
                                hintText: 'รหัสผ่านเดิม',
                              ),
                              obscureText: !_showOldPassword,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 18),
                            ),
                          ),
                          SizedBox(height: 15.0),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.0,
                            ),
                            child: Text(
                              'รหัสผ่านใหม่',
                              style: loginLabelStyle,
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Container(
                            alignment: Alignment.centerLeft,
                            decoration: loginDecorationStyle,
                            height: 58.0,
                            child: TextField(
                              controller: newPasswordController,
                              textAlign: TextAlign.left,
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(left: 18),
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _showNewPassword = !_showNewPassword;
                                    });
                                  },
                                  child: Icon(_showNewPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                ),
                                border: InputBorder.none,
                                hintText: 'รหัสผ่านใหม่',
                              ),
                              obscureText: !_showNewPassword,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 18),
                            ),
                          ),
                          SizedBox(height: 15.0),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.0,
                            ),
                            child: Text(
                              'ยืนยันรหัสผ่านใหม่',
                              style: loginLabelStyle,
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Container(
                            alignment: Alignment.centerLeft,
                            decoration: loginDecorationStyle,
                            height: 58.0,
                            child: TextField(
                              controller: confirmNewPasswordController,
                              textAlign: TextAlign.left,
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(left: 18),
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _showConfirmNewPassword =
                                          !_showConfirmNewPassword;
                                    });
                                  },
                                  child: Icon(_showConfirmNewPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                ),
                                border: InputBorder.none,
                                hintText: 'ยืนยันรหัสผ่านใหม่',
                              ),
                              obscureText: !_showConfirmNewPassword,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 18),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 35,
                      ),
                      RoundedLoadingButton(
                        color: Color.fromRGBO(240, 173, 78, 1),
                        height: 58,
                        borderRadius: 18,
                        child: Text('เปลี่ยนรหัสผ่าน',
                            style: TextStyle(color: Colors.white)),
                        controller: _btnController,
                        onPressed: () {
                          _changePasswordValidate(
                              oldPasswordController.text,
                              newPasswordController.text,
                              confirmNewPasswordController.text,
                              context);
                        },
                      )
                      /*    GestureDetector(
                        onTap: () {
                          _changePasswordValidate(
                              oldPasswordController.text,
                              newPasswordController.text,
                              confirmNewPasswordController.text,
                              context);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: loginSubmitDecorationStyle,
                          height: 58.0,
                          child: Text(
                            'เปลี่ยนรหัสผ่าน',
                            style: submitTextStyle,
                          ),
                        ),
                      ), */
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
    ;
  }

  void _changePasswordValidate(oldPass, newPass, confirmNewPass, ctx) async {
    FocusScope.of(context).unfocus();
    bool newPasswordValid =
        RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{6,}$')
            .hasMatch(newPass);

    bool confirmNewPasswordValid =
        RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{6,}$')
            .hasMatch(confirmNewPass);

    if (newPass != confirmNewPass) {
      popped('กรุณากรอกรหัสผ่านใหม่และยืนยันรหัสผ่านใหม่ให้เหมือนกัน', ctx);
      _btnController.reset();
    } else if (!newPasswordValid) {
      popped('กรุณากรอกรหัสผ่านใหม่ให้ถูกต้อง', ctx);
      _btnController.reset();
    } else if (!confirmNewPasswordValid) {
      popped('กรุณากรอกยืนยันรหัสผ่านใหม่ให้ถูกต้อง', ctx);
      _btnController.reset();
    } else {
      await _changePassword(oldPass, newPass, confirmNewPass, ctx);
    }
  }

  Future<void> _changePassword(oldPass, newPass, confirmNewPass, ctx) async {
    final storage = new FlutterSecureStorage();
    String userId = await storage.read(key: 'userId');
    String token = await storage.read(key: 'token');

    var changePasswordId = ("${dotenv.env['POST_CHANGE_PASSWORD_PATH']}")
        .replaceFirst('userid', userId);
    var changePasswordUrl =
        Uri.parse('${dotenv.env['BASE_API']}${changePasswordId}');
    var changePassBody = {"oldPassword": oldPass, "newPassword": newPass};

    /*  EasyLoading.show(status: 'loading...'); */
    var res = await postHttpWithToken(changePasswordUrl, token, changePassBody);

    Map<String, dynamic> resObj = jsonDecode(res);
    if (resObj['resultCode'] == '40900') {
      /*    EasyLoading.showError('รหัสผ่านเดิมไม่ถูกต้อง'); */
      popped('รหัสผ่านเดิมไม่ถูกต้อง', ctx);
      _btnController.reset();
    } else if (resObj['resultCode'] == '20000') {
/*       EasyLoading.showSuccess('สำเร็จ! ระบบได้บันทึกข้อมูลแล้ว'); */
      popped('สำเร็จ! ระบบได้บันทึกข้อมูลแล้ว', ctx);

      _btnController.success();
      Timer(Duration(seconds: 1), () {
        _destroyActivity(ctx);
      });
    } else {
      EasyLoading.showError('เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง');
      popped('เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง', ctx);
      _btnController.reset();
    }
  }
}

void _backPress(context) {
  Navigator.pop(context);
}

GestureDetector _backButton(context) {
  return GestureDetector(
    onTap: () {
      _backPress(context);
    },
    child: Image.asset(
      'assets/images/backarrow.png',
      height: 25,
    ),
  );
}

Future<bool> popped(text, ctx) {
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

void _destroyActivity(context) {
  Navigator.pop(context);
}
