import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_x/utils/authentication.dart';
import 'package:flutter/material.dart';

import '../screens/landing_screen.dart';

class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({Key? key}) : super(key: key);

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _isSigningIn = false;

  @override
  Widget build(BuildContext context) {
    NavigatorState navigator = Navigator.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: _isSigningIn
          ? const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            )
          : Center(
              // style: ButtonStyle(
              //   backgroundColor: MaterialStateProperty.all(Colors.white),
              // ),
              child: InkWell(
                  splashColor: Colors.black26,
                  onTap: () async {
                    setState(() {
                      _isSigningIn = true;
                    });
                    User? user =
                        await Authentication.signInWithGoogle(context: context);

                    setState(() {
                      _isSigningIn = false;
                    });

                    if (user != null) {
                      //Navigator.pushReplacementNamed(context, HomePage.id);
                      navigator.pushReplacementNamed(Landing.id);
                      // pushReplacementNamed(context, Landing.id);
                    }
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Ink.image(
                          image: const AssetImage(
                              'assets/btn_google_signin_dark_pressed_web@2x.png'),
                          height: 60,
                          width: 240,
                          fit: BoxFit.fill),
                      const SizedBox(
                        width: 6.0,
                      ),
                    ],
                  )),
            ),
    );
  }
}
