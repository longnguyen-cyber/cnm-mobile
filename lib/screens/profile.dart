import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zalo_app/blocs/bloc_friend/friend_cubit.dart';
import 'package:zalo_app/components/index.dart';
import 'package:zalo_app/config/routes/app_route_constants.dart';
import 'package:zalo_app/config/socket/socket.dart';
import 'package:zalo_app/config/socket/socket_event.dart';
import 'package:zalo_app/config/socket/socket_message.dart';
import 'package:zalo_app/model/chat.model.dart';
import 'package:zalo_app/model/user.model.dart';
import 'package:zalo_app/services/api_service.dart';

class Profile extends StatefulWidget {
  const Profile({super.key, this.user, required this.id});
  final User? user;
  final String id;

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late bool isRequest = false;
  late bool isFriend = false;
  late String chatId = widget.id;
  late String userId = "";

  final api = API();
  void getFriendChatWaittingAccept() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var token = prefs.getString("token") ?? "";
    var userOfToken = prefs.getString(token) ?? "";
    if (userOfToken != "") {
      userId = User.fromJson(userOfToken).id!;
      setState(() {
        userId = userId;
      });
    }
    if (mounted) {
      final response = await api
          .get("chats/${widget.user!.id}/friendChatWaittingAccept", {});
      if (response != null) {
        Chat chat = Chat.fromMap(response["data"]);
        setState(() {
          isRequest = chat.requestAdd;
          isFriend = chat.isFriend;
        });
      }
    }
  }

  void reqAddFriend(String receiveId) {
    SocketConfig.emit(SocketMessage.reqAddFriend, {
      "receiveId": receiveId,
    });
  }

  void reqAddFriendHaveChat(String receiveId, String chatId) {
    SocketConfig.emit(SocketMessage.reqAddFriendHaveChat, {
      "receiveId": receiveId,
      "chatId": chatId,
    });
  }

  void unReqAddFriend(String chatId) {
    SocketConfig.emit(SocketMessage.unReqAddFriend, {
      "chatId": chatId,
    });
  }

  void unFriend(String chatId) {
    SocketConfig.emit(SocketMessage.unfriend, {
      "chatId": chatId,
    });
  }

  @override
  void initState() {
    super.initState();
    getFriendChatWaittingAccept();

    SocketConfig.listen(SocketEvent.chatWS, (response) {
      var status = response['status'];
      var data = response['data'];
      if (status == 200) {
        if (mounted) {
          setState(() {
            if (data["receiveId"] == userId || data["senderId"] == userId) {
              if (data["type"] == "unReqAddFriend") {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Đã hủy thu hồi lời mời kết bạn"),
                  ),
                );

                setState(() {
                  isRequest = false;
                  chatId = "";
                });
              } else if (data["type"] == "unfriend") {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Đã hủy kết bạn"),
                  ),
                );
              } else if (data["type"] == "reqAddFriend" ||
                  data["type"] == "reqAddFriendHaveChat") {
                setState(() {
                  isRequest = true;
                  chatId = data["chat"]["id"];
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Đã gửi lời mời kết bạn"),
                  ),
                );
              }
            }
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    User userDefine = widget.user!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
          child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Image(
                image: NetworkImage(userDefine.avatar!),
                width: size.width * 0.9,
                height: 200,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 120,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(userDefine.avatar!),
                    ),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(
            height: 40,
          ),
          Text(
            "${userDefine.name!}${userDefine.displayName != null ? "(${userDefine.displayName})" : ""}",
            style: const TextStyle(
              fontSize: 20,
            ),
          ),
          BlocBuilder<FriendCubit, FriendState>(
            builder: (context, state) {
              if (state is FriendInitial) {
                context
                    .read<FriendCubit>()
                    .getFriendChatWaittingAccept(userDefine.id!);
              } else if (state is FriendChatWaittingAccept) {
                Chat chat = state.chat;
                if (chat.requestAdd) {
                  isRequest = true;
                }
              }
              return _isRequest(isRequest);
            },
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: BlocBuilder<FriendCubit, FriendState>(
              builder: (context, state) {
                if (state is FriendInitial) {
                  context
                      .read<FriendCubit>()
                      .getFriendChatWaittingAccept(userDefine.id!);
                } else if (state is FriendChatWaittingAccept) {
                  Chat chat = state.chat;
                  if (chat.requestAdd) {
                    isRequest = true;
                    chatId = chat.id!;
                  } else if (chat.isFriend) {
                    isFriend = true;
                  }
                }
                return Row(
                  children: [
                    Expanded(
                        child: CustomButton(
                            buttonText: "Nhắn tin",
                            onPressed: () {
                              GoRouter.of(context).pushNamed(
                                  MyAppRouteConstants.detailChatRouteName,
                                  extra: {
                                    "id": chatId,
                                    "type": "chat",
                                    "user": {
                                      "id": userDefine.id,
                                      "name": userDefine.name,
                                    }
                                  });
                            })),
                    const SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (isRequest) {
                          // Future<bool> rs = context
                          //     .read<FriendCubit>()
                          //     .unReqAddFriend(chatId);
                          // bool result = await rs;
                          // if (result) {
                          //   isRequest = false;
                          //   // ignore: use_build_context_synchronously
                          //   ScaffoldMessenger.of(context).showSnackBar(
                          //     const SnackBar(
                          //       content: Text("Đã hủy lời mời kết bạn"),
                          //     ),
                          //   );
                          // }
                          unReqAddFriend(chatId);
                        } else if (isFriend) {
                          unFriend(chatId);
                        } else {
                          // Future<bool> rs = context
                          //     .read<FriendCubit>()
                          //     .reqAddFriend(userDefine.id!);

                          // bool result = await rs;
                          // if (result) {
                          //   isRequest = true;
                          //   // ignore: use_build_context_synchronously
                          //   ScaffoldMessenger.of(context).showSnackBar(
                          //     const SnackBar(
                          //       content: Text("Đã gửi lời mời kết bạn"),
                          //     ),
                          //   );
                          // }

                          if (chatId != "") {
                            reqAddFriendHaveChat(userDefine.id!, chatId);
                          } else {
                            reqAddFriend(userDefine.id!);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.all(0),
                      ),
                      child: SizedBox(
                        height: 60,
                        width: 60,
                        child: isRequest
                            ? const Icon(
                                Icons.person_remove_alt_1_sharp,
                                size: 30,
                              )
                            : isFriend
                                ? const Icon(
                                    Icons.person_off_outlined,
                                    size: 25,
                                  )
                                : const Icon(
                                    Icons.person_add_alt_1_sharp,
                                    size: 30,
                                  ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      )),
    );
  }

  _isRequest(bool isRequest) {
    if (isRequest) {
      return const Text("Đã gửi lời mời kết bạn");
    } else {
      return const Text("");
    }
  }
}
