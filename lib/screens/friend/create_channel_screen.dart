import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:zalo_app/blocs/bloc_channel/channel_cubit.dart';
import 'package:zalo_app/blocs/bloc_chat/chat_cubit.dart';
import 'package:zalo_app/blocs/bloc_friend/friend_cubit.dart';
import 'package:zalo_app/config/routes/app_route_constants.dart';
import 'package:zalo_app/config/socket/socket.dart';
import 'package:zalo_app/config/socket/socket_event.dart';
import 'package:zalo_app/config/socket/socket_message.dart';
import 'package:zalo_app/model/chat.model.dart';
import 'package:zalo_app/model/user.model.dart';

const List<String> list = <String>['Public', 'Priavte'];

List<User> selectedUsersFinal = [];

class CreateChannelScreen extends StatefulWidget {
  const CreateChannelScreen({super.key});

  @override
  State<CreateChannelScreen> createState() => _CreateChannelScreenState();
}

class _CreateChannelScreenState extends State<CreateChannelScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    SocketConfig.listen(SocketEvent.channelWS, (response) {
      var status = response['status'];
      if (status == 201) {
        if (mounted) {
          SnackBar snackBar = const SnackBar(
            content: Text('Tạo nhóm thành công'),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          selectedUsersFinal.clear();
          //delay 2s
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              // Check if the widget is still in the tree
              GoRouter.of(context)
                  .pushNamed(MyAppRouteConstants.friendRouteName, extra: 1);
            }
          });
        }
      } else {
        if (mounted) {
          SnackBar snackBar = const SnackBar(
            content: Text('Tạo nhóm thất bại'),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      }
    });
  }

  void createChannel(dynamic obj) {
    SocketConfig.emit(SocketMessage.createChannel, obj);
  }

  late final TabController _tabController =
      TabController(length: 2, vsync: this);
  late String dropdownValue = 'Public';
  late String name = "";
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nhóm mới"),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            margin: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    onChanged: (value) => {
                      setState(() {
                        name = value;
                      }),
                    },
                    decoration: InputDecoration(
                      hintText: 'Tên nhóm',
                      contentPadding: const EdgeInsets.all(10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                DropdownButton<String>(
                  value: dropdownValue,
                  icon: const Icon(Icons.arrow_drop_down_circle_outlined),
                  elevation: 16,
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  // border for it
                  borderRadius: BorderRadius.circular(10),

                  onChanged: (String? value) {
                    setState(() {
                      dropdownValue = value!;
                    });
                  },
                  items: list.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          selectedUsersFinal.isNotEmpty
              ? Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Row(
                        children: selectedUsersFinal
                            .map((e) => Container(
                                  margin: const EdgeInsets.only(left: 10),
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundImage: NetworkImage(e.avatar!),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    BlocBuilder<ChannelCubit, ChannelState>(
                      builder: (context, state) {
                        return TextButton(
                          onPressed: () async {
                            List<String> users =
                                selectedUsersFinal.map((e) => e.id!).toList();
                            if (name.isEmpty) {
                              SnackBar snackBar = const SnackBar(
                                content: Text('Tên nhóm không được để trống'),
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            } else if (users.length < 2) {
                              SnackBar snackBar = const SnackBar(
                                content: Text('Nhóm phải có ít nhất 2 người'),
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            } else {
                              Map<String, dynamic> obj = {
                                "name": name,
                                "isPublic":
                                    dropdownValue == 'Public' ? false : true,
                                "members": users
                              };
                              createChannel(obj);
                            }
                          },
                          child: const Text(
                            'Tạo nhóm ',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                  ],
                )
              : Container(),
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Gần đây'),
                Tab(text: 'Bạn bè'),
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
            child: Stack(children: [
              TabBarView(
                dragStartBehavior: DragStartBehavior.start,
                controller: _tabController,
                children: [
                  BlocBuilder<ChatCubit, ChatState>(builder: (context, state) {
                    if (state is ChatInitial) {
                      context.read<ChatCubit>().getAllChats();
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is GetAllChatsLoaded) {
                      List<Chat> all = state.chats;
                      return SingleChildScrollView(
                        child: Column(children: [
                          for (int i = 0; i < all.length; i++)
                            InkWell(
                              onTap: () {
                                setState(() {
                                  // ignore: collection_methods_unrelated_type
                                  if (selectedUsersFinal
                                      .map((e) => e.id)
                                      .contains(all[i].user!.id)) {
                                    selectedUsersFinal.remove(all[i].user);
                                  } else {
                                    selectedUsersFinal.add(all[i].user!);
                                  }
                                });
                              },
                              child: Container(
                                width: size.width,
                                padding: EdgeInsets.all(size.width * 0.02),
                                child: Row(
                                  children: [
                                    Container(
                                        margin: const EdgeInsets.only(left: 20),
                                        child: CircleAvatar(
                                            radius: 30,
                                            backgroundImage: NetworkImage(
                                                all[i].user!.avatar!))),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            all[i].user!.name!,
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                          all[i].timeThread != null
                                              ? Text(
                                                  formatTime(
                                                      all[i].timeThread!),
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey),
                                                )
                                              : const SizedBox(),
                                        ],
                                      ),
                                    ),
                                    Radio<String>(
                                      value: all[i].user!.id!,
                                      groupValue: selectedUsersFinal
                                              .map((e) => e.id)
                                              .contains(all[i].user!.id!)
                                          ? all[i].user!.id!
                                          : null,
                                      onChanged: (String? value) {},
                                    )
                                  ],
                                ),
                              ),
                            )
                        ]),
                      );
                    } else {
                      return const Text('Error');
                    }
                  }),
                  BlocBuilder<FriendCubit, FriendState>(
                    builder: (context, state) {
                      if (state is FriendInitial) {
                        context.read<FriendCubit>().whitelistFriendAccept();
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is WhitelistFriendAcceptLoaded) {
                        List<Chat> all = state.chats;
                        return SingleChildScrollView(
                          child: Column(children: [
                            for (int i = 0; i < all.length; i++)
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    // ignore: collection_methods_unrelated_type
                                    if (selectedUsersFinal
                                        .map((e) => e.id)
                                        .contains(all[i].user!.id)) {
                                      selectedUsersFinal.remove(all[i].user);
                                    } else {
                                      selectedUsersFinal.add(all[i].user!);
                                    }
                                  });
                                },
                                child: Container(
                                  width: size.width,
                                  padding: EdgeInsets.all(size.width * 0.02),
                                  child: Row(
                                    children: [
                                      Container(
                                          margin:
                                              const EdgeInsets.only(left: 20),
                                          child: CircleAvatar(
                                              radius: 30,
                                              backgroundImage: NetworkImage(
                                                  all[i].user!.avatar!))),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                              all[i].user!.name!,
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                            // all[i].timeThread != null
                                            //     ? Text(
                                            //         formatTime(
                                            //             all[i].timeThread!),
                                            //         style: const TextStyle(
                                            //             fontSize: 12,
                                            //             color: Colors.grey),
                                            //       )
                                            //     : const SizedBox(),
                                          ],
                                        ),
                                      ),
                                      Radio<String>(
                                        value: all[i].user!.id!,
                                        groupValue: selectedUsersFinal
                                                .map((e) => e.id)
                                                .contains(all[i].user!.id!)
                                            ? all[i].user!.id!
                                            : null,
                                        onChanged: (String? value) {},
                                      )
                                    ],
                                  ),
                                ),
                              )
                          ]),
                        );
                      } else {
                        return const Text('Error');
                      }
                    },
                  ),
                ],
              ),
            ]),
          ),
        ],
      ),
    );
  }

  String formatTime(DateTime time) {
    var now = DateTime.now();
    var duration = now.difference(time);

    if (duration.inDays > 0) {
      var dateFormat =
          DateFormat(duration.inDays > 365 ? 'dd/MM/yyyy' : 'dd/MM');
      return dateFormat.format(time);
    } else if (duration.inHours > 0) {
      return "${duration.inHours} giờ trước";
    } else if (duration.inMinutes > 0) {
      return "${duration.inMinutes} phút trước";
    } else {
      return "Vừa xong";
    }
  }
}
