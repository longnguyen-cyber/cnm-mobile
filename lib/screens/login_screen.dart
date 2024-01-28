import 'package:flutter/material.dart';
import 'package:zalo_app/components/components.dart';
import 'package:zalo_app/constants.dart';
import 'package:zalo_app/screens/welcome.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:zalo_app/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static String id = 'login_screen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // final _auth = FirebaseAuth.instance;
  late String _email;
  late String _password;
  bool _saving = false;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope.new(
      onWillPop: () async {
        Navigator.popAndPushNamed(context, HomeScreen.id);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: LoadingOverlay(
          isLoading: _saving,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const TopScreenImage(screenImageName: 'welcome.png'),
                  Expanded(
                    flex: 2,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const ScreenTitle(title: 'ĐĂNG NHẬP'),
                          CustomTextField(
                            textField: TextFormField(
                              onChanged: (value) {
                                _email = value;
                              },
                              style: const TextStyle(
                                fontSize: 20,
                              ),
                              decoration: kTextInputDecoration.copyWith(
                                  contentPadding: const EdgeInsets.all(10),
                                  hintText: 'Nhập email',
                                  prefixIcon: const Icon(Icons.email)),
                              validator: (value) =>
                                  value!.isEmpty ? 'Vui lòng email' : null,
                            ),
                          ),
                          CustomTextField(
                            textField: TextFormField(
                              obscureText: true,
                              onChanged: (value) {
                                _password = value;
                              },
                              style: const TextStyle(
                                fontSize: 20,
                              ),
                              decoration: kTextInputDecoration.copyWith(
                                hintText: 'Nhập mật khẩu',
                                prefixIcon: Icon(Icons.lock),
                              ),
                            ),
                          ),
                          CustomBottomScreen(
                            textButton: 'Đăng nhập',
                            heroTag: 'login_btn',
                            question: 'Quên mật khẩu',
                            buttonPressed: () {
                              // Validate returns true if the form is valid, or false otherwise.
                              if (_formKey.currentState!.validate()) {
                                // If the form is valid, display a snackbar. In the real world,
                                // you'd often call a server or save the information in a database.
                                // ScaffoldMessenger.of(context).showSnackBar(
                                //   const SnackBar(
                                //       content: Text('Processing Data')),
                                // );
                              }
                            },
                            // buttonPressed: () async {
                            //   if (!_formKey.currentState!.validate()) {

                            //   }
                            //   FocusManager.instance.primaryFocus?.unfocus();
                            //   setState(() {
                            //     _saving = true;
                            //   });
                            //   try {
                            //     // await _auth.signInWithEmailAndPassword(
                            //     //     email: _email, password: _password);

                            //     if (context.mounted) {
                            //       setState(() {
                            //         _saving = false;
                            //         Navigator.popAndPushNamed(
                            //             context, LoginScreen.id);
                            //       });
                            //       Navigator.pushNamed(
                            //           context, WelcomeScreen.id);
                            //     }
                            //   } catch (e) {
                            //     signUpAlert(
                            //       context: context,
                            //       onPressed: () {
                            //         setState(() {
                            //           _saving = false;
                            //         });
                            //         Navigator.popAndPushNamed(
                            //             context, LoginScreen.id);
                            //       },
                            //       title: 'WRONG PASSWORD OR EMAIL',
                            //       desc:
                            //           'Confirm your email and password and try again',
                            //       btnText: 'Try Now',
                            //     ).show();
                            //   }
                            // },
                            questionPressed: () {
                              signUpAlert(
                                onPressed: () async {
                                  // await FirebaseAuth.instance
                                  //     .sendPasswordResetEmail(email: _email);
                                },
                                title: 'RESET YOUR PASSWORD',
                                desc:
                                    'Click on the button to reset your password',
                                btnText: 'Reset Now',
                                context: context,
                              ).show();
                            },
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
      ),
    );
  }
}
