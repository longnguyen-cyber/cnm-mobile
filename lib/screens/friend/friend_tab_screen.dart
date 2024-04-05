import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zalo_app/blocs/bloc_friend/friend_cubit.dart';
import 'package:zalo_app/config/socket/socket.dart';
import 'package:zalo_app/config/socket/socket_event.dart';
import 'package:zalo_app/config/socket/socket_message.dart';
import 'package:zalo_app/model/chat.model.dart';
import 'package:zalo_app/model/user.model.dart';
import 'package:zalo_app/services/api_service.dart';

import 'components/index.dart';

class FriendTabScreen extends StatefulWidget {
  const FriendTabScreen({super.key});

  @override
  State<FriendTabScreen> createState() => _FriendTabScreenState();
}

class _FriendTabScreenState extends State<FriendTabScreen>
    with TickerProviderStateMixin {
  final Dio _dio = Dio();
  var baseUrl = dotenv.env['API_URL'];
  // ignore: avoid_init_to_null
  late dynamic newEvent = null;
  late String userId = "";
  final api = API();

  List<Chat> whiteList = [];
  List<Chat> waitList = [];
  void getAll() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var token = prefs.getString("token") ?? "";
    var userOfToken = prefs.getString(token) ?? "";
    if (userOfToken != "") {
      userId = User.fromJson(userOfToken).id!;
      setState(() {
        userId = userId;
      });
    }
    String urlWaitList = "chats/friend/waitlistFriendAccept";
    String urlWhiteList = "chats/friend/whitelistFriendAccept";
    // final response = await _dio.get(
    //   url,
    //   options: Options(
    //     headers: {
    //       'Content-Type': 'application/json',
    //       'Accept': 'application/json',
    //       'Authorization': 'Bearer $token',
    //     },
    //   ),
    // );

    final responseWaitList = await api.get(urlWaitList, {});
    final responseWhiteList = await api.get(urlWhiteList, {});

    if (mounted) {
      setState(() {
        waitList = (responseWaitList["data"] as List)
            .map((e) => Chat.fromMap(e))
            .toList();

        whiteList = (responseWhiteList["data"] as List)
            .map((e) => Chat.fromMap(e))
            .toList();
      });
    }
  }

  void whitelistFriendAccept() {}

  @override
  void initState() {
    super.initState();
    getAll();
    // listen to the chatWS event with function get all request add friend
    SocketConfig.listen(SocketEvent.chatWS, (response) {
      var status = response['status'];
      var data = response['data'];
      if (status == 200) {
        if (mounted) {
          setState(() {
            if (data["receiveId"] == userId || data["senderId"] == userId) {
              if (data["type"] == "unReqAddFriend") {
                waitList.removeWhere((chat) => chat.id == data["chat"]["id"]);
              } else if (data["type"] == "acceptAddFriend") {
                whiteList.add(Chat.fromMap(data["chat"]));
                waitList.removeWhere((chat) => chat.id == data["chat"]["id"]);
              } else if (data["type"] == "rejectAddFriend") {
                waitList.removeWhere((chat) => chat.id == data["chat"]["id"]);
              } else if (data["type"] == "unfriend") {
                whiteList.removeWhere((chat) => chat.id == data["chat"]["id"]);
              } else if (data['receiveId'] == userId) {
                waitList.add(Chat.fromMap(data["chat"]));
              } else if (data["type"] == "reqAddFriend" ||
                  data["type"] == "reqAddFriendHaveChat") {
                if (data["receiveId"] == userId) {
                  waitList.add(Chat.fromMap(data["chat"]));
                }
              }
            }
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const FriendTabItem(
          iconUrl: 'assets/icons/invite-friends.svg',
          name: 'Thêm bạn bè',
        ),
        Column(children: [
          for (int i = 0; i < waitList.length; i++)
            FriendItem(
              chat: waitList[i],
            )
        ]),
        const Divider(
          color: Colors.grey,
        ),
        Expanded(
          child: ListView(children: [
            for (int i = 0; i < whiteList.length; i++)
              FriendItem(
                chat: whiteList[i],
              )
          ]),
        ),
      ],
    );
  }
}

class FriendItem extends StatefulWidget {
  const FriendItem({
    super.key,
    required this.chat,
  });

  final Chat chat;

  @override
  State<FriendItem> createState() => _FriendItemState();
}

class _FriendItemState extends State<FriendItem> {
  late String token = "";

  void getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var tk = prefs.getString("token") ?? "";
    if (tk != "") {
      setState(() {
        token = tk;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getToken();
  }

  void acceptFriend(String chatId) {
    SocketConfig.emit(
      SocketMessage.acceptAddFriend,
      {
        "chatId": chatId,
      },
    );
  }

  void rejectFriend(String chatId) {
    SocketConfig.emit(
      SocketMessage.rejectAddFriend,
      {
        "chatId": chatId,
      },
    );
  }

  void unFriend(String chatId) {
    SocketConfig.emit(
      SocketMessage.unfriend,
      {
        "chatId": chatId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    Chat chat = widget.chat;
    User user = chat.user!;

    return Container(
      width: size.width,
      padding: EdgeInsets.all(size.width * 0.02),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.only(left: 20),
            child: user.avatar != null
                ? CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(user.avatar!),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(1000),
                    ),
                    height: 50,
                    width: 50,
                    child: Center(
                      child: Text(
                        user.name![0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                        ),
                      ),
                    ),
                  ),
          ),
          Expanded(
            child: Text(
              user.name!,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Expanded(
            flex: 1,
            child: chat.requestAdd
                ? Row(
                    children: [
                      const Spacer(),
                      Expanded(
                        child: SizedBox(
                          height: 30,
                          child: ElevatedButton(
                            onPressed: () {
                              acceptFriend(chat.id!);
                            },
                            child: const Icon(
                              Icons.check,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: SizedBox(
                          height: 30,
                          child: ElevatedButton(
                            onPressed: () {
                              rejectFriend(chat.id!);
                            },
                            child: const Icon(
                              Icons.close,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: <Widget>[
                      const Spacer(),
                      const Icon(Icons.call),
                      const SizedBox(
                        width: 10,
                      ),
                      const Icon(Icons.video_call),
                      const SizedBox(
                        width: 10,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          unFriend(chat.id!);
                        },
                        child: const Icon(Icons.remove_circle_outlined),
                      )
                    ],
                  ),
          )
        ],
      ),
    );
  }
}
