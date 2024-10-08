import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_x/screens/sign_in_screen.dart';
import 'package:flashcard_x/screens/verify_email_screen.dart';
import 'package:flashcard_x/utils/authentication.dart';
import 'package:flashcard_x/utils/string_validation.dart';
import 'package:flutter/material.dart';

class RegistrationForm extends StatefulWidget {
  final FocusNode nameFocusNode;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;

  const RegistrationForm({
    Key? key,
    required this.nameFocusNode,
    required this.emailFocusNode,
    required this.passwordFocusNode,
  }) : super(key: key);

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _isSigningUp = false;
  final _formkey = GlobalKey<FormState>();

  @override
  void dispose() {
    _name.dispose();
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
          SizedBox(
            width: 350,
            height: 60,
            // NAME //
            child: TextFormField(
              controller: _name,
              focusNode: widget.nameFocusNode,
              validator: (value) => StringValidation.validateName(
                name: value,
              ),
              cursorColor: Colors.black,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.person,
                ),
                hintText: 'Enter Name',
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
          // EMAIL //
          SizedBox(
            width: 350,
            height: 60,
            child: TextFormField(
              controller: _email,
              focusNode: widget.emailFocusNode,
              validator: (value) => StringValidation.validateEmail(
                email: value,
              ),
              cursorColor: Colors.black,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.email,
                ),
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
              controller: _password,
              focusNode: widget.passwordFocusNode,
              obscureText: true,
              validator: (value) => StringValidation.validatePassword(
                password: value,
              ),
              cursorColor: Colors.black,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.visibility_off,
                ),
                hintText: 'Enter Password',
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
          // PASSWORD CONFIRMATION //
          SizedBox(
            width: 350,
            height: 60,
            child: TextFormField(
              obscureText: true,
              validator: (value) {
                if (value != _password.text) {
                  return 'Passwords do not match';
                } else if (value?.isEmpty ?? true) {
                  return 'Password confirmation is required';
                }
                return null;
              },
              cursorColor: Colors.black,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.visibility_off,
                ),
                hintText: 'Confirm Password',
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: const BorderSide(
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: const BorderSide(
                    width: 2.0,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),

          const SizedBox(height: 20),
          _isSigningUp
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
                      onPressed: () async {
                        widget.nameFocusNode.unfocus();
                        widget.emailFocusNode.unfocus();
                        widget.passwordFocusNode.unfocus();

                        setState(() {
                          _isSigningUp = true;
                        });

                        if (_formkey.currentState!.validate()) {
                          User? user = await Authentication
                              .registerWithNameEmailPassword(
                            context: context,
                            name: _name.text,
                            email: _email.text,
                            password: _password.text,
                          );

                          if (user != null) {
                            navigator.pushReplacementNamed(VerifyEmailScreen.id);
                          }
                        }

                        setState(() {
                          _isSigningUp = false;
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
                        'Sign Up',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ),
                ),
          const SizedBox(height: 16.0),
          InkWell(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account? Click here to ",
                    style: TextStyle(fontSize: 19)),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, SignInScreen.id);
                  },
                  child: const Text(
                    "Sign In",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
