import 'package:flutter/material.dart';

import 'components/index.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      for (int i = 0; i < listChat.length; i++)
        ChatItem(
          displayName: listChat[i]['displayName'].toString(),
          avatarUrl: listChat[i]['avatarUrl'].toString(),
          read: listChat[i]['read'].toString() == 'true' ? true : false,
          lastMessage: listChat[i]['lastMessage'].toString(),
          timeSent: listChat[i]['timeSent'].toString(),
          prepareMessage: listChat[i]['prepareMessage']?.toString(),
        )
    ]);
  }
}

const listChat = [
  {
    "id": 0,
    "avatarUrl":
        "https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg",
    "displayName": "Adam Halay",
    "lastMessage": "Tối nay họp lúc 9h",
    "timeSent": "12 phút",
    "read": true,
  },
  {
    "id": 1,
    "avatarUrl":
        "https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg",
    "displayName": "Jame Smith",
    "lastMessage": "Bạn có đang rãnh không?",
    "timeSent": "bây giờ",
    "read": false
  },
  {
    "id": 2,
    "avatarUrl":
        "https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg",
    "displayName": "Agenti",
    "lastMessage": "Tối nay có họp k dậy taaa",
    "timeSent": "bây giờ",
    "read": true,
    "prepareMessage": 'Chưa biết nữa',
  }
];
