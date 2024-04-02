import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zalo_app/components/index.dart';
import 'package:zalo_app/config/routes/app_route_constants.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late String _token = "";

  @override
  void initState() {
    super.initState();
    fetchToken();
  }

  void fetchToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token") ?? "";
    setState(() {
      _token = token;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_token.toString() != "") {
      GoRouter.of(context).go(MyAppRouteConstants.mainRouteName);
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const TopScreenImage(screenImageName: 'home.jpg'),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.only(right: 15.0, left: 15, bottom: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const ScreenTitle(title: 'Xin chào'),
                      const Text(
                        'Chào mừng bạn đến vơi WORKCHAT, nền tảng chat online',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Hero(
                        tag: 'login_btn',
                        child: CustomButton(
                          buttonText: 'ĐĂNG NHẬP',
                          onPressed: () {
                            GoRouter.of(context)
                                .pushNamed(MyAppRouteConstants.loginRouteName);
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Hero(
                        tag: 'signup_btn',
                        child: CustomButton(
                          buttonText: 'ĐĂNG KÍ',
                          isOutlined: true,
                          onPressed: () {
                            GoRouter.of(context)
                                .pushNamed(MyAppRouteConstants.signupRouteName);
                          },
                        ),
                      ),
                      const Text(
                        'Hoặc',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: CircleAvatar(
                              radius: 25,
                              child: Image.asset('assets/icons/facebook.png'),
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.transparent,
                              child: Image.asset('assets/icons/google.png'),
                            ),
                          ),
                          // IconButton(
                          //   onPressed: () {},
                          //   icon: CircleAvatar(
                          //     radius: 25,
                          //     child: Image.asset('assets/icons/linkedin.png'),
                          //   ),
                          // ),
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
