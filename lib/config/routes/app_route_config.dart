import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zalo_app/model/file.model.dart';
import 'package:zalo_app/model/user.model.dart';
import 'package:zalo_app/screens/auth/forgot_pass_screen.dart';
import 'package:zalo_app/screens/auth/login_screen.dart';
import 'package:zalo_app/screens/auth/signup_screen.dart';
import 'package:zalo_app/screens/auth/verify_noti_screen.dart';
import 'package:zalo_app/screens/auth/welcome_screen.dart';
import 'package:zalo_app/screens/chat/chat_screen.dart';
import 'package:zalo_app/screens/chat/components/add_member.dart';
import 'package:zalo_app/screens/chat/components/all_file.dart';
import 'package:zalo_app/screens/chat/components/forward.dart';
import 'package:zalo_app/screens/chat/components/full_screen.dart';
import 'package:zalo_app/screens/chat/components/more_info.dart';
import 'package:zalo_app/screens/chat/components/test.dart';
import 'package:zalo_app/screens/chat/detail_chat_screen.dart';
import 'package:zalo_app/screens/friend/add_friend_screen.dart';
import 'package:zalo_app/screens/friend/create_channel_screen.dart';
import 'package:zalo_app/screens/home/main_screen.dart';
import 'package:zalo_app/screens/personal/edit_presonal.dart';
import 'package:zalo_app/screens/personal/edit_setting.dart';
import 'package:zalo_app/screens/profile.dart';
import 'package:zalo_app/screens/search_screen.dart';

import 'app_route_constants.dart';

class MyAppRouter {
  GoRouter router = GoRouter(
    routes: [
      GoRoute(
        name: MyAppRouteConstants.mainRouteName,
        path: '/',
        pageBuilder: (context, state) {
          // return MaterialPage(child: BottomSheetApp());
          // return MaterialPage(
          //     child: MoreInfo(
          //   data: {
          //     "type": "channel",
          //     "data": {
          //       "id": "661e2a10db85acbc89a5732c",
          //       "name": "update socket channel 300",
          //       "type": "channel",
          //       "members": [
          //         "65bceb94ceda5567efc0b629",
          //         "65dd4ae4cbeffa04dbbc5b16"
          //       ]
          //     }
          //   },
          // ));
          dynamic data = {
            "id": "661de3d568d65e1a851a2e2e",
            "name": "nesdw",
            "type": "chat",
            "receiverId": "65dd4ae4cbeffa04dbbc5b16",
          };
          dynamic dataChannel = {
            "id": "661e2a10db85acbc89a5732c",
            "name": "update socket channel 300",
            "type": "channel",
            "members": ["65bceb94ceda5567efc0b629", "65dd4ae4cbeffa04dbbc5b16"]
          };
          dynamic dataCloud = {
            "id": "661e158bcb9d1afaad63d296",
            "name": "cloud của tôi",
            "type": "cloud",
          };
          // return buildPageWithDefaultTransition<void>(
          //   context: context,
          //   state: state,
          //   child: MainScreen(
          //     index: 0,
          //   ),
          // );

          // return MaterialPage(
          //     child: DetailChatScreen(
          //   data: data,
          // ));
          // return MaterialPage(child: LoginScreen());
          // CallPage(callID: "L6KZla12", userID: "Dat", userName: "Đạt"));
          // MainScreen());
          // return const MaterialPage(
          //     child: DetailChatScreen(
          //   id: "65e480261644570261cadca4",
          //   type: "channel",
          //   name: "lam dep",
          // ));
          // return MaterialPage(
          //     child: VideoPlayerPage(
          //   url: Uri.parse(
          //       "https://workchatprod.s3.ap-southeast-1.amazonaws.com/2024-04-05+19-07-31.mp4"),
          // ));
          return MaterialPage(
              child: DetailChatScreen(
            data: dataChannel,
          ));
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
        name: MyAppRouteConstants.forgotRouteName,
        path: '/forgot',
        pageBuilder: (context, state) {
          return const MaterialPage(child: ForgotPasswordScreen());
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
          return const MaterialPage(child: VerifyNotiScreen());
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
        name: MyAppRouteConstants.searchRouteName,
        path: '/search',
        pageBuilder: (context, state) {
          return const MaterialPage(child: SearchScreen());
        },
      ),
      GoRoute(
        name: MyAppRouteConstants.profileRouteName,
        path: '/profile',
        pageBuilder: (context, state) {
          dynamic params = state.extra as dynamic;
          User user = params["user"] as User;
          String chatId = params["chatId"] ?? "";
          return MaterialPage(
              child: Profile(
            user: user,
            id: chatId,
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
              "members":
                  (params["users"] as List<dynamic>).map((e) => e).toList(),
            };
          } else if (params["type"] == "cloud") {
            data = {
              "id": params["id"],
              "type": "cloud",
              "name": params["user"]["name"],
            };
          } else {
            data = {
              "id": params["id"],
              "type": "chat",
              "name": params["user"]["name"],
              "receiverId": params["user"]["id"],
            };
          }

          // return buildPageWithDefaultTransition<void>(
          //   context: context,
          //   state: state,
          //   child: DetailChatScreen(
          //     data: data,
          //   ),
          // );
          return MaterialPage(child: DetailChatScreen(data: data));
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
      GoRoute(
        name: MyAppRouteConstants.allFileRouteName,
        path: '/allFile',
        pageBuilder: (context, state) {
          List<FileModel> files = state.extra as List<FileModel>;

          return buildPageWithDefaultTransition<void>(
            context: context,
            state: state,
            child: AllFileScreen(files: files),
          );
        },
      ),
      GoRoute(
        name: MyAppRouteConstants.addMemberRouteName,
        path: '/addMember',
        pageBuilder: (context, state) {
          // List<String> members = state.extra as List<String>;
          dynamic params = state.extra as dynamic;
          List<String> members = params["members"] as List<String>;
          String channelId = params["channelId"] as String;
          List<String> blockUser = params["blockUser"] as List<String>;

          return buildPageWithDefaultTransition<void>(
            context: context,
            state: state,
            child: AddMember(
              members: members,
              channelId: channelId,
              blockUser: blockUser,
            ),
          );
        },
      ),
      GoRoute(
        name: MyAppRouteConstants.forwardRouteName,
        path: '/foward',
        pageBuilder: (context, state) {
          String content = state.extra as String;

          return buildPageWithDefaultTransition<void>(
            context: context,
            state: state,
            child: Forward(content: content),
          );
        },
      ),
      GoRoute(
        name: MyAppRouteConstants.editPersonRouteName,
        path: '/editPerson',
        pageBuilder: (context, state) {
          return buildPageWithDefaultTransition<void>(
            context: context,
            state: state,
            child: const EditPerson(),
          );
        },
      ),
      GoRoute(
        name: MyAppRouteConstants.editSettingRouteName,
        path: '/editSetting',
        pageBuilder: (context, state) {
          return buildPageWithDefaultTransition<void>(
            context: context,
            state: state,
            child: const EditSetting(),
          );
        },
      ),
      GoRoute(
        name: MyAppRouteConstants.fullRouteName,
        path: '/full',
        pageBuilder: (context, state) {
          return buildPageWithDefaultTransition(
              context: context,
              state: state,
              child: FullScreenImage(image: state.extra as String));
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
