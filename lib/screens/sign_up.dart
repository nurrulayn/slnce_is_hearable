import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:silence_is_hearable/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:silence_is_hearable/global/common/toast.dart';
import 'package:silence_is_hearable/screens/login_screen.dart';
import 'package:silence_is_hearable/widgets/form_container_widget.dart';

import '../widgets/custom_scaffold_widget.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool isSigningUp = false;
  final FirebaseAuthService _auth = FirebaseAuthService();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Return false to prevent navigation
        return false;
      },
      child: CustomScaffold(
        child: Column(
          children: [
            const Expanded(
              flex: 2,
              child: SizedBox(
                height: 50,
              ),
            ),
            Expanded(
              flex: 7,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40.0),
                    topRight: Radius.circular(40.0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        'SIGN UP',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: Colors.teal.shade200,
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      FormContainerWidget(
                        controller: _usernameController,
                        hintText: "username",
                        isPasswordField: false,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      FormContainerWidget(
                        controller: _emailController,
                        hintText: "email@example.com",
                        isPasswordField: false,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      FormContainerWidget(
                        controller: _passwordController,
                        hintText: "password",
                        isPasswordField: true,
                      ),
                      const SizedBox(height: 25),
                      GestureDetector(
                        onTap: () {
                          _signUp();
                        },
                        child: Container(
                          width: 200,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.teal.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: isSigningUp
                                ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                                : const Text(
                              "Sign Up",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SignInScreen()),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            text: "Already have an account? ",
                            style: TextStyle(
                              color: Colors.teal.shade200,
                              fontSize: 16.0,
                            ),
                            children: [
                              TextSpan(
                                text: "Login",
                                style: TextStyle(
                                  color: Colors.teal.shade200,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _signUp() async {
    setState(() {
      isSigningUp = true;
    });

    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    User? user = await _auth.signUpWithEmailAndPassword(email, password);

    setState(() {
      isSigningUp = false;
    });

    if (user != null) {
      showToast(message: "User is successfully created");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SignInScreen()),
      );
    } else {
      showToast(message: "Some error occurred");
    }
  }
}
