// ignore_for_file: avoid_init_to_null

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zalo_app/config/routes/app_route_constants.dart';
import 'package:zalo_app/config/socket/socket.dart';
import 'package:zalo_app/config/socket/socket_event.dart';
import 'package:zalo_app/config/socket/socket_message.dart';
import 'package:zalo_app/model/channel.model.dart';
import 'package:zalo_app/model/chat.model.dart';
import 'package:zalo_app/model/file.model.dart';
import 'package:zalo_app/model/user.model.dart';
import 'package:zalo_app/services/api_service.dart';

class MoreInfo extends StatefulWidget {
  const MoreInfo({
    super.key,
    this.data,
  });
  final dynamic data;

  @override
  State<MoreInfo> createState() => _MoreInfoState();
}

class _MoreInfoState extends State<MoreInfo> {
  late Channel? channel = null;
  late Chat? chat = null;
  List<FileModel> files = [];
  List<FileModel> filesUI = [];
  late bool isAdmin = false;
  List<User> users = [];
  List<User> members = [];
  late bool isEdit = false;
  late String name = "";
  User userSelected = User();
  late String userId = "";
  late bool leaving = false;
  late bool deleteChannel = false;

  final api = API();
  void _isAdmin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token") ?? "";
    var userOfToken = prefs.getString(token) ?? "";
    // SocketConfig.connect(token);
    if (userOfToken != "") {
      User currentUser = User.fromJson(userOfToken);
      setState(() {
        userId = currentUser.id!;
      });
      User admin = channel!.users!.firstWhere(
        (element) => element.id == currentUser.id!,
      );
      if (admin.role! == "ADMIN") {
        setState(() {
          isAdmin = true;
        });
      }
      for (var user in channel!.users!) {
        if (user.id != admin.id) {
          setState(() {
            users.add(user);
          });
        }
      }
      setState(() {
        userSelected = users[0];
      });
    }
  }

  void getMembers(String id) async {
    final response = await api.get("channels/$id/members", {});
    if (response != null) {
      if (mounted) {
        setState(() {
          members = (response as List).map((e) => User.fromMap(e)).toList();
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.data["type"] == "channel") {
      _isAdmin();

      channel = widget.data["data"];
      getMembers(channel!.id!);
      for (var thread in channel!.threads!) {
        for (var file in thread.files!) {
          files.add(file);
        }
      }
    } else {
      chat = widget.data["data"];
      for (var thread in chat!.threads!) {
        for (var file in thread.files!) {
          files.add(file);
        }
      }
    }

    var fileImage = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
    for (var file in files) {
      if (fileImage.contains(file.path!.split('.').last)) {
        filesUI.add(file);
      }
    }
  }
//   {
//     "channelUpdate":{
//         "name":"update socket channel 300"
//     },
//     "channelId":"65ea7894304905092a6d02f6"
// }

  void updateChannel(String channelId, String name) {
    var data = {
      "channelUpdate": {"name": name},
      "channelId": channelId
    };

    setState(() {
      channel!.name = name;
      Navigator.pop(context);
    });
    SocketConfig.emit(SocketMessage.updateChannel, data);
    SocketConfig.listen(SocketEvent.channelWS, (response) {
      var status = response['status'];
      var data = response['data'];
      if (status == 200) {
        if (mounted) {
          var type = data["type"];

          if (type == "updateChannel") {
            setState(() {
              channel!.name = name;
              Navigator.pop(context);
              isEdit = false;
            });
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tùy chọn"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        //style for appbar
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            chat != null
                ? SizedBox(
                    height: 80,
                    width: 80,
                    child: Center(
                      child: InkWell(
                        onTap: () {
                          GoRouter.of(context).pushNamed(
                              MyAppRouteConstants.profileRouteName,
                              extra: {"user": chat!.user, "chatId": chat!.id});
                        },
                        child: CircleAvatar(
                          radius: 25,
                          backgroundImage:
                              NetworkImage(chat!.user!.avatar ?? ""),
                        ),
                      ),
                    ),
                  )
                : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    SizedBox(
                      height: 70,
                      width: 80,
                      child: GridView.count(
                        primary: false,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.all(10),
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                        crossAxisCount: 2,
                        children: [
                          for (var user in channel!.users!.take(4))
                            user.avatar != null
                                ? CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(user.avatar ?? ""))
                                : Center(
                                    child: CircleAvatar(
                                      child: Text(
                                        user.name.toString()[0],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 25,
                                        ),
                                      ),
                                    ),
                                  ),
                        ],
                      ),
                    )
                  ]),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    chat != null ? chat!.user!.name.toString() : channel!.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  chat == null
                      ? IconButton(
                          onPressed: () {
                            setState(() {
                              isEdit = true;
                            });
                            if (isEdit) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                      title: const Text("Nhập tên mới"),
                                      actions: [
                                        ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              isEdit = false;
                                              Navigator.pop(context);
                                            });
                                          },
                                          child: const Text("Huỷ"),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            updateChannel(channel!.id!, name);
                                          },
                                          child: const Text("Lưu"),
                                        ),
                                      ],
                                      content: TextField(
                                        onChanged: (value) {
                                          setState(() {
                                            name = value;
                                          });
                                        },
                                      ));
                                },
                              );
                            }
                          },
                          icon: const Icon(Icons.edit_note_outlined),
                        )
                      : Container(),
                ],
              ),
            ),
            chat == null
                ? const Divider(
                    height: 20,
                    thickness: 4,
                  )
                : Container(),
            chat == null
                ? InkWell(
                    child: Container(
                        alignment: Alignment.center,
                        width: double.infinity,
                        child: const Text("Thêm thành viên")),
                    //dont border rad
                    onTap: () {
                      List<String> members =
                          channel!.users!.map((e) => e.id!).toList();
                      GoRouter.of(context).pushNamed(
                          MyAppRouteConstants.addMemberRouteName,
                          extra: {
                            "members": members,
                            "channelId": channel!.id
                          });
                    },
                  )
                : Container(),
            const Divider(
              height: 20,
              thickness: 4,
            ),
            const Row(
              children: [
                SizedBox(
                  width: 10,
                ),
                Icon(Icons.folder_open_sharp),
                SizedBox(
                  width: 10,
                ),
                Text("Ảnh, file đã gửi"),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: 8, left: 40),
              child: GestureDetector(
                onTap: () {
                  GoRouter.of(context).pushNamed(
                      MyAppRouteConstants.allFileRouteName,
                      extra: files);
                },
                child: Row(
                  children: _buildChildren(filesUI),
                ),
              ),
            ),
            chat == null
                ? Column(
                    children: [
                      const Divider(
                        height: 20,
                        thickness: 4,
                      ),
                      const Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Icon(Icons.people_alt),
                          SizedBox(
                            width: 10,
                          ),
                          Text("Thành viên"),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Column(
                          children: [
                            for (var user in members)
                              ListTile(
                                onLongPress: () {
                                  if (user.role == "ADMIN") return;
                                  if (isAdmin) {
                                    showModalBottomSheet<void>(
                                      context: context,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      builder: (BuildContext context) {
                                        return SizedBox(
                                          height: 160,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: <Widget>[
                                                const SizedBox(height: 10),
                                                const Center(
                                                    child: Text(
                                                        "Thông tin thành viên")),
                                                const Divider(),
                                                Row(
                                                  children: [
                                                    user.avatar != null
                                                        ? CircleAvatar(
                                                            backgroundImage:
                                                                NetworkImage(
                                                                    user.avatar ??
                                                                        ""))
                                                        : CircleAvatar(
                                                            child: Text(
                                                              user.name
                                                                  .toString()[0],
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 25,
                                                              ),
                                                            ),
                                                          ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Text(user.name.toString()),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 3.0),
                                                  child: InkWell(
                                                    hoverColor:
                                                        Colors.transparent,
                                                    onTap: () {
                                                      if (user.role
                                                              .toString() ==
                                                          "CO-ADMIN") {
                                                        updateRoleUserInChannel(
                                                            channel!.id!,
                                                            user.id!,
                                                            "MEMBER");
                                                      } else {
                                                        updateRoleUserInChannel(
                                                            channel!.id!,
                                                            user.id!,
                                                            "CO-ADMIN");
                                                      }
                                                    },
                                                    child: Text(
                                                      user.role.toString() ==
                                                              "CO-ADMIN"
                                                          ? "Xoá vai trò phó nhóm"
                                                          : "Bổ nhiệm làm phó nhóm",
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 2.0),
                                                  child: InkWell(
                                                    hoverColor:
                                                        Colors.transparent,
                                                    onTap: () {
                                                      removeUserFromChannel(
                                                          channel!.id!,
                                                          user.id!);
                                                    },
                                                    child: const SizedBox(
                                                      width: double.infinity,
                                                      height: 30,
                                                      child: Text(
                                                          "Xoá khỏi nhóm",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red)),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }
                                },
                                leading: user.avatar != null
                                    ? CircleAvatar(
                                        backgroundImage:
                                            NetworkImage(user.avatar ?? ""))
                                    : CircleAvatar(
                                        child: Text(
                                          user.name.toString()[0],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 25,
                                          ),
                                        ),
                                      ),
                                title: user.role.toString() == "ADMIN"
                                    ? RichText(
                                        text: TextSpan(
                                        text: user.name.toString(),
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                        ),
                                        children: <TextSpan>[
                                          TextSpan(
                                            text:
                                                user.role.toString() == "ADMIN"
                                                    ? " (Trưởng nhóm)"
                                                    : "",
                                            style: const TextStyle(
                                              color: Colors.blue,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ))
                                    : Text(user.name.toString()),
                              ),
                          ],
                        ),
                      )
                    ],
                  )
                : Container(),
            isAdmin
                ? const Divider(
                    height: 20,
                    thickness: 2,
                  )
                : Container(),
            isAdmin
                ? GestureDetector(
                    onTap: () {},
                    child: const Row(
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        Icon(Icons.people_alt, color: Colors.red),
                        SizedBox(
                          width: 10,
                        ),
                        Text("Xóa lịch sử trò chuyện",
                            style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  )
                : Container(),
            const Divider(
              height: 20,
              thickness: 2,
            ),
            chat != null
                ? Container()
                : GestureDetector(
                    onTap: () {
                      if (isAdmin) {
                        showModalBottomSheet<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  const Text('Chọn trưởng nhóm trước khi rời'),
                                  SizedBox(
                                    height: 270,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          for (int i = 0; i < users.length; i++)
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  userSelected = users[i];
                                                });
                                              },
                                              child: Container(
                                                width: size.width,
                                                padding: EdgeInsets.all(
                                                    size.width * 0.02),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                        margin: const EdgeInsets
                                                            .only(left: 20),
                                                        child: CircleAvatar(
                                                            radius: 20,
                                                            backgroundImage:
                                                                NetworkImage(users[
                                                                        i]
                                                                    .avatar!))),
                                                    const SizedBox(
                                                      width: 20,
                                                    ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          Text(
                                                            users[i].name!,
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        16),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Radio<String>(
                                                      value: users[i].id!,
                                                      groupValue:
                                                          userSelected.id,
                                                      onChanged:
                                                          (String? value) {
                                                        setState(() {
                                                          setState(() {
                                                            userSelected = users
                                                                .firstWhere(
                                                                    (user) =>
                                                                        user.id ==
                                                                        value);
                                                          });
                                                        });
                                                      },
                                                    )
                                                  ],
                                                ),
                                              ),
                                            )
                                        ],
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    hoverColor: Colors.transparent,
                                    onTap: () {
                                      leaveChannel(channel!.id!);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                        top: 5,
                                        bottom: 5,
                                      ),
                                      margin: const EdgeInsets.all(4.0),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.blue,
                                          width: 1.0,
                                        ),
                                      ),
                                      width: double.infinity,
                                      child: const Center(
                                        child: Text(
                                          "Xác nhận",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    hoverColor: Colors.transparent,
                                    onTap: () {
                                      Navigator.pop(context);
                                      userSelected = users[0];
                                    },
                                    child: const SizedBox(
                                      width: double.infinity,
                                      height: 30,
                                      child: Center(
                                        child: Text("Hủy"),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      } else {
                        leaveChannel(channel!.id!);
                        GoRouter.of(context)
                            .pushNamed(MyAppRouteConstants.mainRouteName);
                      }
                    },
                    child: const Row(
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(
                          width: 10,
                        ),
                        Text("Rời nhóm", style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
            const Divider(
              height: 20,
              thickness: 2,
            ),
            isAdmin
                ? GestureDetector(
                    onTap: () {
                      _deleteChannel(channel!.id!);
                    },
                    child: const Row(
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        Icon(Icons.remove_circle_outline_sharp,
                            color: Colors.red),
                        SizedBox(
                          width: 10,
                        ),
                        Text("Giải tán nhóm",
                            style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  void _deleteChannel(String channelId) {
    var data = {"channelId": channelId};
    SocketConfig.emit(SocketMessage.deleteChannel, data);

    setState(() {
      deleteChannel = true;
    });
    if (deleteChannel) {
      SnackBar snackBar = const SnackBar(
        content: Text("Đang giải tán nhóm..."),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    SocketConfig.listen(SocketEvent.channelWS, (response) {
      var status = response['status'];
      var data = response['data'];
      if (status == 200) {
        if (mounted) {
          var c = data["channel"];
          var type = data["type"];

          if (c["id"] == channel!.id && type == "deleteChannel") {
            setState(() {
              leaving = false;
            });
            SnackBar snackBar = const SnackBar(
              content: Text("Giải tán nhóm thành công"),
              duration: Duration(seconds: 2),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            //delay 2s
            Future.delayed(const Duration(seconds: 2), () {
              GoRouter.of(context).go(MyAppRouteConstants.mainRouteName);
              // Navigator.pop(context);
            });
          }
        }
      }
    });
  }

  void leaveChannel(String channelId) {
    var data = {"channelId": channelId};
    if (isAdmin) {
      data["transferOwner"] = userSelected.id!;
      Navigator.pop(context);
    }

    setState(() {
      leaving = true;
    });
    if (leaving) {
      SnackBar snackBar = const SnackBar(
        content: Text("Đang rời nhóm..."),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    SocketConfig.emit(SocketMessage.leaveChannel, data);
    SocketConfig.listen(SocketEvent.channelWS, (response) {
      var status = response['status'];
      var data = response['data'];
      if (status == 200) {
        if (mounted) {
          var c = data["channel"];
          var type = data["type"];

          if (c["id"] == channel!.id && type == "leaveChannel") {
            setState(() {
              leaving = false;
            });
            SnackBar snackBar = const SnackBar(
              content: Text("Rời nhóm thành công"),
              duration: Duration(seconds: 2),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            //delay 2s
            Future.delayed(const Duration(seconds: 2), () {
              // GoRouter.of(context).go(MyAppRouteConstants.mainRouteName);
              // Navigator.pop(context);
            });
          }
        }
      }
    });
  }

  void updateRoleUserInChannel(String channelId, String userId, String role) {
    var data = {
      "channelId": channelId,
      "user": {"id": userId, "role": role}
    };
    SocketConfig.emit(SocketMessage.updateRoleUserInChannel, data);
    Navigator.pop(context);
  }

  void removeUserFromChannel(String channelId, String userId) {
    var data = {"channelId": channelId, "userId": userId};

    setState(() {
      channel!.users!.removeWhere((user) => user.id == userId);
    });

    SocketConfig.emit(SocketMessage.removeUserFromChannel, data);
    Navigator.pop(context);
  }

  List<Widget> _buildChildren(List<FileModel> files) {
    List<Widget> widgets = [];
    for (int i = 0; i < files.length; i++) {
      //just keep image file
      String fileType = files[i].path!.split('.').last;
      if (fileType == 'jpg' ||
          fileType == 'jpeg' ||
          fileType == 'png' ||
          fileType == 'gif' ||
          fileType == "webp") {
        if (i > 3) {
          widgets.add(
            Container(
              width: 80,
              height: 80,
              color: Colors.blue,
              child: Center(
                child: Text(
                  "+${files.length - 4}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          );
          break;
        } else {
          widgets.add(
            Container(
              margin: const EdgeInsets.only(right: 10),
              width: 80,
              height: 80,
              child: Image.network(
                files[i].path ?? "",
                fit: BoxFit.cover,
              ),
            ),
          );
        }
      }
    }
    return widgets;
  }
}
