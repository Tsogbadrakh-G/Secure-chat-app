import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:secure_chat_app/helper/user_controller.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChannelScreen extends ConsumerStatefulWidget {
  final String name;
  final String? imageUrl;
  const ChannelScreen({
    super.key,
    required this.name,
    this.imageUrl,
  });

  @override
  ConsumerState<ChannelScreen> createState() => _ChatPageState();
}

class Message {
  String message;
  String senderName;
  Message({required this.message, required this.senderName});
}

class _ChatPageState extends ConsumerState<ChannelScreen> {
  final userController = Get.find<UserController>();
  TextEditingController messagecontroller = TextEditingController();
  List<Message> messages = [];

  String key = '';
  final channel = WebSocketChannel.connect(
    Uri.parse('ws://192.168.4.28:3000'),
  );

  StreamBuilder? streamBuilder;
  @override
  void initState() {
    //  s

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          StreamBuilder(
            stream: channel.stream,
            builder: (context, snapshot) {
              log('snapshot: ${snapshot.data}');
              if (snapshot.hasData && (snapshot.data as String).contains(":")) {
                String senderName = snapshot.data.split(":")[0];
                String message = snapshot.data.split(":")[1];
                messages = [...messages, Message(message: message, senderName: senderName)];
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) => chatMessageTile(
                    messages[index].message,
                    messages[index].senderName == userController.myUserName,
                  ),
                );

                // return const SizedBox.shrink();
              }
              return const Text('');
            },
          ),
          Container(
            margin: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
            alignment: Alignment.bottomCenter,
            child: Material(
              elevation: 5.0,
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
                child: TextField(
                  controller: messagecontroller,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Type a message",
                      hintStyle: const TextStyle(color: Colors.black45),
                      suffixIcon: GestureDetector(
                          onTap: () {
                            log('send message');
                            FirebaseMessaging.instance.sendMessage();
                            channel.sink.add("${userController.myUserName}: ${messagecontroller.text}");
                          },
                          child: const Icon(
                            Icons.send_rounded,
                          ))),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget chatMessageTile(String message, bool sendByMe) {
    return Row(
      mainAxisAlignment: sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
            child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(24),
                  bottomRight: sendByMe ? const Radius.circular(0) : const Radius.circular(24),
                  topRight: const Radius.circular(24),
                  bottomLeft: sendByMe ? const Radius.circular(24) : const Radius.circular(0)),
              color: sendByMe ? const Color.fromARGB(255, 234, 236, 240) : const Color.fromARGB(255, 211, 228, 243)),
          child: Text(
            message,
            style: const TextStyle(color: Colors.black, fontSize: 15.0, fontWeight: FontWeight.w500),
          ),
        )),
      ],
    );
  }

  PreferredSizeWidget buildAppBar() {
    return AppBar(
      elevation: 0.5,
      automaticallyImplyLeading: false,
      toolbarHeight: 70,
      backgroundColor: Colors.white,
      flexibleSpace: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 70,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Image.asset('assets/images/ic_chevron_left.png', height: 20, width: 20, color: Colors.black),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.all(Radius.circular(30)),
                        border: Border.all(color: Colors.black.withOpacity(0.5))),
                    width: 60,
                    height: 60,
                    child: widget.imageUrl != null
                        ? ClipRRect(
                            borderRadius: const BorderRadius.all(Radius.circular(30)),
                            child: Image.network(
                              widget.imageUrl!,
                              fit: BoxFit.fill,
                            ))
                        : const Offstage(),
                  ),
                  const SizedBox(width: 15),
                  Text(
                    widget.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(width: 10)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
