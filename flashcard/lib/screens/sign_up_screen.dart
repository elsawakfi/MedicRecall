import 'package:flashcard_x/widgets/registration_form.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  static String id = 'signup';

  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _nameFocusNode.unfocus();
        _emailFocusNode.unfocus();
        _passwordFocusNode.unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/newlogo.png',
                  // this file doesn't exist and generates error
                  height: 130,
                ),
                const SizedBox(height: 20),
                const Text("Sign Up",
                    style:
                        TextStyle(fontSize: 38, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                RegistrationForm(
                  nameFocusNode: _nameFocusNode,
                  emailFocusNode: _emailFocusNode,
                  passwordFocusNode: _passwordFocusNode,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
