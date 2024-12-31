import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:secure_chat_app/helper/user_controller.dart';

import 'firebase_options.dart';

late AndroidNotificationChannel channel;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log("Handling a background message: ${message.messageId}");
  FirebaseUtils.onFirebaseBackgroundMsg(message);
}

class FirebaseUtils {
  static AndroidInitializationSettings initializationSettingsAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher');
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static init(WidgetRef ref) async {
    await Firebase.initializeApp(name: "Chat app secure", options: DefaultFirebaseOptions.currentPlatform);
    // Initialization section

    DarwinInitializationSettings initializationSettingsIOS = const DarwinInitializationSettings();
    InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveLocalNotification,
        onDidReceiveBackgroundNotificationResponse: onDidReceiveBackgroundNotificationResponse);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();

    // ?.requestPermission();
    // Initialization section end

    log("******************FIREBASE CONNECTION******************");
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
        alert: true, announcement: false, badge: true, carPlay: false, criticalAlert: false, provisional: false, sound: true);

    debugPrint('User granted permission: ${settings.authorizationStatus}');

    try {
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      final user = FirebaseAuth.instance.currentUser;
      String? uid1 = user?.uid;
      ref.read(userController.notifier).updateUserFCMtoken(uid1 ?? '', {'fcm_token': fcmToken ?? 'empty'});

      log('my token: $fcmToken');

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
