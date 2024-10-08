import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_x/screens/sign_in_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/authentication.dart';
import '../utils/string_validation.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPassword();
}

class _ForgotPassword extends State<ForgotPassword> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    emailController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      centerTitle: true,
      title: const Text('Reset Password'),
    ),
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
            const Text("Receive an Email to reset your password",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            FutureBuilder(
              future: Authentication.initializeFirebase(context: context),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Error initializing Firebase');
                } else if (snapshot.connectionState == ConnectionState.done) {
                  return Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // EMAIL //
                        SizedBox(
                          width: 350,
                          height: 60,
                          child: TextFormField(
                            key: const ValueKey('emailResetPasswordField'),
                            controller: emailController,
                            //focusNode: widget.emailFocusNode,
                            validator: (value) => StringValidation.validateEmail(
                              email: value,
                            ),
                            cursorColor: Colors.black,
                            textInputAction: TextInputAction.next,
                            // keyboardType:
                            //     TextInputType.emailAddress, // special keyboard for email address
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.email,
                              ),
                              labelText: 'Email',
                              hintText: 'Enter Email',
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                borderSide: const BorderSide(
                                  // color: Colors.blue,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                borderSide: const BorderSide(
                                  // color: Colors.lightBlueAccent,
                                  width: 2.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _isSending
                            ? const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                            : Padding(
                          padding: const EdgeInsets.only(left: 0.0, right: 0.0),
                          child: SizedBox(
                            width: 350, // match_parent
                            child: ElevatedButton.icon(
                              key: const ValueKey('Reset Password'),
                              onPressed: () async {
                                setState(() {
                                  _isSending = true;
                                });

                                await resetPassword();

                                setState(() {
                                  _isSending = false;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(50),
                                backgroundColor: Colors.green.shade300,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                elevation: 15.0,
                              ),
                              icon: const Icon(Icons.mail_outline_rounded,
                                  size: 30, color: Colors.white),
                              label: const Text(
                                'Reset Password',
                                style: TextStyle(color: Colors.white, fontSize: 20),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white,
                  ),
                );
              },
            ),
          ],
        )
      ],
    ),
  );

  //Shows an error on bottom to notify users if the email
  void showEmailSnackbar() {
    Navigator.of(context).pop();
    Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const SignInScreen(),
        )
    );

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.black,
          content: Text(
            "Password reset email sent",
            style: TextStyle(color: Colors.lightGreenAccent, letterSpacing: 0.5),
          ),
        )
    );
  }
  
  Future resetPassword() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());
      showEmailSnackbar();
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print(e);
      }

      if(e.message == "The email address is badly formatted.") {
        ScaffoldMessenger.of(context).showSnackBar(
          Authentication.customSnackBar(
            content: 'Invalid email address format',
          ),
        );
      } else if (e.message == "There is no user record corresponding to this identifier. The user may have been deleted.") {
        ScaffoldMessenger.of(context).showSnackBar(
          Authentication.customSnackBar(
            content: 'Account not found',
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          Authentication.customSnackBar(
            content: '${e.message}',
          ),
        );
      }
    }
  }
}