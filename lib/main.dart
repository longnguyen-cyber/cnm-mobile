import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zalo_app/blocs/bloc_user/user_cubit.dart';
import 'package:zalo_app/config/routes/app_route_config.dart';
import 'package:zalo_app/config/socket/socket.dart';
import 'package:zalo_app/repository/user_repo.dart';
import 'package:zalo_app/screens/chat/components/local_notifications.dart';
import 'package:zalo_app/services/user_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await LocalNotifications.init();

//  handle in terminated state

  // SharedPreferences prefs = await SharedPreferences.getInstance();
  // prefs.clear();
  await dotenv.load(fileName: "lib/.env");
  // await FlutterDownloader.initialize(
  //     debug:
  //         true, // optional: set to false to disable printing logs to console (default: true)
  //     ignoreSsl:
  //         true // option: set to false to disable working with http links (default: false)
  //     );
  runApp(MyApp(
    userService: UserService(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.userService,
  });
  final UserService userService;

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
