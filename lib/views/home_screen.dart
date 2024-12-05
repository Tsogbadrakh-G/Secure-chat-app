// ignore_for_file: must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:secure_chat_app/helper/user_controller.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends ConsumerState<HomeScreen> {
  UserController userController = Get.find<UserController>();

  saveUser() async {
    Map<String, dynamic> userInfoMap = {
      "Photo":
          "https://firebasestorage.googleapis.com/v0/b/language-exchange-app-cf264.appspot.com/o/images%2Fimg_profile.png?alt=media&token=82d48d53-f2d7-4c3c-8daa-930ce1253b72&_gl=1*1c3e9ai*_ga*MTAwMzU1OTkzMi4xNjc4OTc2OTE3*_ga_CW55HF8NVT*MTY5ODQ1ODE1OS41MC4xLjE2OTg0NjM0MTEuMjAuMC4w",
      "email": userController.email,
    };
    final user = FirebaseAuth.instance.currentUser;
    String? ui = user?.uid;

    await FirebaseFirestore.instance.collection("users").doc(ui).set(userInfoMap);
  }

  @override
  void initState() {
    saveUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: const Center(child: Text('Welcome to Secure Chat App!')),
    );
  }
}
