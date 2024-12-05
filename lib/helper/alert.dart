import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Alerts {
  static Future<void> showMyDialog(BuildContext context, String s1) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          actionsPadding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
          contentPadding: const EdgeInsets.fromLTRB(20, 20, 10, 10),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(s1),
                //Text('Would you like to approve of this message?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Ok',
                style: TextStyle(color: Color.fromARGB(255, 114, 159, 226), fontFamily: 'Nunito', fontWeight: FontWeight.normal, fontSize: 14),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> alertVideoCall(
    String s1,
    Function() button1,
    Function() button2,
  ) {
    return Get.defaultDialog(
      title: 'Ирэх дуудлага',
      content: Text(
        'Танд $s1 хэрэглэгчээс видео дуудлага ирж байна.',
        style: const TextStyle(fontFamily: 'Nunito', height: 1.2),
      ),
      confirm: Transform.scale(
        scale: 1,
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(30)),
          child: FloatingActionButton(
              backgroundColor: Colors.green, foregroundColor: Colors.white, onPressed: button1, child: const Icon(Icons.call_end)),
        ),
      ),
      cancel: Transform.scale(
        scale: 1,
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(30)),
          child:
              FloatingActionButton(backgroundColor: Colors.red, foregroundColor: Colors.white, onPressed: button2, child: const Icon(Icons.call_end)),
        ),
      ),
    );
  }

  static Future<void> alertBoxVertical({
    required Widget textWidget,
    required Widget titleWidget,
    required Function() button1,
    required Function() button2,
    Function()? onClose,
    String imgAsset = '',
    String button1Text = '',
    String button2Text = '',
  }) async {
    return await Get.dialog(
      AlertDialog(
        contentPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        content: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color(0xffffffff),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  // ClipRRect(
                  //   borderRadius: BorderRadius.circular(10),
                  //   child: Image.asset(
                  //     'assets/images/$imgAsset.png',
                  //   ),
                  // ),
                  Positioned.fill(
                    right: 10,
                    top: 10,
                    child: Align(
                      alignment: Alignment.topRight,
                      child: InkWell(
                        onTap: onClose ?? Get.back,
                        child: Image.asset(
                          'assets/images/alert/alert_back.png',
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 5.0),
              titleWidget,
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: textWidget,
              ),
              const SizedBox(height: 15.0),
              LimeTextButton(
                onTap: button1,
                text: button1Text,
                textColor: const Color(0xffd0ff14),
                margin: const EdgeInsets.symmetric(horizontal: 22),
              ),
              const SizedBox(height: 4),
              LimeTextButton(
                onTap: button2,
                text: button2Text,
                textColor: const Color(0xffd0ff14),
                margin: const EdgeInsets.symmetric(horizontal: 22),
              ),
              const SizedBox(height: 19),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}

class LimeTextButton extends StatelessWidget {
  final Color? color;
  final double? height;
  final EdgeInsets margin;
  final EdgeInsets? padding;
  final Function()? onTap;
  final String text;
  final Color? textColor;
  final double? width;
  final double? elevation;
  const LimeTextButton({
    required this.text,
    required this.margin,
    this.padding,
    this.onTap,
    this.color,
    this.height,
    this.width,
    this.elevation,
    this.textColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height ?? 50,
      margin: margin,
      child: TextButton(
        onPressed: onTap,
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          foregroundColor: WidgetStateProperty.all(textColor ?? Colors.white),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) {
              if (states.contains(WidgetState.disabled)) {
                return const Color(0xffcccccc);
              }

              return color ?? const Color(0xff000000);
            },
          ),
          elevation: WidgetStateProperty.all(elevation ?? 0),
          padding: WidgetStateProperty.all(
            padding ?? const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          //  style: LimeStyles.rubikMedium16x18.copyWith(color: textColor ?? Colors.white),
        ),
      ),
    );
  }
}
