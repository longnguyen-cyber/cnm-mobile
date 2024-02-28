import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'components/index.dart';

class FriendTabScreen extends StatefulWidget {
  const FriendTabScreen({super.key});

  @override
  State<FriendTabScreen> createState() => _FriendTabScreenState();
}

class _FriendTabScreenState extends State<FriendTabScreen>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    var listView = ListView(children: const <Widget>[
      FriendTabItem(
        iconUrl: 'assets/icons/invite-friends.svg',
        name: 'Thêm bạn bè',
      ),
      FriendTabItem(
        iconUrl: 'assets/icons/phonebook.svg',
        name: 'Danh bạ máy',
        subtitle: 'Liên hệ có sử dụng Workchat',
      ),
      FriendTabItem(
        iconUrl: 'assets/icons/birthday-16.svg',
        name: 'Lịch sinh nhật',
        subtitle: 'Theo dõi sinh nhật của bạn bè',
      )
    ]);
    return Expanded(
      child: Column(children: <Widget>[
        Expanded(flex: 1, child: listView),
        const Text('Bạn bè'),
        Expanded(
            child: ListView(children: const <Widget>[
          FriendItem(
            iconUrl: 'https://i.pravatar.cc/300',
            name: 'Huy Nguyễn',
          ),
          FriendItem(
            iconUrl: 'https://i.pravatar.cc/300',
            name: 'Bách',
          ),
          FriendItem(
            iconUrl: 'https://i.pravatar.cc/300',
            name: 'Hải',
          ),
        ])),
      ]),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}

class FriendItem extends StatelessWidget {
  const FriendItem({
    super.key,
    required this.iconUrl,
    required this.name,
  });
  final String iconUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      padding: EdgeInsets.all(size.width * 0.02),
      child: Row(children: [
        Expanded(
            flex: 2,
            child: CircleAvatar(
                radius: 30, backgroundImage: NetworkImage(iconUrl))),
        const Spacer(),
        Expanded(
            flex: 6, child: Text(name, style: const TextStyle(fontSize: 16))),
        const Expanded(
          flex: 2,
          child: Row(children: <Widget>[
            Icon(Icons.call),
            Spacer(),
            Icon(Icons.video_call)
          ]),
        )
      ]),
    );
    // return Column(children: [
    // Expanded(
    //     flex: 2,
    //     child:
    //         CircleAvatar(radius: 30, backgroundImage: NetworkImage(iconUrl))),
    // const Spacer(),
    // Expanded(
    //     flex: 6, child: Text(name, style: const TextStyle(fontSize: 16))),
    // const Expanded(
    //   flex: 2,
    //   child: Row(children: <Widget>[
    //     Icon(Icons.call),
    //     Spacer(),
    //     Icon(Icons.video_call)
    //   ]),
    // )
    // ]);
  }
}
