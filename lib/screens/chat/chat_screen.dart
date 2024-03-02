import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zalo_app/model/channel.model.dart';
import 'package:zalo_app/model/chat.model.dart';

import 'components/index.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final Dio _dio = Dio();
  var baseUrl = dotenv.env['API_URL'];

  List<dynamic> all = [];

  void getAll() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token") ?? "";
    print(token);
    var localData = prefs.getString("all");
    if (localData != null) {
      setState(() {
        all = json.decode(localData);
      });
    } else {
      String url = "$baseUrl/all";
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

      setState(() {
        all = response.data;
        prefs.setString("all", json.encode(response.data));
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getAll();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      for (int i = 0; i < all.length; i++)
        // if(all[i]['type'] == 'channel') {
        //   var objt = Channel.fromJson(all[i]);
        //   Text(objt.type);
        // } else {
        //   var objt = Chat.fromJson(all[i]);
        //   Text(objt.type);
        // }
        ChatItem(obj: all[i])
    ]);
    // ChatItem(
    // displayName: listChat[i]['displayName'].toString(),
    // avatarUrl: listChat[i]['avatarUrl'].toString(),
    // read: listChat[i]['read'].toString() == 'true' ? true : false,
    // lastMessage: listChat[i]['lastMessage'].toString(),
    // timeSent: listChat[i]['timeSent'].toString(),
    // prepareMessage: listChat[i]['prepareMessage']?.toString(),
    // )
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
