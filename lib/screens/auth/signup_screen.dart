import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:zalo_app/blocs/bloc_user/user_cubit.dart';
import 'package:zalo_app/components/index.dart';
import 'package:zalo_app/config/routes/app_route_constants.dart';
import 'package:zalo_app/constants.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // final _auth = FirebaseAuth.instance;
  late String _email;
  late String _password;
  late String _userName;
  // late String _
  final bool _saving = false;
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
                                  onChanged: (value) {},
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
                                        'Vui long cho',
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.blue),
                                      )),
                                    );
                                    GoRouter.of(context).pushNamed(
                                        MyAppRouteConstants.splashRouteName);

                                    context.read<UserCubit>().register(
                                          email: _email,
                                          password: _password,
                                          username: _userName,
                                        );
                                  }
                                },
                                questionPressed: () {
                                  GoRouter.of(context).pushNamed(
                                      MyAppRouteConstants.loginRouteName);
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
        );
      },
    );
  }
}
