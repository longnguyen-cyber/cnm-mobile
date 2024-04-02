import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zalo_app/config/socket/socket.dart';
import 'package:zalo_app/config/socket/socket_event.dart';
import 'package:zalo_app/model/user.model.dart';
import 'package:zalo_app/services/api_service.dart';

import 'components/index.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // ignore: avoid_init_to_null
  late dynamic newEvent = null;
  late String userId = "";
  final api = API();

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
    final response = await api.get("all", {});
    if (mounted) {
      setState(() {
        all = response;
      });
    }
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

    SocketConfig.listen(SocketEvent.updatedSendThread, (response) {
      if (response["typeMsg"] == null) {
        var receiveId;
        var members;
        if (response["type"] == "chat") {
          receiveId = response["receiveId"];
        } else {
          members =
              (response["members"] as List).map((e) => e.toString()).toList();
        }

        var data = {
          "lastedThread": {
            "messages": {"message": response["messages"]["message"]},
          },
          "isReply": response["isReply"],
          "isRecall": response["isRecall"],
          "user": response["user"],
          "timeThread": response["timeThread"],
          "id": response["type"] == "chat"
              ? response["chatId"]
              : response["channelId"],
          "type": response["type"],
        };

        if (mounted) {
          if (userId == receiveId || members.contains(userId)) {
            var index =
                all.indexWhere((element) => element["id"] == data["id"]);
            setState(() {
              all[index] = data;
              all.sort((a, b) {
                return DateTime.parse(b["timeThread"])
                    .compareTo(DateTime.parse(a["timeThread"]));
              });
            });
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [for (int i = 0; i < all.length; i++) ChatItem(obj: all[i])],
    );
  }
}
