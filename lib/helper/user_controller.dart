import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart' hide FormData;
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';
import 'package:dio/dio.dart';
import 'package:secure_chat_app/helper/database_controller.dart';

class UserController extends GetxController {
  final dio = Dio();

  //Тухайн аппын нэвтэрсний дараа хэрэглэгчийн мэдээллийг хадгалах хувьсагчууд
  String id = '', myName = '', myUserName = '', key = '', email = '';
  Rx<String> picUrl = ''.obs;
  List<String> nativeLans = List.empty(growable: true);

  // Тухайн хэрэглэгчийн нийт уншаагүй чатын тоог хадгалах хувьсагч
  RxInt unreadChats = 0.obs;
  final firestoreInstance = FirebaseFirestore.instance;

  //Listener-д бүртгэгдсэн чат өрөөнүүдийн утгыг хадгалах хувьсагч
  List<String> activeChatroomListeners = [];

  //хэрэглэгчийн үүсгэсэн өрөөнүүдийн тоо
  RxInt roomsNum = 0.obs;

  // хэрэглэгчийн төрөлх хэлийг хадгалах хувьсагч
  String myNativeLan = '';

  String fcmToken = '';

  // ignore: non_constant_identifier_names
  Future<void> chatroomsLength() async {
    int len = 0;
    QuerySnapshot querySnapshot = await firestoreInstance.collection('chatrooms').get();

    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      String username = doc.id.replaceAll(myUserName, "");
      username = username.replaceAll("_", "");
      len++;
    }
    roomsNum.value = len;
  }

  void saveUser(String email, String username) {
    this.email = email;
    this.myUserName = username;
  }

  void setLastMessage(String chatroomId, Map<String, dynamic> lasMessageMap, bool read, String myUserName, String username) {
    Map<String, dynamic> lastMessageInfoMap = {
      "lastMessage": lasMessageMap['lastMessage'],
      "lastMessageSendTs": lasMessageMap['lastMessageSendTs'],
      "time": lasMessageMap['time'],
      "lastMessageSendBy": lasMessageMap['lastMessageSendBy'],
      "read": read,
      "to_msg_$myUserName": 0,
      "to_msg_$username": lasMessageMap['to_msg_$username']
    };

    DatabaseController.updateLastMessageSend(chatroomId, lastMessageInfoMap);
  }

  addMessage(String chatRoomId, String text, String from, String transto, String ousername, String oname) async {
    if (text != "") {
      String message = text;
      text = "";

      String messageId = randomAlphaNumeric(10);

      DateTime now = DateTime.now();
      String formattedDate = DateFormat('h:mma').format(now);

      Map<String, dynamic> messageInfoMap = {
        "id": messageId,
        "type": "text",
        "message": message,
        "sendBy": myUserName,
        "ts": now,
        "time": FieldValue.serverTimestamp(),
        "imgUrl": picUrl.value,
      };

      DocumentSnapshot ds = await FirebaseFirestore.instance.collection("chatrooms").doc(chatRoomId).get();
      Map<String, dynamic>? lastMessageData = ds.data() as Map<String, dynamic>;

      int to = 0;

      if (lastMessageData["lastMessage"] is String) {
        to = lastMessageData['to_msg_$ousername'] + 1;
      } else {
        to = 1;
      }

      DatabaseController.addMessage(chatRoomId, messageId, messageInfoMap).then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          "lastMessage": message,
          "lastMessageSendTs": formattedDate,
          "time": FieldValue.serverTimestamp(),
          "lastMessageSendBy": myUserName,
          "read": false,
          "to_msg_$myUserName": 0,
          "to_msg_$ousername": to,
          "sendByNameFrom": myName,
          "sendByNameTo": oname
        };
        DatabaseController.updateLastMessageSend(chatRoomId, lastMessageInfoMap);
      });

      ///!!! required below rows

      //String fcmUser = await fetchthisUserFCM(ousername, chatRoomId);

      //Data.sendNotifcation(fcmUser, myUserName, message);
    }
  }

  Future<void> updateUserFCMtoken() async {
    final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

    await usersCollection.doc(id).update({'fcm_$myUserName': fcmToken});
  }

  fetchthisUserFCM(String ousername, String chatroomID) async {
    ousername = chatroomID.replaceAll("_", "").replaceAll(myUserName, "");
    QuerySnapshot querySnapshot = await DatabaseController.getUserInfo(ousername.toUpperCase());
    final user = querySnapshot.docs[0].data() as Map<String, dynamic>;
    String fcm = "${user["fcm_$ousername"]}";

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
}
