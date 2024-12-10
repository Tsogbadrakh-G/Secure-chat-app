// ignore_for_file: must_be_immutable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:secure_chat_app/views/channel_screen.dart';

class ChatRoomCard extends ConsumerWidget {
  final String photoUrl, username;
  const ChatRoomCard({required this.photoUrl, required this.username, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.network(
                    photoUrl,
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                  )),
              const SizedBox(width: 20.0),
              Text(
                username,
                style: const TextStyle(
                  color: Color(0xff434347),
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Nunito',
                  fontSize: 18.0,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ChatRoomListTile extends ConsumerStatefulWidget {
  String username, photoUrl;

  ChatRoomListTile({
    required this.username,
    required this.photoUrl,
    super.key,
  });

  @override
  ConsumerState<ChatRoomListTile> createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends ConsumerState<ChatRoomListTile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.to(ChannelScreen(name: widget.username, imageUrl: widget.photoUrl)),
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
        padding: const EdgeInsets.symmetric(horizontal: 2),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20))),
        width: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  height: 65,
                  width: 65,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black.withOpacity(0.5)), borderRadius: const BorderRadius.all(Radius.circular(30))),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: CachedNetworkImage(
                      imageUrl: widget.photoUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 5.0,
                  ),
                  Text(
                    widget.username,
                    style: const TextStyle(color: Colors.black, fontSize: 17.0, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 30,
            ),
          ],
        ),
      ),
    );
  }
}

class UserAvatar extends StatelessWidget {
  final String filename;
  const UserAvatar({
    super.key,
    required this.filename,
  });

  @override
  Widget build(BuildContext context) {
    if (filename != '') {
      return CircleAvatar(
        radius: 32,
        backgroundColor: Colors.white,
        child: CircleAvatar(
          radius: 29,
          backgroundImage: Image.network(filename).image,
        ),
      );
    } else {
      return CircleAvatar(
        radius: 32,
        backgroundColor: Colors.white,
        child: CircleAvatar(
          radius: 29,
          backgroundImage: Image.asset('assets/images/boy1.jpg').image,
        ),
      );
    }
  }
}
