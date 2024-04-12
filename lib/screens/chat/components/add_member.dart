import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zalo_app/config/socket/socket.dart';
import 'package:zalo_app/config/socket/socket_event.dart';
import 'package:zalo_app/config/socket/socket_message.dart';
import 'package:zalo_app/model/chat.model.dart';
import 'package:zalo_app/model/user.model.dart';
import 'package:zalo_app/services/api_service.dart';

class AddMember extends StatefulWidget {
  const AddMember({super.key, required this.members, required this.channelId});

  final List<String> members;
  final String channelId;
  @override
  State<AddMember> createState() => AddMemberState();
}

class AddMemberState extends State<AddMember> with TickerProviderStateMixin {
  final api = API();
  late String userId = "";
  List<Chat> selectedFriendsFinal = [];
  List<Chat> searchFriends = [];
  List<Chat> defaultList = [];
  late bool adding = false;

  List<Chat> whiteList = [];
  void getFriends() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var token = prefs.getString("token") ?? "";
    var userOfToken = prefs.getString(token) ?? "";
    if (userOfToken != "") {
      userId = User.fromJson(userOfToken).id!;
      setState(() {
        userId = userId;
      });
    }
    String urlWhiteList = "chats/friend/whitelistFriendAccept";

    final responseWhiteList = await api.get(urlWhiteList, {});
    if (mounted) {
      setState(() {
        whiteList = (responseWhiteList["data"] as List)
            .map((e) => Chat.fromMap(e))
            .toList();
        defaultList = (responseWhiteList["data"] as List)
            .map((e) => Chat.fromMap(e))
            .toList();
      });
    }
  }

  void searchFriend(String name) async {
    String url = "chats/search/$name";

    final responseSearch = await api.get(url, {});

    if (mounted) {
      setState(() {
        searchFriends = (responseSearch["data"] as List)
            .map((e) => Chat.fromMap(e))
            .toList();
        whiteList = searchFriends;
      });
    }
  }

  void addMember(List<Map<String, dynamic>> members) {
    var data = {
      "channelId": widget.channelId,
      "users": members,
    };
    setState(() {
      adding = true;
    });
    SocketConfig.emit(SocketMessage.addUserToChannel, data);
    SocketConfig.listen(SocketEvent.channelWS, (response) {
      var status = response['status'];
      var data = response['data'];
      if (status == 200) {
        if (mounted) {
          var channel = data["channel"];
          if (channel["id"] == widget.channelId) {
            setState(() {
              adding = false;
            });
            SnackBar snackBar = const SnackBar(
              content: Text("Thêm thành viên thành công"),
              duration: Duration(seconds: 2),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            //delay 2s
            Future.delayed(const Duration(seconds: 2), () {
              Navigator.pop(context);
            });
          }
        }
      }
    });
    // GoRouter.of(context).pushNamed(MyAppRouteConstants.mainRouteName);
  }

  @override
  void initState() {
    super.initState();
    getFriends();
  }

  void createChannel(dynamic obj) {
    SocketConfig.emit(SocketMessage.createChannel, obj);
  }

  late String name = "";
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    List<String> members = widget.members;

    return Scaffold(
      bottomNavigationBar: selectedFriendsFinal.isNotEmpty
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
                      children: selectedFriendsFinal
                          .map((e) => Container(
                                margin: const EdgeInsets.only(left: 10),
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundImage:
                                      NetworkImage(e.user!.avatar!),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  adding
                      ? const CircularProgressIndicator()
                      : IconButton(
                          onPressed: () {
                            // forwardMessage();
                            List<Map<String, dynamic>> members = [];
                            for (var user in selectedFriendsFinal) {
                              members
                                  .add({"id": user.user!.id, "role": "MEMBER"});
                            }
                            addMember(members);
                            // Navigator.pop(context);
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
      appBar: AppBar(
        title: const Text("Thêm thành viên"),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
              child: TextFormField(
                onChanged: (value) {
                  if (value.isEmpty) {
                    setState(() {
                      whiteList = defaultList;
                    });
                  } else {
                    searchFriend(value);
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm tên bạn bè',
                  contentPadding: const EdgeInsets.all(10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            for (int i = 0; i < whiteList.length; i++)
              InkWell(
                onTap: () {
                  if (members.contains(whiteList[i].user!.id!)) {
                    return;
                  }
                  setState(() {
                    // ignore: collection_methods_unrelated_type
                    if (selectedFriendsFinal
                        .map((e) => e.id)
                        .contains(whiteList[i].id)) {
                      selectedFriendsFinal.remove(whiteList[i]);
                    } else {
                      selectedFriendsFinal.add(whiteList[i]);
                    }
                  });
                },
                child: Container(
                  width: size.width,
                  padding: EdgeInsets.all(size.width * 0.02),
                  color: members.contains(whiteList[i].user!.id!)
                      ? Colors.grey[300]
                      : Colors.white,
                  child: Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 20),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundImage:
                              NetworkImage(whiteList[i].user!.avatar!),
                        ),
                      ),
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
                              whiteList[i].user!.name!,
                              style: const TextStyle(fontSize: 16),
                            ),
                            whiteList[i].timeThread != null
                                ? Text(
                                    formatTime(whiteList[i].timeThread!),
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      ),
                      Radio<String>(
                        value: whiteList[i].id!,
                        groupValue: members.contains(whiteList[i].user!.id!)
                            ? whiteList[i].id!
                            : selectedFriendsFinal
                                    .map((e) => e.id)
                                    .contains(whiteList[i].id)
                                ? whiteList[i].id
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
