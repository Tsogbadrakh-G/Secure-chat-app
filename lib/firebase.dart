import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:secure_chat_app/helper/user_controller.dart';
import 'firebase_options.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
late AndroidNotificationChannel channel;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log("Handling a background message: ${message.messageId}");
  FirebaseUtils.onFirebaseBackgroundMsg(message);
}

final firebaseUtils = Provider((ref) => FirebaseUtils(ref: ref));

class FirebaseUtils {
  Ref ref;
  FirebaseUtils({required this.ref});
  init() async {
    await Firebase.initializeApp(name: "Chat app secure", options: DefaultFirebaseOptions.currentPlatform);
    await ref.read(notificationHandler).init();
    // Initialization section

    log("******************FIREBASE CONNECTION******************");
    try {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;
        log("+++++ +++++ +++++FIREBASE ON MESSAGE+++++ +++++ +++++");
        log(message.data.toString());
        log("${message.notification?.body}");

        if (notification != null && android != null && !kIsWeb) {
          flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(android: AndroidNotificationDetails(channel.id, channel.name)),
            payload: "username: ${message.data['username']}, message: ${notification.body}",
          );
        }
      });
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
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

  void getUserToken() async {
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    final user = FirebaseAuth.instance.currentUser;
    String? uid1 = user?.uid;
    log('my uid: $uid1');
    ref.read(userController.notifier).updateUserFCMtoken(uid1 ?? '', {'fcm_token': fcmToken ?? 'empty'});
    log('my token: $fcmToken');

    log("********************FIREBASE MESSAGE TOKEN******************");
    log(fcmToken.toString());
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
        payload: "username: ${message.data['username']}, message: ${notification.body}",
      );
    }

    if (message.data['navigation'] != null) {
      String route = message.data['navigation'];
      debugPrint('Navigate from firebase to the page with $route');
    }
  }
}

final notificationHandler = Provider((ref) => NotificationHandler(ref: ref));

class NotificationHandler {
  Ref ref;
  NotificationHandler({required this.ref});

  init() async {
    DarwinInitializationSettings initializationSettingsIOS = const DarwinInitializationSettings();
    AndroidInitializationSettings initializationSettingsAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher');
    InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveLocalNotification,
        onDidReceiveBackgroundNotificationResponse: onDidReceiveBackgroundNotificationResponse);

    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
        alert: true, announcement: false, badge: true, carPlay: false, criticalAlert: false, provisional: false, sound: true);

    debugPrint('User granted permission: ${settings.authorizationStatus}');

    if (!kIsWeb) {
      channel =
          const AndroidNotificationChannel('high_importance_channel', 'High Importance Notifications', importance: Importance.high, playSound: true);

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);
    }

    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
  }

  void onDidReceiveLocalNotification(NotificationResponse response) async {
    if (response.payload == null) return;
    log('payload: ${response.payload}');
    String username = response.payload!.split(",")[0].split(":")[1].trim();
    String message = response.payload!.split(",")[1].split(":")[1].trim();

    ref.read(userController.notifier).routeChatChannel(username, message);
  }

  getChatRoomIdbyUsername(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "${b}_$a";
    } else {
      return "${a}_$b";
    }
  }

  static void onDidReceiveBackgroundNotificationResponse(NotificationResponse response) async {
    log('onDidReceiveBackgroundNotificationResponse');
    log(response.toString());
  }
}
