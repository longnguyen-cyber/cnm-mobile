import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:zalo_app/screens/friend/friend_tab_screen.dart';
import 'package:zalo_app/screens/friend/group_tab_screen.dart';

class FriendScreen extends StatefulWidget {
  const FriendScreen({super.key});

  @override
  State<FriendScreen> createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      height: double.maxFinite,
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Bạn bè'),
                  Tab(text: 'Nhóm'),
                ],
                labelColor: Colors.black,
                unselectedLabelStyle: const TextStyle(
                  color: Colors.grey,
                ),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                indicatorColor: Colors.blue,
              ),
            ),
            Expanded(
              child: TabBarView(
                dragStartBehavior: DragStartBehavior.start,
                controller: _tabController,
                children: const [
                  FriendTabScreen(),
                  GroupTabScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
