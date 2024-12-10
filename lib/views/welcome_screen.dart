import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:secure_chat_app/login/login_screen.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreen();
}

class _WelcomeScreen extends ConsumerState<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: double.infinity,
      width: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 1 / 5,
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 80),
              width: double.infinity,
              child: const Text(
                'Secure chat!',
                style: TextStyle(
                    decoration: TextDecoration.none, fontSize: 25, fontWeight: FontWeight.w600, fontFamily: 'Nunito', color: Color(0xff434347)),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Image.asset(
              'assets/images/ic_splash.png',
              scale: 1.5,
            ),
            const SizedBox(
              height: 20,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Chat guardain',
                style: TextStyle(
                    decoration: TextDecoration.none,
                    fontSize: 25,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.normal,
                    color: Color(0xff0057ff)),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
              height: 80,
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const LogInScreen()));
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  backgroundColor: const Color(0xff0057ff),
                ),
                child: const Text(
                  'SIGN IN',
                  style: TextStyle(
                    decoration: TextDecoration.none,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future callDelay(BuildContext context) async {
    // print("call dellay21");
    await Future.delayed(const Duration(milliseconds: 5000), () {});
    //Get.to(const LogIn());
  }
}
