import 'dart:convert';

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
import 'package:pgc/screens/unity/message.dart';
import 'package:pgc/screens/unity/message_list.dart';
import 'package:pgc/screens/unity/permissions.dart';
import 'package:pgc/screens/unity/token_monitor.dart';
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
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  AndroidNotificationChannel channel;

  /// Initialize the [FlutterLocalNotificationsPlugin] package.
  FlutterLocalNotificationsPlugin localNotification;
  var androidInitialize = new AndroidInitializationSettings('ic_launcher');
  var iOSInitialize = new IOSInitializationSettings();
  var initialzationSettings = new InitializationSettings(
      android: androidInitialize, iOS: iOSInitialize);

  localNotification = new FlutterLocalNotificationsPlugin();

  localNotification.initialize(initialzationSettings);
  var androidDetails = new AndroidNotificationDetails(
      "channelId", "Work Notifications", "Send Work Notification",
      importance: Importance.high, channelShowBadge: true);

  var iosDetails = new IOSNotificationDetails();
  var generalNotificationDetails =
      new NotificationDetails(android: androidDetails, iOS: iosDetails);

  /*  final convertedData2 = json.decode(convertedData) as Map<String, dynamic>; */

  await localNotification.show(0, message.data['title'], message.data['body'],
      generalNotificationDetails);
  await flutterLocalNotificationsPlugin.cancel(0);
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
AndroidNotificationChannel channel;

/// Initialize the [FlutterLocalNotificationsPlugin] package.
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  if (!kIsWebs) {
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      'This channel is used for important notifications.', // description
      importance: Importance.max,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
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
    /*    return MaterialApp(
      title: 'Messaging Example App',
      theme: ThemeData.dark(),
      routes: {
        '/': (context) => Application(),
        '/message': (context) => MessageView(),
      },
    ); */
  }
}

/// Renders the example application.
class Application extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Application();
}

class _Application extends State<Application> {
  String _token;

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage message) {
      if (message != null) {
        Navigator.pushNamed(context, '/message',
            arguments: MessageArguments(message, true));
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null && !kIsWebs) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                // TODO add a proper drawable resource to android, for now using
                //      one that already exists in example app.
                icon: 'launch_background',
              ),
            ));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      Navigator.pushNamed(context, '/message',
          arguments: MessageArguments(message, true));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Messaging'),
        actions: <Widget>[
          PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'subscribe',
                  child: Text('Subscribe to topic'),
                ),
                const PopupMenuItem(
                  value: 'unsubscribe',
                  child: Text('Unsubscribe to topic'),
                ),
                const PopupMenuItem(
                  value: 'get_apns_token',
                  child: Text('Get APNs token (Apple only)'),
                ),
              ];
            },
          ),
        ],
      ),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
          backgroundColor: Colors.white,
          child: const Icon(Icons.send),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          MetaCard('Permissions', Permissions()),
          MetaCard('FCM Token', TokenMonitor((token) {
            _token = token;
            return token == null
                ? const CircularProgressIndicator()
                : Text(token, style: const TextStyle(fontSize: 12));
          })),
          MetaCard('Message Stream', MessageList()),
        ]),
      ),
    );
  }
}

/// UI Widget for displaying metadata.
class MetaCard extends StatelessWidget {
  final String _title;
  final Widget _children;

  // ignore: public_member_api_docs
  MetaCard(this._title, this._children);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(left: 8, right: 8, top: 8),
        child: Card(
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child:
                          Text(_title, style: const TextStyle(fontSize: 18))),
                  _children,
                ]))));
  }
}
