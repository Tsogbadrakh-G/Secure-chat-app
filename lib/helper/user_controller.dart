import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:secure_chat_app/helper/database_controller.dart';
import 'package:secure_chat_app/main.dart';
import 'package:secure_chat_app/views/channel_screen.dart';
import 'package:secure_chat_app/views/welcome_screen.dart';

final dio = Dio();
final userController = StateNotifierProvider<UserController, UserState>((ref) => UserController());

class UserState {
  final String usrId;
  final String myUserName;
  final String email;
  const UserState(
    this.usrId,
    this.myUserName,
    this.email,
  );

  UserState copyWith({
    final usrId,
    final myUserName,
    final email,
  }) {
    return UserState(
      usrId ?? this.usrId,
      myUserName ?? this.myUserName,
      email ?? this.email,
    );
  }
}

class UserController extends StateNotifier<UserState> {
  UserController() : super(const UserState('', '', ''));

  Future<void> saveUserInfoToCloud(Map<String, dynamic> json, String uid) async {
    await FirebaseFirestore.instance.collection("users").doc(uid).set(json);
  }

  void saveUser(String email, String username) {
    state = state.copyWith(myUserName: username, email: email);
  }

  Future<void> updateUserFCMtoken(String uid, Map<String, dynamic> json) async {
    final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
    await usersCollection.doc(uid).update(json);
  }

  Future<String> fetchThisUserFCM(String chatroomID) async {
    String username = chatroomID.replaceAll("_", "").replaceAll(state.myUserName, "");
    QuerySnapshot querySnapshot = await DatabaseController.getUserInfo(username);
    final user = querySnapshot.docs[0].data() as Map<String, dynamic>;
    String fcm = "${user["fcm_token"]}";

    log('fcm: $fcm');

    return fcm;
  }

  Future<String> fetchThisUserId(String username) async {
    QuerySnapshot querySnapshot = await DatabaseController.getUserInfo(username.toUpperCase());
    final user = querySnapshot.docs[0].data() as Map<String, dynamic>;
    String fcm = "${user["Id"]}";

    return fcm;
  }

  Future<void> sendMessage(String receiverFcm, String message) async {
    dio.post('http://$hostname:3000/', data: {
      'fcm': receiverFcm,
      'message': message,
      'sender_username': state.myUserName,
    });
  }

  getChatRoomIdbyUsername(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "${b}_$a";
    } else {
      return "${a}_$b";
    }
  }

  routeChatChannel(String username, String message) => navigatorKey.currentState?.push(MaterialPageRoute(
        builder: (context) => ChannelScreen(
          name: username,
          chatRoomId: getChatRoomIdbyUsername(username, state.myUserName),
          message: message,
        ),
      ));

  // static Future<void> sendNotifcation(String toToken, String name, String content) async {
  //   final dio = Dio();

  //   String localUrl = 'http://13.125.68.71:5000/sendChat';

  //   FormData formData = FormData.fromMap({'fcm': toToken, 'name': name, 'content': content});

  //   dio.get(
  //     localUrl,
  //     data: formData,
  //     options: Options(headers: {"Content-Type": "multipart/form-data"}),
  //   );
  // }
}

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const WelcomeScreen()); // Replace with your home screen
      case '/channel':
        if (args != null) {
          return MaterialPageRoute(
            builder: (_) => ChannelScreen(
              name: args['name'],
              chatRoomId: args['chatRoomId'],
              imageUrl: args['imageUrl'],
              message: args['message'],
            ),
          );
        }
        return _errorRoute();
      // Add more cases for other routes
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('ERROR: Route not found'),
        ),
      );
    });
  }
}
