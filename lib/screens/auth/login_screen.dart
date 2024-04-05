// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:zalo_app/blocs/bloc_user/user_cubit.dart';
import 'package:zalo_app/components/index.dart';
import 'package:zalo_app/config/routes/app_route_constants.dart';
import 'package:zalo_app/constants.dart';
import 'package:zalo_app/utils/valid.dart';

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
  Valid valid = Valid();
  late bool _obscureText = true;
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
              child: Column(
                children: [
                  const TopScreenImage(screenImageName: 'welcome.png'),
                  Expanded(
                    flex: 2,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const ScreenTitle(title: 'ĐĂNG NHẬP'),
                          const SizedBox(height: 20),
                          CustomTextField(
                            textField: TextFormField(
                              onChanged: (value) {
                                email = value;
                              },
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                              decoration: kTextInputDecoration.copyWith(
                                  // contentPadding: const EdgeInsets.all(10),
                                  hintText: 'Nhập email',
                                  prefixIcon: const Icon(Icons.email_outlined)),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lý nhập email';
                                }
                                if (!valid.validateEmail(email)) {
                                  return 'Email không hợp lệ';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            textField: TextFormField(
                              obscureText: _obscureText,
                              onChanged: (value) {
                                password = value;
                              },
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                              decoration: kTextInputDecoration.copyWith(
                                hintText: 'Nhập mật khẩu',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureText
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureText = !_obscureText;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lý nhập mật khẩu';
                                }
                                if (value.length < 6) {
                                  return 'Mật khẩu ít nhất là 6 kí tự';
                                }
                                // if (!valid.validatePassword(value)) {
                                //   return 'Mật khẩu phải chứa ít nhất 1 kí tự hoa, 1 kí tự số và 1 kí tự đặc biệt';
                                // }

                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          CustomBottomScreen(
                            textButton: 'Đăng nhập',
                            heroTag: 'login_btn',
                            question: 'Quên mật khẩu',
                            buttonPressed: () async {
                              // Validate returns true if the form is valid, or false otherwise.
                              if (_formKey.currentState!.validate()) {
                                // If the form is valid, display a snackbar. In the real world,
                                // you'd often call a server or save the information in a database.
                                // ScaffoldMessenger.of(context).showSnackBar(
                                //   const SnackBar(
                                //       content: Text(
                                //     'Đang đăng nhập',
                                //     style: TextStyle(
                                //         fontSize: 20, color: Colors.blue),
                                //   )),
                                // );

                                Future<bool> result = context
                                    .read<UserCubit>()
                                    .login(email, password);

                                bool isLogin = await result;
                                if (isLogin) {
                                  GoRouter.of(context).pushNamed(
                                      MyAppRouteConstants.mainRouteName);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                      'Email hoặc mật khẩu không đúng',
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.red),
                                    )),
                                  );
                                }
                              }
                            },
                            questionPressed: () {
                              GoRouter.of(context).pushNamed(
                                  MyAppRouteConstants.forgotRouteName);
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
        );
      },
    );
  }
}
