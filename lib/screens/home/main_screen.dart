import 'package:flutter/material.dart';
import 'package:motion_tab_bar/MotionBadgeWidget.dart';
import 'package:motion_tab_bar/MotionTabBar.dart';
import 'package:motion_tab_bar/MotionTabBarController.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zalo_app/screens/auth/welcome_screen.dart';
import 'package:zalo_app/screens/friend/friend_screen.dart';
import 'package:zalo_app/screens/personal.dart';

import '../chat/chat_screen.dart';

class BottomNavigator extends StatefulWidget {
  const BottomNavigator({super.key});

  @override
  State<BottomNavigator> createState() => _BottomNavigatorsState();
}

class _BottomNavigatorsState extends State<BottomNavigator>
    with TickerProviderStateMixin {
  MotionTabBarController? _motionTabBarController;
  @override
  void initState() {
    super.initState();
    _motionTabBarController = MotionTabBarController(
      initialIndex: 3,
      length: 4,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
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

          // custom badge Widget
          Container(
            color: Colors.black,
            padding: const EdgeInsets.all(2),
            child: const Text(
              '11',
              style: TextStyle(
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

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
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
    // if (_token.toString() != "" && _token.toString() != "null") {
    //   return const Scaffold(
    //     body: BottomNavigator(),
    //   );
    // } else {
    //   return const WelcomeScreen(); // Show a loading spinner while navigating
    // }
    return const Scaffold(
      body: BottomNavigator(),
    );
    if (_token.toString() != "" && _token.toString() != "null") {
      return const Scaffold(
        body: BottomNavigator(),
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
