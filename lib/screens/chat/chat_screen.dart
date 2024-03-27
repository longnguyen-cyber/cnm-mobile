import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zalo_app/config/socket/socket.dart';
import 'package:zalo_app/config/socket/socket_event.dart';
import 'package:zalo_app/model/user.model.dart';

import 'components/index.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final Dio _dio = Dio();
  var baseUrl = dotenv.env['API_URL'];
  // ignore: avoid_init_to_null
  late dynamic newEvent = null;
  late String userId = "";

  List<dynamic> all = [];
  void getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token") ?? "";
    var userOfToken = prefs.getString(token) ?? "";
    if (userOfToken != "") {
      userId = User.fromJson(userOfToken).id!;
      setState(() {
        userId = userId;
      });
    }
  }

  void getAll() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // bool isFirstRun = prefs.getBool('isFirstRun')!;
    // if (isFirstRun) {
    //   prefs.remove("all");
    //   prefs.setBool('isFirstRun', false);
    // }
    var token = prefs.getString("token") ?? "";
    // var localData = prefs.getString("all");
    // if (localData != null) {
    //   setState(() {
    //     all = json.decode(localData);
    //   });
    // } else {
    print(token);
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
    print(response.data);
    if (mounted) {
      setState(() {
        // all = json.decode(localData);
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

      if (mounted) {
        setState(() {
          all = response.data;
        });
      }
    }
    // }
  }

  @override
  void initState() {
    super.initState();
    getAll();
    getUser();
    SocketConfig.listen(SocketEvent.channelWS, (response) {
      var status = response['status'];
      var data = response['data'];
      if (status == 200) {
        if (mounted) {
          var type = data["type"];
          var channel = data["channel"];
          var userIds = (channel["users"] as List)
              .map((e) => User.fromMap(e))
              .toList()
              .map((e) => e.id)
              .toList();

          setState(() {
            if (userIds.contains(userId)) {
              if (type == "updateChannel") {
                int index =
                    all.indexWhere((element) => element["id"] == channel["id"]);
                all[index] = channel;
              } else if (type == "deleteChannel") {
                all.removeWhere((c) => c["id"] == channel["id"]);
              } else if (type == "addUserToChannel") {
                // input: usersAddedName: [long, tuyen]
                // output: long, tuyen duoc them vao nhom
                int index =
                    all.indexWhere((element) => element["id"] == channel["id"]);
                all[index] =
                    channel; // update last message of channel when add user to channel
              }
            }
          });
        }
      }
      if (status == 201) {
        if (mounted) {
          var userIds = (data["users"] as List)
              .map((e) => User.fromMap(e))
              .toList()
              .map((e) => e.id)
              .toList();
          setState(() {
            if (userIds.contains(userId)) {
              all.insert(0, data);
            }
          });
        }
      }
    });
    SocketConfig.listen(SocketEvent.chatWS, (response) {
      var status = response['status'];
      var data = response['data'];
      if (status == 201) {
        if (mounted) {
          setState(() {
            if (data["receiveId"] == userId || data["sendId"] == userId) {
              all.insert(0, data);
            }
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // for (int i = 0; i < all.length; i++) print('Dữ liệu' + all[i] + '');
    return ListView(
      children: [
        for (int i = 0; i < all.length; i++) ChatItem(obj: all[i])
        // print(all[i]) ,
      ],
    );
  }
}
