// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:email_validator/email_validator.dart';
import 'package:secure_chat_app/firebase.dart';
import 'package:secure_chat_app/helper/alert.dart';
import 'package:secure_chat_app/helper/user_controller.dart';
import 'package:secure_chat_app/views/home_screen.dart';

class LogInScreen extends ConsumerStatefulWidget {
  const LogInScreen({super.key});

  @override
  ConsumerState<LogInScreen> createState() => _LogInState();
}

class _LogInState extends ConsumerState<LogInScreen> {
  String email = "", password = "", name = "", pic = "", username = "", id = "", userNativeLan = '';
  TextEditingController usermailcontroller = TextEditingController();
  TextEditingController userpasswordcontroller = TextEditingController();
  FocusNode focusNode1 = FocusNode();
  FocusNode focusNode2 = FocusNode();
  final UserController userController = Get.put(UserController());
  bool _isEmptyMail = false;
  bool _isEmptyPass = false;
  bool isValidMail = false;
  bool isValidPass = false;
  final _formkey = GlobalKey<FormState>();

  validator() {
    if (usermailcontroller.text.isEmpty) {
      _isEmptyMail = true;
      setState(() {});
    } else {
      _isEmptyMail = false;
    }
    if (userpasswordcontroller.text.isEmpty) {
      _isEmptyPass = true;
      setState(() {});
    } else {
      _isEmptyPass = false;
    }

    if (_isEmptyMail && _isEmptyPass) {
      Alerts.showMyDialog(context, 'Please enter your email and password!');
    } else if (_isEmptyMail) {
      Alerts.showMyDialog(context, 'Please enter your email!');
    } else if (_isEmptyPass) {
      Alerts.showMyDialog(context, 'Please enter your password!');
    }
  }

  userLogin() async {
    try {
      email = email.toLowerCase();
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);

      userController.saveUser(email);

      Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
      FirebaseUtils.main();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Alerts.showMyDialog(context, 'There are no registered users you have entered!');
      } else if (e.code == 'wrong-password') {
        Alerts.showMyDialog(context, 'The password you entered is incorrect!');
      } else if (e.code == 'invalid-email') {
        Alerts.showMyDialog(context, 'The email address you entered is incorrect!');
      } else if (e.code == 'INVALID_LOGIN_CREDENTIALS') {
        Alerts.showMyDialog(context, 'Please check that the password and email you entered are correct!');
      } else if (e.code == 'network-request-failed') {
        Alerts.showMyDialog(context, 'Make sure you are connected to the Internet!');
      }

      log('sign in exception: ${e.toString()}, code: ${e.code}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back)),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () {
          if (focusNode1.hasFocus) {
            FocusScope.of(context).requestFocus(FocusNode());
          }
          if (focusNode2.hasFocus) {
            FocusScope.of(context).requestFocus(FocusNode());
          }
        },
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10),
          width: double.infinity,
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/ic_splash.png',
                scale: 1.5,
              ),
              const SizedBox(
                height: 30,
              ),
              SizedBox(
                width: double.infinity,
                child: Form(
                  key: _formkey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextFormField(
                          onChanged: (value) {
                            setState(() {
                              isValidMail = EmailValidator.validate(value);
                            });
                          },
                          focusNode: focusNode1,
                          textAlignVertical: TextAlignVertical.center,
                          controller: usermailcontroller,
                          decoration: InputDecoration(
                            suffixIcon: isValidMail
                                ? const Icon(
                                    Icons.check_circle_outline,
                                    color: Color(
                                      0xff48D68A,
                                    ),
                                    size: 23,
                                  )
                                : Image.asset(
                                    'assets/images/img_login_exclamation.png',
                                    scale: 1.9,
                                  ),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(width: 1, color: Colors.black38),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                width: 1,
                                color: Color(0xff434347),
                              ),
                            ),
                            hintText: 'Email',
                            hintStyle: const TextStyle(color: Color(0xff434347), fontFamily: 'Nunito', fontWeight: FontWeight.normal, fontSize: 14),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: TextFormField(
                          onChanged: (value) {},
                          focusNode: focusNode2,
                          textAlignVertical: TextAlignVertical.center,
                          controller: userpasswordcontroller,
                          decoration: const InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(width: 1, color: Colors.black38),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                width: 1.5,
                                color: Color(0xff434347),
                              ),
                            ),
                            border: InputBorder.none,
                            hintText: 'Password',
                            hintStyle: TextStyle(color: Color(0xff434347), fontFamily: 'Nunito', fontWeight: FontWeight.normal, fontSize: 14),
                          ),
                          obscureText: true,
                        ),
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 35),
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                        child: ElevatedButton(
                          onPressed: () {
                            validator();
                            if (!_isEmptyMail && !_isEmptyPass) {
                              if (_formkey.currentState!.validate()) {
                                setState(() {
                                  email = usermailcontroller.text;
                                  password = userpasswordcontroller.text;
                                });
                              }
                              userLogin();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            backgroundColor: const Color(0xff0057ff),
                          ),
                          child: const Text(
                            'Sign in',
                            style: TextStyle(color: Colors.white, fontFamily: 'Nunito', fontWeight: FontWeight.normal, fontSize: 14),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
