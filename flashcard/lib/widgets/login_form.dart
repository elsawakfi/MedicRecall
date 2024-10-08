import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_x/screens/verify_email_screen.dart';
import 'package:flashcard_x/utils/authentication.dart';
import 'package:flashcard_x/utils/string_validation.dart';
import 'package:flutter/material.dart';


class LoginForm extends StatefulWidget {
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;

  const LoginForm({
    required this.emailFocusNode,
    required this.passwordFocusNode,
    Key? key,
  }) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isSigningIn = false;
  final _formkey = GlobalKey<FormState>();
  bool passwordVisible = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    NavigatorState navigator = Navigator.of(context);
    return Form(
      key: _formkey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // EMAIL //
          SizedBox(
            width: 350,
            height: 60,
            child: TextFormField(
              key: const ValueKey('emailSignUpField'),
              controller: _email,
              focusNode: widget.emailFocusNode,
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
          const SizedBox(height: 4),
          // PASSWORD //
          SizedBox(
            width: 350,
            height: 60,
            child: TextFormField(
              key: const ValueKey('passwordSignUpField'),
              controller: _password,
              focusNode: widget.passwordFocusNode,
              obscureText: passwordVisible,
              validator: (value) => StringValidation.validatePassword(
                password: value,
              ),
              cursorColor: Colors.black,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.lock,
                ),
                labelText: 'Password',
                hintText: 'Enter Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    passwordVisible ? Icons.visibility_off : Icons.visibility,
                    color:
                        Theme.of(context).secondaryHeaderColor.withOpacity(0.8),
                  ),
                  onPressed: () {
                    setState(() {
                      passwordVisible = !passwordVisible;
                    });
                  },
                ),
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
          _isSigningIn
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
                      key: const ValueKey('Log In Button'),
                      onPressed: () async {
                        widget.emailFocusNode.unfocus();
                        widget.passwordFocusNode.unfocus();

                        setState(() {
                          _isSigningIn = true;
                        });

                        if (_formkey.currentState!.validate()) {
                          User? user =
                              await Authentication.signInWithEmailAndPassword(
                            context: context,
                            email: _email.text,
                            password: _password.text,
                          );

                          if (user != null) {
                            // if a user object is filled
                            //Navigator.pushReplacementNamed(
                            //  context, HomePage.id); //push replace page with homepage instance, with id, which is a string
                            navigator.pushReplacementNamed(VerifyEmailScreen.id);
                          }
                        }

                        setState(() {
                          _isSigningIn = false;
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
                      icon: const Icon(Icons.lock_open_sharp,
                          size: 30, color: Colors.white),
                      label: const Text(
                        'Login',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
