import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zalo_app/blocs/bloc_channel/channel_cubit.dart';
import 'package:zalo_app/blocs/bloc_chat/chat_cubit.dart';
import 'package:zalo_app/blocs/bloc_friend/friend_cubit.dart';
import 'package:zalo_app/blocs/bloc_user/user_cubit.dart';
import 'package:zalo_app/config/routes/app_route_config.dart';
import 'package:zalo_app/config/socket/socket.dart';
import 'package:zalo_app/repository/channel_repo.dart';
import 'package:zalo_app/repository/chat_repo.dart';
import 'package:zalo_app/repository/user_repo.dart';
import 'package:zalo_app/services/channel_service.dart';
import 'package:zalo_app/services/chat_service.dart';
import 'package:zalo_app/services/user_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // prefs.remove("all");

  // prefs.clear();
  await dotenv.load(fileName: "lib/.env");
  runApp(MyApp(
    userService: UserService(),
    channelService: ChannelService(),
    chatService: ChatService(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.userService,
    required this.channelService,
    required this.chatService,
  });
  final UserService userService;
  final ChannelService channelService;
  final ChatService chatService;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late String token = "";
  void getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token") ?? "";
    if (token != "") {
      setState(() {
        this.token = token;
        SocketConfig.connect(
            this.token); // pass the token to the connect method
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getToken();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    switch (state) {
      case AppLifecycleState.inactive:
        prefs.setBool('isFirstRun', true);
        break;
      case AppLifecycleState.paused:
        prefs.setBool('isFirstRun', true);
        break;
      case AppLifecycleState.resumed:
        prefs.setBool('isFirstRun', true);
        break;
      case AppLifecycleState.hidden:
        prefs.setBool('isFirstRun', true);
        break;
      case AppLifecycleState.detached:
        prefs.setBool('isFirstRun', false);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<UserCubit>(
          create: (BuildContext context) => UserCubit(
            userRepo: UserRepository(
              userService: widget.userService,
            ),
          ),
        ),
        BlocProvider<ChannelCubit>(
          create: (BuildContext context) => ChannelCubit(
            channelRepo: ChannelRepository(
              channelService: widget.channelService,
            ),
          ),
        ),
        BlocProvider<FriendCubit>(
          create: (BuildContext context) => FriendCubit(
            chatRepo: ChatRepository(
              chatService: widget.chatService,
            ),
          ),
        ),
        BlocProvider<ChatCubit>(
          create: (BuildContext context) => ChatCubit(
            chatRepo: ChatRepository(
              chatService: widget.chatService,
            ),
          ),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            textTheme: const TextTheme(
          bodyMedium: TextStyle(
            fontFamily: 'Ubuntu',
          ),
        )),
        routerConfig: MyAppRouter().router,
      ),
    );
  }
}
