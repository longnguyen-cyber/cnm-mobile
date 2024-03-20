import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zalo_app/model/chat.model.dart';
import 'package:zalo_app/model/user.model.dart';
import 'package:zalo_app/screens/auth/login_screen.dart';
import 'package:zalo_app/screens/auth/signup_screen.dart';
import 'package:zalo_app/screens/auth/splash_screen.dart';
import 'package:zalo_app/screens/auth/welcome_screen.dart';
import 'package:zalo_app/screens/chat/chat_screen.dart';
import 'package:zalo_app/screens/chat/components/more_info.dart';
import 'package:zalo_app/screens/chat/detail_chat_screen.dart';
import 'package:zalo_app/screens/friend/add_friend_screen.dart';
import 'package:zalo_app/screens/friend/create_channel_screen.dart';
import 'package:zalo_app/screens/home/main_screen.dart';
import 'package:zalo_app/screens/profile.dart';

import 'app_route_constants.dart';

class MyAppRouter {
  GoRouter router = GoRouter(
    routes: [
      GoRoute(
        name: MyAppRouteConstants.mainRouteName,
        path: '/',
        pageBuilder: (context, state) {
          return MaterialPage(
              child:
                  // LoginScreen());
                  MainScreen(
            index: 0,
          ));
          // return const MaterialPage(
          //     child: DetailChatScreen(
          //   id: "65e480261644570261cadca4",
          //   type: "channel",
          //   name: "lam dep",
          // ));
          // return const MaterialPage(
          //     child: DetailChatScreen(
          //   id: "65ea7527798ba90473c6a2da",
          //   type: "chat",
          // ));
        },
      ),
      GoRoute(
        name: MyAppRouteConstants.welcomeRouteName,
        path: '/welcome',
        pageBuilder: (context, state) {
          return const MaterialPage(child: WelcomeScreen());
        },
      ),
      GoRoute(
          name: MyAppRouteConstants.friendRouteName,
          path: '/friend',
          pageBuilder: (context, state) {
            int index = state.extra as int;
            return MaterialPage(
                child: MainScreen(
              index: index,
            ));
          }),
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
        name: MyAppRouteConstants.addFriendRouteName,
        path: '/addFriend',
        pageBuilder: (context, state) {
          return const MaterialPage(child: AddFriendScreen());
        },
      ),
      GoRoute(
        name: MyAppRouteConstants.createChannelRouteName,
        path: '/createChannel',
        pageBuilder: (context, state) {
          return const MaterialPage(child: CreateChannelScreen());
        },
      ),
      GoRoute(
        name: MyAppRouteConstants.profileRouteName,
        path: '/profile',
        pageBuilder: (context, state) {
          User user = state.extra as User;
          return MaterialPage(
              child: Profile(
            user: user,
          ));
        },
      ),
      GoRoute(
        name: MyAppRouteConstants.detailChatRouteName,
        path: '/detailChat',
        pageBuilder: (context, state) {
          dynamic params = state.extra as dynamic;
          dynamic data;
          if (params["type"] == "channel") {
            data = {
              "id": params["id"],
              "type": "channel",
              "name": params["name"],
              "members": (params["users"] as List<dynamic>).length
            };
          } else {
            data = {
              "id": params["id"],
              "type": "chat",
              "name": params["user"]["name"],
            };
          }

          return buildPageWithDefaultTransition<void>(
            context: context,
            state: state,
            child: DetailChatScreen(
              data: data,
            ),
          );
        },
      ),
      GoRoute(
        name: MyAppRouteConstants.moreRouteName,
        path: '/more',
        pageBuilder: (context, state) {
          dynamic params = state.extra as dynamic;

          return buildPageWithDefaultTransition<void>(
            context: context,
            state: state,
            child: MoreInfo(
              data: params,
            ),
          );
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

CustomTransitionPage buildPageWithDefaultTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = const Offset(1.0, 0.0);
      var end = Offset.zero;
      var tween = Tween(begin: begin, end: end);
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}
