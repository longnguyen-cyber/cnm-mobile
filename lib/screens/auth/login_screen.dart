import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:zalo_app/blocs/bloc_user/user_cubit.dart';
import 'package:zalo_app/components/index.dart';
import 'package:zalo_app/config/routes/app_route_constants.dart';
import 'package:zalo_app/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // final _auth = FirebaseAuth.instance;

  final bool _saving = false;
  late String email = "";
  late String password = "";
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                GoRouter.of(context)
                    .pushNamed(MyAppRouteConstants.welcomeRouteName);
              },
            ),
            backgroundColor: Colors.white,
            elevation: 0,
          ),
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
                                  email = value;
                                },
                                style: const TextStyle(
                                  fontSize: 20,
                                ),
                                decoration: kTextInputDecoration.copyWith(
                                    // contentPadding: const EdgeInsets.all(10),
                                    hintText: 'Nhập email',
                                    prefixIcon: const Icon(Icons.email)),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Vui lý nhập email';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Email không hợp lệ';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            CustomTextField(
                              textField: TextFormField(
                                obscureText: true,
                                onChanged: (value) {
                                  password = value;
                                },
                                style: const TextStyle(
                                  fontSize: 20,
                                ),
                                decoration: kTextInputDecoration.copyWith(
                                  hintText: 'Nhập mật khẩu',
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
                            CustomBottomScreen(
                              textButton: 'Đăng nhập',
                              heroTag: 'login_btn',
                              question: 'Quên mật khẩu',
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

                                  GoRouter.of(context).pushNamed(
                                      MyAppRouteConstants.splashRouteName);
                                  context
                                      .read<UserCubit>()
                                      .login(email, password);
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
                              //     //     email: email, password: password);

                              //     if (context.mounted) {
                              //       setState(() {
                              //         _saving = false;

                              //       });

                              //     }
                              //   } catch (e) {
                              //     signUpAlert(
                              //       context: context,
                              //       onPressed: () {
                              //         setState(() {
                              //           _saving = false;
                              //         });

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
                                    //     .sendPasswordResetEmail(email: email);
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
        );
      },
    );
  }
}
