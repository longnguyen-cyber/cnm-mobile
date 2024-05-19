import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zalo_app/config/routes/app_route_constants.dart';
import 'package:zalo_app/config/socket/socket.dart';
import 'package:zalo_app/config/socket/socket_event.dart';
import 'package:zalo_app/config/socket/socket_message.dart';
import 'package:zalo_app/model/chat.model.dart';
import 'package:zalo_app/model/user.model.dart';
import 'package:zalo_app/services/api_service.dart';

class CreateChannelScreen extends StatefulWidget {
  const CreateChannelScreen({super.key});

  @override
  State<CreateChannelScreen> createState() => _CreateChannelScreenState();
}

class _CreateChannelScreenState extends State<CreateChannelScreen>
    with TickerProviderStateMixin {
  final api = API();
  List<Chat> all = [];
  List<Chat> whitelist = [];
  late String userId = "";
  late bool adding = false;
  List<User> selectedUsersFinal = [];

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
    String urlAll = "chats";
    String urlWhiteList = "chats/friend/whitelistFriendAccept";

    final responseWaitList = await api.get(urlAll, {});
    final responseWhiteList = await api.get(urlWhiteList, {});

    if (mounted) {
      setState(() {
        all = (responseWaitList["data"] as List)
            .map((e) => Chat.fromMap(e))
            .toList();

        whitelist = (responseWhiteList["data"] as List)
            .map((e) => Chat.fromMap(e))
            .toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getAll();
  }

  void createChannel(dynamic obj) {
    setState(() {
      adding = true;
    });
    SocketConfig.listen(SocketEvent.channelWS, (response) {
      var status = response['status'];
      var data = response['data'];

      if (status == 201) {
        var userIds = (data["users"] as List)
            .map((e) => User.fromMap(e))
            .toList()
            .map((e) => e.id)
            .toList();
        if (userIds.contains(userId)) {
          setState(() {
            adding = false;
          });
          SnackBar snackBar = const SnackBar(
            content: Text("Tạo nhóm thành công"),
            duration: Duration(seconds: 2),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          //delay 2s
          Future.delayed(const Duration(seconds: 2), () {
            GoRouter.of(context).pushNamed(MyAppRouteConstants.mainRouteName);
            // Navigator.pop(context);
          });
        }
      }
    });
    SocketConfig.emit(SocketMessage.createChannel, obj);
  }

  late String name = "";
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tạo nhóm mới"),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      bottomNavigationBar: selectedUsersFinal.isNotEmpty
          ? Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                ),
              ),
              height: 60,
              child: Row(
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
                  adding
                      ? const CircularProgressIndicator()
                      : IconButton(
                          onPressed: () {
                            // Navigator.pop(context)
                            // ;
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
                                "members": users
                              };
                              createChannel(obj);
                            }
                          },
                          icon: const Icon(Icons.send),
                        ),
                  const SizedBox(
                    width: 10,
                  )
                ],
              ),
            )
          : null,
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
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
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
                                    backgroundImage:
                                        NetworkImage(all[i].user!.avatar!))),
                            const SizedBox(
                              width: 20,
                            ),
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    all[i].user!.name!,
                                    style: const TextStyle(fontSize: 16),
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
                ],
              ),
            ),
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
