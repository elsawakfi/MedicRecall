import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_x/screens/sign_in_screen.dart';
import 'package:flashcard_x/utils/authentication.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'landing_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  static String id = 'verifyEmail';

  const VerifyEmailScreen({Key? key}) : super(key: key);

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool isEmailVerified = false;
  bool isVerifying = false;

  @override
  void initState() {
    super.initState();
    try {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
      if (!isEmailVerified) {
        sendVerificationEmail();
      }
    } catch(e) {
      Future.delayed(Duration.zero, ()
      {
        Navigator.of(context).pop();
        Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const SignInScreen(),
            )
        );
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  //Sends an email to the users email to verify
  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  //Shows an error on bottom to notify users if the email
  void showError() {
    ScaffoldMessenger.of(context).showSnackBar(
      Authentication.customSnackBar(
        content: 'Email not Verified',
      ),
    );
  }

  //If the email has been verified you are directed to landing screen else you just stay on the page until you verify it.
  @override
  Widget build(BuildContext context) => isEmailVerified
      ? const Landing()
      :  Scaffold(
      appBar: AppBar(
        centerTitle: true,
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
                //need to update logo to new one
                height: 130,
              ),
              const SizedBox(height: 20),
              const Text("Verify your Email address to continue!",
                  style:
                  TextStyle(fontSize: 38, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text("A verification email has been sent to your email.",
                  style:
                  TextStyle(fontSize: 20, fontWeight: FontWeight.normal)),
              const SizedBox(height: 20),
              //If it is in the process of verifying, the button will be loading else it is just a button.
              isVerifying
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
                  //Button to get status of if email has been verified.
                  child: ElevatedButton.icon(
                    key: const ValueKey('Click if Email has been verified'),

                    onPressed: () async {
                      setState(() {
                        isVerifying = true;
                      });

                      await FirebaseAuth.instance.currentUser!.reload();

                      setState(() {
                        isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
                      });

                      if (isEmailVerified == false) {
                        showError();
                      }

                      setState(() {
                        isVerifying = false;
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

                    icon: const Icon(Icons.mark_email_read_outlined,
                        size: 30, color: Colors.white),

                    label: const Text(
                      'Click if Email has been verified',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                //Resend email button
                children: [
                  const Text("Didn't receive an email? Click here to ",
                      style: TextStyle(fontSize: 19)),
                  GestureDetector(
                    onTap: () {
                      if (!isEmailVerified) {
                        sendVerificationEmail();
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Colors.black,
                              content: Text(
                                "Email resent",
                                style: TextStyle(color: Colors.lightGreenAccent, letterSpacing: 0.5),
                              ),
                            )
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          Authentication.customSnackBar(
                            content: 'Error sending verification email',
                          ),
                        );
                      }
                    },
                    child: const Text(
                      "Resend Email",
                      style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

