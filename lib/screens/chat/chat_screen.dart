// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zalo_app/config/socket/socket.dart';
import 'package:zalo_app/config/socket/socket_event.dart';
import 'package:zalo_app/model/thread.model.dart';
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
  late dynamic cloud = null;

  List<dynamic> all = [];
  void getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token") ?? "";
    var userOfToken = prefs.getString(token) ?? "";

    if (userOfToken != "") {
      String id = User.fromJson(userOfToken).id!;
      setState(() {
        userId = id;
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

  Future<void> getCloud() async {
    final response = await api.get("users/my-cloud", {});
    var lastedThread;
    List<Thread> threads = [];
    if (mounted) {
      setState(() {
        threads = (response["data"]["threads"] as List)
            .map((e) => Thread.fromMap(e))
            .toList();
        lastedThread = threads[threads.length - 1];
        String message = lastedThread.messages == null
            ? "File đính kèm"
            : lastedThread.messages.message ?? "";
        cloud = {
          "id": response["data"]["id"],
          "timeThread": lastedThread.createdAt.toString(),
          "type": "cloud",
          "lastedThread": {
            "messages": {"message": message}
          },
          "user": {
            "avatar":
                "https://workchatprod.s3.ap-southeast-1.amazonaws.com/memmme.jpg",
            "name": "Cloud của tôi"
          },
        };
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getAll();
    getUser();
    getCloud();

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
                if (index == -1) {
                  all.insert(0, channel);
                } else {
                  all[index] = channel;
                }
              } else if (type == "removeUserFromChannel") {
                int index =
                    all.indexWhere((element) => element["id"] == channel["id"]);
                // all[index] = channel;

                all[index] = channel;
              } else if (type == "updateRoleUserInChannel") {
                int index =
                    all.indexWhere((element) => element["id"] == channel["id"]);
                all[index] = channel;
              }
            }

            if (type == "leaveChannel") {
              String userLeave = data["userLeave"];
              if (userLeave == userId) {
                all.removeWhere((c) => c["id"] == channel["id"]);
              } else {
                if (userIds.contains(userId)) {
                  int index = all
                      .indexWhere((element) => element["id"] == channel["id"]);
                  all[index] = channel;
                }
              }
            } else if (type == "removeUserFromChannel") {
              // all[index] = channel;
              var removeMember = data["removeMember"];
              if (removeMember == (userId)) {
                all.removeWhere((c) => c["id"] == channel["id"]);
              }
            }

            all.sort((a, b) {
              return DateTime.parse(b["timeThread"])
                  .compareTo(DateTime.parse(a["timeThread"]));
            });
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
        List<String> members = [];
        if (response["type"] == "chat") {
          receiveId = response["receiveId"];
        } else if (response["type"] == "channel") {
          members =
              (response["members"] as List).map((e) => e.toString()).toList();
        }
        if (response["messages"] != null) {
          var data = {
            "lastedThread": {
              "messages": {"message": response["messages"]["message"]},
            },
            "stoneId": response["stoneId"],
            "isReply": response["isReply"],
            "isRecall": response["isRecall"],
            "timeThread": response["timeThread"],
            "id": response["type"] == "chat"
                ? response["chatId"]
                : response["channelId"],
            "type": response["type"],
            "user": response["user"]
          };

          if (mounted) {
            if (response["type"] == "chat" &&
                (userId == receiveId ||
                    (data["user"] != null && userId == data["user"]["id"]))) {
              var index =
                  all.indexWhere((element) => element["id"] == data["id"]);
              setState(() {
                if (userId == data["user"]["id"]) {
                  dynamic prevUser = all[index]["user"];
                  data["user"] = prevUser;
                }
                all[index] = data;
                all.sort((a, b) {
                  return DateTime.parse(b["timeThread"])
                      .compareTo(DateTime.parse(a["timeThread"]));
                });
              });
            } else if (members.isNotEmpty && members.contains(userId)) {
              var index =
                  all.indexWhere((element) => element["id"] == data["id"]);
              var item = all[index];
              setState(() {
                all[index] = data;
                all[index]["users"] = item["users"];
                all[index]["user"] = null;
                all[index]["name"] = item["name"];
                all.sort((a, b) {
                  return DateTime.parse(b["timeThread"])
                      .compareTo(DateTime.parse(a["timeThread"]));
                });
              });
            }
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // all.insert(0, {
    //   "id": "0",
    //   "timeThread": "2021-09-01T00:00:00.000Z",
    //   "lastedThread": {
    //     "messages": {"message": "Xin chào"}
    //   },
    //   "user": {
    //     "avatar":
    //         "https://workchatprod.s3.ap-southeast-1.amazonaws.com/memmme.jpg",
    //     "name": "Cloud của tôi"
    //   },
    // });
    return ListView(
      children: [
        cloud != null
            ? ChatItem(
                obj: cloud,
              )
            : Container(),
        for (int i = 0; i < all.length; i++) ChatItem(obj: all[i])
      ],
    );
  }
}
