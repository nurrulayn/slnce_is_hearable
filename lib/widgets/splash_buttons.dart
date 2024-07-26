import 'package:flutter/material.dart';

class SplashButtons extends StatelessWidget {
  const SplashButtons({super.key, this.buttonText, this.onTap, this.color});

  final String? buttonText;
  final Widget? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => onTap!,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(30.0),
        decoration: BoxDecoration(
          color: color!,
          // Add BorderRadius to make the button rectangular
          borderRadius: BorderRadius.circular(0),
        ),
        child: Text(
          buttonText!,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
