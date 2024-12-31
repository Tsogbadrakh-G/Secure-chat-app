// ignore_for_file: must_be_immutable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ChatRoomCard extends ConsumerWidget {
  final String photoUrl, username;
  const ChatRoomCard({required this.photoUrl, required this.username, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      decoration: const BoxDecoration(
        color: Color.fromARGB(134, 188, 182, 182),
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: CachedNetworkImage(
              imageUrl: photoUrl,
              height: 60,
              width: 60,
              fit: BoxFit.cover,
            ),
          ),
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
    );
  }
}
