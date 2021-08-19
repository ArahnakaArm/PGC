import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pgc/screens/changepassword_screen.dart';
import 'package:pgc/screens/history.dart';
import 'package:pgc/screens/processwork.dart';
import 'package:pgc/screens/setting_screen.dart';
import 'package:pgc/screens/splash_screen.dart';
import 'package:pgc/screens/worklist.dart';
import 'package:pgc/screens/checkin.dart';
import 'package:pgc/screens/scanandlist.dart';
import 'package:pgc/screens/confirmfinishjob.dart';
import 'package:pgc/screens/login_screen.dart';
import 'package:pgc/screens/successfinishjob.dart';
import 'package:pgc/screens/mainmenu_screen.dart';
import 'package:pgc/screens/successfinishjob.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Color.fromRGBO(75, 132, 241, 1)));
    return MaterialApp(
      builder: (context, child) {
        return MediaQuery(
          child: child,
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        );
      },
      title: "GPS Tracking",
      home: SplashScreen(),
    );
  }
}
