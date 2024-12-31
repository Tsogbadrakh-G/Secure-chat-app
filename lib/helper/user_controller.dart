import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:secure_chat_app/helper/database_controller.dart';

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

  static Future<void> sendNotifcation(String toToken, String name, String content) async {
    final dio = Dio();

    String localUrl = 'http://13.125.68.71:5000/sendChat';

    FormData formData = FormData.fromMap({'fcm': toToken, 'name': name, 'content': content});

    dio.get(
      localUrl,
      data: formData,
      options: Options(headers: {"Content-Type": "multipart/form-data"}),
    );
  }

  getChatRoomIdbyUsername(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "${b}_$a";
    } else {
      return "${a}_$b";
    }
  }
}
