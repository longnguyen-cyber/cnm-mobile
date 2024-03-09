import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:motion_tab_bar/MotionBadgeWidget.dart';
import 'package:motion_tab_bar/MotionTabBar.dart';
import 'package:motion_tab_bar/MotionTabBarController.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zalo_app/config/socket/socket.dart';
import 'package:zalo_app/config/socket/socket_event.dart';
import 'package:zalo_app/model/chat.model.dart';
import 'package:zalo_app/screens/auth/welcome_screen.dart';
import 'package:zalo_app/screens/friend/friend_screen.dart';
import 'package:zalo_app/screens/personal.dart';

import '../chat/chat_screen.dart';

class BottomNavigator extends StatefulWidget {
  const BottomNavigator({
    super.key,
    required this.index,
  });
  final int index;

  @override
  State<BottomNavigator> createState() => _BottomNavigatorsState();
}

class _BottomNavigatorsState extends State<BottomNavigator>
    with TickerProviderStateMixin {
  List<Chat> waitList = [];
  final Dio _dio = Dio();
  var baseUrl = dotenv.env['API_URL'];
  void getAll() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var token = prefs.getString("token") ?? "";

    String url = "$baseUrl/chats/friend/waitlistFriendAccept";
    final response = await _dio.get(
      url,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (mounted) {
      setState(() {
        waitList = (response.data["data"] as List)
            .map((e) => Chat.fromMap(e))
            .toList();
      });
    }
  }

  MotionTabBarController? _motionTabBarController;
  @override
  void initState() {
    super.initState();
    SocketConfig.listen(SocketEvent.chatWS, (response) {
      var status = response['status'];
      var data = response['data'];
      if (status == 200) {
        if (mounted) {
          if (data["type"] == "unReqAddFriend" ||
              data["type"] == "acceptAddFriend" ||
              data["type"] == "rejectAddFriend") {
            waitList.removeWhere((chat) => chat.id == data["chat"]["id"]);
          }
        }
      }
      setState(() {
        waitList = waitList;
      });
    });
    getAll();
    _motionTabBarController = MotionTabBarController(
      initialIndex: widget.index,
      length: 4,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    print(waitList.length);
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(
          Icons.search,
          color: Colors.white,
        ),
        backgroundColor: Colors.blue,
        title: TextField(
          // controller: _searchController,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: const InputDecoration(
            hintText: 'Tìm kiếm',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
          ),

          onChanged: (value) {
            // Perform search functionality here
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.qr_code,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
          IconButton(
              icon: const Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () {}),
        ],
      ),
      bottomNavigationBar: MotionTabBar(
        controller: _motionTabBarController,
        initialSelectedTab: "Tin nhắn",
        labels: buildLabels,
        icons: buildIcons,
        badges: [
          const MotionBadgeWidget(
            text: '10+',
            textColor: Colors.white,
            color: Colors.red,
            size: 18,
          ),

          waitList.length == 0
              ? const SizedBox()
              : Container(
                  color: Colors.black,
                  padding: const EdgeInsets.all(2),
                  child: Text(
                    waitList.length.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),

          // allow null
          null,

          // Default Motion Badge Widget with indicator only
          const MotionBadgeWidget(
            isIndicator: true,
            color: Colors.blue, // optional, default to Colors.red
            size: 5, // optional, default to 5,
            show: true, // true / false
          ),
        ],
        tabSize: 50,
        tabBarHeight: 55,
        textStyle: const TextStyle(
          fontSize: 12,
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
        tabIconColor: Colors.blue[600],
        tabIconSize: 28.0,
        tabIconSelectedSize: 26.0,
        tabSelectedColor: Colors.blue[900],
        tabIconSelectedColor: Colors.white,
        tabBarColor: Colors.white,
        onTabItemSelected: (int value) {
          setState(() {
            // _tabController!.index = value;
            _motionTabBarController!.index = value;
          });
        },
      ),
      body: TabBarView(
        physics:
            const NeverScrollableScrollPhysics(), // swipe navigation handling is not supported
        // controller: _tabController,
        controller: _motionTabBarController,
        children: buildPages,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _motionTabBarController!.dispose();
  }
}

// ignore: must_be_immutable
class MainScreen extends StatefulWidget {
  MainScreen({super.key, this.index});

  int? index;
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late String _token = "";

  @override
  void initState() {
    super.initState();

    fetchToken();
    if (widget.index == null) {
      setState(() {
        widget.index = 0;
      });
    }
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
    if (_token.toString() != "" && _token.toString() != "null") {
      return Scaffold(
        body: BottomNavigator(
          index: widget.index!,
        ),
      );
    } else {
      return const WelcomeScreen();
    }
  }
}

List<IconData> buildIcons = [
  Icons.message,
  Icons.people_alt,
  Icons.feed,
  Icons.person
];

List<String> buildLabels = const ["Tin nhắn", "Bạn bè", "Nhật kí", "Cá nhân"];

List<Widget> buildPages = const [
  ChatScreen(),
  FriendScreen(),
  Center(
    child: Text("Nhật kí"),
  ),
  Person()
];
