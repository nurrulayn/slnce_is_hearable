import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:silence_is_hearable/global/common/toast.dart';
import 'package:silence_is_hearable/widgets/form_container_widget.dart';

import '../firebase_auth_implementation/firebase_auth_services.dart';
import '../widgets/custom_scaffold_widget.dart';
import 'home_screen.dart';
import 'sign_up.dart'; // Import the SignUpScreen

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _isSigning = false;
  final FirebaseAuthService _auth = FirebaseAuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    setState(() {
      _isSigning = false;
    });
    return false; // Prevent navigation
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: CustomScaffold(
        child: Column(
          children: [
            const Expanded(
              flex: 3,
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
                    )),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        'LOG IN',
                        style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.w900,
                            color: Colors.teal.shade200),
                      ),
                      const SizedBox(
                        height: 30,
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
                      const SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: _signIn,
                        child: Container(
                          width: 200,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.teal.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: _isSigning
                                ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                                : const Text(
                              "Log In",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SignUpScreen()),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(
                              color: Colors.teal.shade200,
                              fontSize: 16.0,
                            ),
                            children: [
                              TextSpan(
                                text: "Sign up",
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

  void _signIn() async {
    setState(() {
      _isSigning = true;
    });

    String email = _emailController.text;
    String password = _passwordController.text;
    User? user = await _auth.signInWithEmailAndPassword(email, password);

    setState(() {
      _isSigning = false;
    });
    if (user != null) {
      showToast(message: "User is successfully Signed In");
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    } else {
      showToast(message: "Some error occurred");
    }
  }
}
