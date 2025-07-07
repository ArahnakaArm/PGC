import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:pgc/model/notificationModel.dart';
import 'package:pgc/screens/changepassword_screen.dart';
import 'package:pgc/screens/exampleqr.dart';
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

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pgc/utilities/constants.dart';
import 'package:http/http.dart' as http;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("NOT SUPPPP");
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  AndroidNotificationChannel channel;

  /// Initialize the [FlutterLocalNotificationsPlugin] package.
  FlutterLocalNotificationsPlugin localNotification;
  var androidInitialize = new AndroidInitializationSettings('ic_launcher');
  var initialzationSettings =
      new InitializationSettings(android: androidInitialize);

  localNotification = new FlutterLocalNotificationsPlugin();

  localNotification.initialize(initialzationSettings);
  var androidDetails = new AndroidNotificationDetails(
      "channelId", "Work Notifications",
      importance: Importance.high, channelShowBadge: true);

  var generalNotificationDetails =
      new NotificationDetails(android: androidDetails);

  /*  final convertedData2 = json.decode(convertedData) as Map<String, dynamic>; */

  await localNotification.show(0, message.data['title'], message.data['body'],
      generalNotificationDetails);
  /* await flutterLocalNotificationsPlugin.cancel(0); */
  bool res = await FlutterAppBadger.isAppBadgeSupported();
  if (res) {
    FlutterAppBadger.updateBadgeCount(1);

    print("SUPPPP");
  } else {
    print("NOT SUPPPP");
  }

  print('Handling a background message ${message.messageId}');
}

/// Create a [AndroidNotificationChannel] for heads up notifications
AndroidNotificationChannel? channel;

/// Initialize the [FlutterLocalNotificationsPlugin] package.
FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  if (!kIsWebs) {
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      importance: Importance.max,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        ?.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel!);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
  /*  DotEnv envdebug = DotEnv(); */
  /* await dotenv.load(fileName: ".envdebug"); */
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
          child: child!,
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        );
      },
      title: "GPS Tracking",
      home: SplashScreen(),
    );
  }
}
