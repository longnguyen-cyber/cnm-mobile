import 'package:flutter/material.dart';
import 'package:motion_tab_bar/MotionBadgeWidget.dart';
import 'package:motion_tab_bar/MotionTabBar.dart';
import 'package:motion_tab_bar/MotionTabBarController.dart';

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
      initialIndex: 1,
      length: 4,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: BottomNavigator(),
    );
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
  Center(
    child: Text("Tin nhắn"),
  ),
  Center(
    child: Text("Bạn bè"),
  ),
  Center(
    child: Text("Nhật kí"),
  ),
  Center(
    child: Text("Cá nhân"),
  )
];
