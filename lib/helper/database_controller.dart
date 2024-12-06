// ignore_for_file: prefer_final_fields

import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:get/get.dart';
import 'package:secure_chat_app/helper/user_controller.dart';

class DatabaseController {
  static UserController _dataController = Get.find();

  static Future addUserDetails(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance.collection("users").doc(id).set(userInfoMap);
  }

  static Future<QuerySnapshot> getUserbyemail(String email) async {
    return await FirebaseFirestore.instance.collection("users").where("E-mail", isEqualTo: email).get();
  }

  static Future<List<Map<String, dynamic>>> search(String username) async {
    List<Map<String, dynamic>> users = [];
    final snapshot = await FirebaseFirestore.instance.collection("users").get();
    for (var doc in snapshot.docs) {
      if ((doc.data()['username'] as String).contains(username)) users.add(doc.data());
    }

    return users;
  }

  static createChatRoom(String chatRoomId, Map<String, dynamic> chatRoomInfoMap) async {
    final snapshot = await FirebaseFirestore.instance.collection("chatrooms").doc(chatRoomId).get();
    if (snapshot.exists) {
      return true;
    } else {
      return FirebaseFirestore.instance.collection("chatrooms").doc(chatRoomId).set(chatRoomInfoMap);
    }
  }

  static Future addMessage(String chatRoomId, String messageId, Map<String, dynamic> messageInfoMap) async {
    return FirebaseFirestore.instance.collection("chatrooms").doc(chatRoomId).collection("chats").doc(messageId).set(messageInfoMap);
  }

  static updateLastMessageSend(String chatRoomId, Map<String, dynamic> lastMessageInfoMap) {
    return FirebaseFirestore.instance.collection("chatrooms").doc(chatRoomId).update(lastMessageInfoMap);
  }

  static Future<Stream<QuerySnapshot>> getChatRoomMessages(chatRoomId) async {
    return FirebaseFirestore.instance.collection("chatrooms").doc(chatRoomId).collection("chats").orderBy("time", descending: true).snapshots();
  }

  static Future<QuerySnapshot> getUserInfo(String username) async {
    return await FirebaseFirestore.instance.collection("users").where("username", isEqualTo: username).get();
  }

  static Future<Stream<QuerySnapshot>> getChatRooms() async {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .orderBy("time", descending: true)
        .where("users", arrayContains: _dataController.myUserName)
        .snapshots();
  }

  static void deleteChatroom(String chatroomId) async {
    try {
      // Reference to your Firestore collection (replace 'chatrooms' with your collection name).
      CollectionReference chatrooms = FirebaseFirestore.instance.collection('chatrooms');

      // Use the document ID to delete the chatroom.
      await chatrooms.doc(chatroomId).delete();
      log('Chatroom deleted successfully.');
    } catch (e) {
      log('Error deleting chatroom: $e');
    }
  }
}
