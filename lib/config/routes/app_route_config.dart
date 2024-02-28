import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zalo_app/screens/auth/login_screen.dart';
import 'package:zalo_app/screens/auth/signup_screen.dart';
import 'package:zalo_app/screens/auth/splash_screen.dart';
import 'package:zalo_app/screens/auth/welcome_screen.dart';
import 'package:zalo_app/screens/chat/chat_screen.dart';
import 'package:zalo_app/screens/chat/detail_chat_screen.dart';
import 'package:zalo_app/screens/home/main_screen.dart';

import 'app_route_constants.dart';

class MyAppRouter {
  GoRouter router = GoRouter(
    routes: [
      GoRoute(
        name: MyAppRouteConstants.mainRouteName,
        path: '/main',
        pageBuilder: (context, state) {
          return const MaterialPage(child: MainScreen());
        },
      ),
      GoRoute(
        name: MyAppRouteConstants.welcomeRouteName,
        path: '/',
        pageBuilder: (context, state) {
          return const MaterialPage(child: MainScreen());
        },
      ),
      // GoRoute(
      //   name: MyAppRouteConstants.welcomeRouteName,
      //   path: '/welcome',
      //   pageBuilder: (context, state) {
      //     return const MaterialPage(child: WelcomeSecreen());
      //   },
      // ),
      GoRoute(
        name: MyAppRouteConstants.splashRouteName,
        path: '/splash',
        pageBuilder: (context, state) {
          return const MaterialPage(child: SplashScreen());
        },
      ),

      GoRoute(
        name: MyAppRouteConstants.loginRouteName,
        path: '/login',
        pageBuilder: (context, state) {
          return const MaterialPage(child: LoginScreen());
        },
      ),
      GoRoute(
        name: MyAppRouteConstants.signupRouteName,
        path: '/signup',
        pageBuilder: (context, state) {
          return const MaterialPage(child: SignUpScreen());
        },
      ),
      GoRoute(
        name: MyAppRouteConstants.chatRouteName,
        path: '/chat',
        pageBuilder: (context, state) {
          return const MaterialPage(child: ChatScreen());
        },
      ),
      GoRoute(
        name: MyAppRouteConstants.detailChatRouteName,
        path: '/detailChat',
        pageBuilder: (context, state) {
          return const MaterialPage(child: DetailChatScreen());
        },
      ),
    ],
    errorPageBuilder: (context, state) {
      return const MaterialPage(
          child: Center(
        child: Text('ErrorPage'),
      ));
    },
  );
}
