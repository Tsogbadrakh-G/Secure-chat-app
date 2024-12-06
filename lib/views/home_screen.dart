// ignore_for_file: must_be_immutable

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:secure_chat_app/helper/database_controller.dart';
import 'package:secure_chat_app/helper/user_controller.dart';

class HomeScreen extends StatefulHookConsumerWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends ConsumerState<HomeScreen> {
  UserController userController = Get.find<UserController>();
  TextEditingController textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final tempSearchStore = StateProvider<List<Map<String, dynamic>>>((ref) => []);
  final isFocused = StateProvider<bool>((ref) => false);
  saveUser() async {
    final regex = RegExp(r'^([^@]+)@');
    final match = regex.firstMatch(userController.email);
    String username = '';
    if (match != null) {
      username = match.group(1)!; // Extracts 'test'
    }
    Map<String, dynamic> userInfoMap = {
      "Photo":
          "https://firebasestorage.googleapis.com/v0/b/language-exchange-app-cf264.appspot.com/o/images%2Fimg_profile.png?alt=media&token=82d48d53-f2d7-4c3c-8daa-930ce1253b72&_gl=1*1c3e9ai*_ga*MTAwMzU1OTkzMi4xNjc4OTc2OTE3*_ga_CW55HF8NVT*MTY5ODQ1ODE1OS41MC4xLjE2OTg0NjM0MTEuMjAuMC4w",
      "email": userController.email,
      'username': username
    };
    final user = FirebaseAuth.instance.currentUser;
    String? ui = user?.uid;

    await FirebaseFirestore.instance.collection("users").doc(ui).set(userInfoMap);

    final usrs = await FirebaseFirestore.instance.collection("users");
  }

  @override
  void initState() {
    saveUser();
    _focusNode.addListener(() {
      log('focus: ${_focusNode.hasFocus}');
      if (_focusNode.hasFocus) {
        ref.read(isFocused.notifier).state = true;
      } else {
        ref.read(isFocused.notifier).state = false;
        ref.read(tempSearchStore.notifier).state = [];
      }
    });
    super.initState();
  }

  initiateSearch(String value) {
    log('value: $value');
    if (value.isEmpty) {
      ref.read(tempSearchStore.notifier).state = [];
      return;
    }
    DatabaseController.search(value).then((List<Map<String, dynamic>> usrs) {
      ref.read(tempSearchStore.notifier).state = usrs;

      log('tempSearchStore: ${ref.read(tempSearchStore)}');
    });
  }

  getChatRoomIdbyUsername(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "${b}_$a";
    } else {
      return "${a}_$b";
    }
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(tempSearchStore);
    final focused = ref.watch(isFocused);
    final onchange = useState(false);
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: const SizedBox(),
          backgroundColor: Colors.white,
          title: const Text('Home Screen'),
        ),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              elevation: 0,
              floating: true,
              titleSpacing: 0,
              automaticallyImplyLeading: false,
              backgroundColor: Colors.white,
              title: Container(
                height: 40,
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: TextField(
                  cursorHeight: 25,
                  controller: textEditingController,
                  textAlignVertical: TextAlignVertical.center,
                  focusNode: _focusNode,
                  textAlign: focused ? TextAlign.start : TextAlign.center,
                  autocorrect: true,
                  textCapitalization: TextCapitalization.words,
                  onChanged: (value) {
                    onchange.value = !onchange.value;
                    initiateSearch(value);
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    suffixIcon: IconButton(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      icon: focused
                          ? const Icon(
                              size: 25,
                              Icons.close,
                              color: Color(0Xff2675EC),
                            )
                          : const Icon(
                              size: 25,
                              Icons.search,
                              color: Color(0Xff2675EC),
                            ),
                      onPressed: () {
                        if (focused) {
                          _focusNode.unfocus();
                          textEditingController.clear();
                          ref.read(tempSearchStore.notifier).state = [];
                        } else {
                          _focusNode.requestFocus();
                        }
                      },
                    ),
                    border: const OutlineInputBorder(borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 205, 205, 206),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 205, 205, 206), // Set the border color when focused
                      ),
                    ),
                    hintText: 'Search',
                    hintStyle: TextStyle(
                      fontFamily: "Manrope",
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xff3c3c43).withOpacity(0.5),
                      //height: 22 / 17,
                    ),
                  ),
                  style: const TextStyle(
                      decoration: TextDecoration.none, color: Colors.black, fontFamily: 'Nunito', fontSize: 15.0, fontWeight: FontWeight.w400),
                ),
              ),
            ),
            if (focused) ...[
              SliverPadding(
                padding: const EdgeInsets.only(top: 5),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      // Build the list of items

                      return ListView(
                          padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                          primary: false,
                          shrinkWrap: true,
                          children: ref.read(tempSearchStore).map((element) {
                            return InkWell(
                              onTap: () async {
                                log('username: ${userController.myUserName}, oth usrname: ${element["username"]}');
                                String chatRoomId = getChatRoomIdbyUsername(userController.myUserName, element["username"]);
                                final snapshot = await FirebaseFirestore.instance.collection("chatrooms").doc(chatRoomId).get();
                                if (!snapshot.exists) {
                                  return FirebaseFirestore.instance.collection("chatrooms").doc(chatRoomId).set({'test': 'test'});
                                }
                              },
                              child: Container(
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
                                              element["Photo"],
                                              height: 60,
                                              width: 60,
                                              fit: BoxFit.cover,
                                            )),
                                        const SizedBox(
                                          width: 20.0,
                                        ),
                                        Text(
                                          element["username"],
                                          style: const TextStyle(
                                              color: Color(0xff434347), fontWeight: FontWeight.w500, fontFamily: 'Nunito', fontSize: 18.0),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                            //return _helperController.buildResultCard(element, search);
                          }).toList());
                    },
                    childCount: 1, // Number of items in the list
                  ),
                ),
              )
            ] else if (users.isEmpty) ...[
              SliverToBoxAdapter(
                child: SizedBox(
                    height: MediaQuery.sizeOf(context).height * 2 / 3,
                    // decoration: BoxDecoration(border: Border.all()),
                    child: const Center(
                        child: Text(
                      'No item',
                      style: TextStyle(fontFamily: 'Nunito'),
                    ))),
              )
            ] else ...[
              SliverPadding(
                padding: const EdgeInsets.only(top: 5),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      // Build the list of items
                      return Text('chatroom sample');
                      // return chatRoomList();
                    },
                    childCount: 1, // Number of items in the list
                  ),
                ),
              )
            ]
          ],
        )

        //const Center(child: Text('Welcome to Secure Chat App!')),
        );
  }
}
