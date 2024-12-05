import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:secure_chat_app/helper/user_controller.dart';

import 'firebase_options.dart';
// import '../models/token/token.dart';
// import '../service/locator.dart';
// import '../service/navigation.dart';
// import '../service/dialog.dart';

late AndroidNotificationChannel channel;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log("Handling a background message: ${message.messageId}");
  FirebaseUtils.onFirebaseBackgroundMsg(message);
}

UserController _dataController = Get.find();

abstract class FirebaseUtils {
  static main() async {
    await Firebase.initializeApp(name: "Language Exchange Platform", options: DefaultFirebaseOptions.currentPlatform);
    // Initialization section
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveLocalNotification,
        onDidReceiveBackgroundNotificationResponse: onDidReceiveBackgroundNotificationResponse);

    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    // ?.requestPermission();
    // Initialization section end

    log("******************FIREBASE CONNECTION******************");
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
        alert: true, announcement: false, badge: true, carPlay: false, criticalAlert: false, provisional: false, sound: true);

    debugPrint('User granted permission: ${settings.authorizationStatus}');

    try {
      // final box = Hive.box(hiveBoxName);
      var fcmToken = await FirebaseMessaging.instance.getToken();
      _dataController.fcmToken = fcmToken ?? 'empty';
      _dataController.updateUserFCMtoken();
      log('my token: $fcmToken');
      // FirebaseMessaging.instance
      //     .sendMessage(to: fcmToken, data: {'message': 'mnessage'});

      // Token? token = box.get('token') as Token?;
      // if (fcmToken != null) {
      //   if (token != null) {
      //     token.fcmToken = fcmToken;
      //     await box.put('token', token);
      //   } else {
      //     await box.put('token', Token(fcmToken: fcmToken));
      //   }
      // }

      log("********************FIREBASE MESSAGE TOKEN******************");
      log(fcmToken.toString());

      if (!kIsWeb) {
        channel = const AndroidNotificationChannel('high_importance_channel', 'High Importance Notifications',
            importance: Importance.high, playSound: true);

        flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(channel);

        await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);
      }

      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;
        log("+++++ +++++ +++++FIREBASE ON MESSAGE+++++ +++++ +++++");
        log(message.data.toString());

        if (notification != null && android != null && !kIsWeb) {
          flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(channel.id, channel.name),
            ),
          );
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        log('onMessageOpenedApp : ');
        log(message.data.toString());

        if (message.data['navigation'] != null) {
          String route = message.data['navigation'];
          log('Navigate from firebase to the page with $route');
        }
      });
    } catch (err) {
      log("******************FIREBASE CONNECTION ERRROR******************");
      log(err.toString());
    }
  }

  static void onFirebaseBackgroundMsg(RemoteMessage message) async {
    // final box = Hive.box(hiveBoxName);
    // final lang = await box.get('lang');

    RemoteNotification? notification = message.notification;

    log('onFirebaseBackgroundMsg ${message.messageId}');
    log(message.data.toString());

    if (notification != null && !kIsWeb) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(channel.id, channel.name),
        ),
      );
    }

    if (message.data['navigation'] != null) {
      String route = message.data['navigation'];
      debugPrint('Navigate from firebase to the page with $route');
    }
  }

  static void onDidReceiveLocalNotification(NotificationResponse response) async {
    log('onDidReceiveLocalNotification');
    log(response.toString());
  }

  static void onDidReceiveBackgroundNotificationResponse(NotificationResponse response) async {
    log('onDidReceiveBackgroundNotificationResponse');
    log(response.toString());
  }
}
