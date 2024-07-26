import 'package:flutter/material.dart';
import 'package:silence_is_hearable/screens/login_screen.dart';
import 'package:silence_is_hearable/screens/sign_up.dart';
import 'package:silence_is_hearable/widgets/custom_scaffold_widget.dart';
import 'package:silence_is_hearable/widgets/splash_buttons.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Padding(
        padding: const EdgeInsets.only(top: 400.0),
        child: Column(
          children: [
            Flexible(
              flex: 8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    margin: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8.0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      "Silence is Hearable",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w900,
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    margin: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8.0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Empowering Silence, Enhancing Communication',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.indigo,
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                  ),
                  const SizedBox(height: 0.0), // Add space between text boxes and the small text
                  const Text(
                    "Developed by Noor Ul Ain",
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 3,
              child: Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  children: [
                    Expanded(
                      child: SplashButtons(
                        buttonText: "Log In",
                        onTap: const SignInScreen(),
                        color: Colors.indigo.shade100,
                      ),
                    ),
                    Expanded(
                      child: SplashButtons(
                        buttonText: "Sign Up",
                        onTap: const SignUpScreen(),
                        color: Colors.teal.shade200,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
