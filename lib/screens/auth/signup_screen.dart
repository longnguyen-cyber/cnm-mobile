import 'package:flutter/material.dart';
import 'package:zalo_app/components/index.dart';
import 'package:zalo_app/screens/auth/home_screen.dart';
import 'package:zalo_app/screens/auth/login_screen.dart';
import 'package:zalo_app/constants.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:zalo_app/screens/auth/welcome.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  static String id = 'signup_screen';

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // final _auth = FirebaseAuth.instance;
  late String _email;
  late String _password;
  late String _confirmPass;
  late String _userName;
  late String _phone;
  // late String _
  bool _saving = false;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.popAndPushNamed(context, HomeScreen.id);
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: LoadingOverlay(
          isLoading: _saving,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const TopScreenImage(screenImageName: 'signup.png'),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const ScreenTitle(title: 'ĐĂNG KÍ'),
                            CustomTextField(
                              textField: TextFormField(
                                onChanged: (value) {
                                  _email = value;
                                },
                                style: const TextStyle(
                                  fontSize: 20,
                                ),
                                decoration: kTextInputDecoration.copyWith(
                                  hintText: 'Email',
                                  prefixIcon: const Icon(Icons.email),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Email không được để trống';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Email không đúng định dạng';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            CustomTextField(
                              textField: TextFormField(
                                onChanged: (value) {
                                  _userName = value;
                                },
                                style: const TextStyle(
                                  fontSize: 20,
                                ),
                                decoration: kTextInputDecoration.copyWith(
                                  hintText: 'Tên người dùng',
                                  prefixIcon: const Icon(Icons.person),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Tên người dùng không được để trống';
                                  }
                                  return null;
                                },
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
                                  hintText: 'Mật khẩu',
                                  prefixIcon: const Icon(Icons.lock),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Vui lý nhập mật khẩu';
                                  }
                                  if (value.length < 6) {
                                    return 'Mật khẩu ít nhất là 6 kí tự';
                                  }

                                  return null;
                                },
                              ),
                            ),
                            CustomTextField(
                              textField: TextFormField(
                                obscureText: true,
                                onChanged: (value) {
                                  _confirmPass = value;
                                },
                                style: const TextStyle(
                                  fontSize: 20,
                                ),
                                decoration: kTextInputDecoration.copyWith(
                                  hintText: 'Nhập lại mật khẩu',
                                  prefixIcon: const Icon(Icons.lock),
                                ),
                                validator: (value) {
                                  if (_password.isEmpty) {
                                    return 'Vui lòng nhập mật khẩu trước';
                                  }
                                  if (value != _password) {
                                    return 'Mật khẩu nhập lại không khớp';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            // CustomTextField(
                            //   textField: TextFormField(
                            //     obscureText: true,
                            //     onChanged: (value) {
                            //       _phone = value;
                            //     },
                            //     style: const TextStyle(
                            //       fontSize: 20,
                            //     ),
                            //     decoration: kTextInputDecoration.copyWith(
                            //       hintText: 'Số điện thoại',
                            //       prefixIcon: const Icon(Icons.phone),
                            //     ),
                            //     validator: (value) {
                            //       if (value == null || value.isEmpty) {
                            //         return 'Số điện thoại không được để trống';
                            //       }
                            //     },
                            //   ),
                            // ),
                            CustomBottomScreen(
                              textButton: 'Đăng kí',
                              heroTag: 'signup_btn',
                              question: 'Đã có tài khoản?',
                              buttonPressed: () {
                                // Validate returns true if the form is valid, or false otherwise.
                                if (_formKey.currentState!.validate()) {
                                  // If the form is valid, display a snackbar. In the real world,
                                  // you'd often call a server or save the information in a database.
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                      'Đang đăng nhập',
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.blue),
                                    )),
                                  );
                                  Navigator.pushNamed(
                                      context, WelcomeScreen.id);
                                }
                              },
                              // buttonPressed: () async {
                              //   FocusManager.instance.primaryFocus?.unfocus();
                              //   setState(() {
                              //     _saving = true;
                              //   });
                              //   if (_confirmPass == _password) {
                              //     try {
                              //       // await _auth.createUserWithEmailAndPassword(
                              //       //     email: _email, password: _password);

                              //       if (context.mounted) {
                              //         signUpAlert(
                              //           context: context,
                              //           title: 'GOOD JOB',
                              //           desc: 'Go login now',
                              //           btnText: 'Login Now',
                              //           onPressed: () {
                              //             setState(() {
                              //               _saving = false;
                              //               Navigator.popAndPushNamed(
                              //                   context, SignUpScreen.id);
                              //             });
                              //             Navigator.pushNamed(
                              //                 context, LoginScreen.id);
                              //           },
                              //         ).show();
                              //       }
                              //     } catch (e) {
                              //       signUpAlert(
                              //           context: context,
                              //           onPressed: () {
                              //             SystemNavigator.pop();
                              //           },
                              //           title: 'SOMETHING WRONG',
                              //           desc: 'Close the app and try again',
                              //           btnText: 'Close Now');
                              //     }
                              //   } else {
                              //     showAlert(
                              //         context: context,
                              //         title: 'WRONG PASSWORD',
                              //         desc:
                              //             'Make sure that you write the same password twice',
                              //         onPressed: () {
                              //           Navigator.pop(context);
                              //         }).show();
                              //   }
                              // },
                              questionPressed: () async {
                                Navigator.pushNamed(context, LoginScreen.id);
                              },
                            ),
                          ],
                        ),
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
