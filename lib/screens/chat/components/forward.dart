import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zalo_app/config/socket/socket.dart';
import 'package:zalo_app/config/socket/socket_message.dart';
import 'package:zalo_app/model/chat.model.dart';
import 'package:zalo_app/services/api_service.dart';

class Forward extends StatefulWidget {
  const Forward({super.key, required this.content});
  final String content;

  @override
  // ignore: library_private_types_in_public_api
  _ForwardState createState() => _ForwardState();
}

class _ForwardState extends State<Forward> {
  final api = API();
  List<Chat> all = [];
  List<Chat> selectedChatFinal = [];

  void getAll() async {
    final response = await api.get("all", {});

    if (mounted) {
      setState(() {
        for (var item in response) {
          if (item["type"] == "chat") {
            all.add(Chat.fromMap(item));
          }
        }
      });
    }
  }

  void forwardMessage() {
    for (var user in selectedChatFinal) {
      SocketConfig.emit(SocketMessage.sendThread, {
        "messages": {
          "message": widget.content,
        },
        "chatId": user.id,
        "receiveId": user.user!.id,
      });
    }
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    getAll();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      bottomNavigationBar: selectedChatFinal.isNotEmpty
          ? Positioned(
              child: Container(
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
                        children: selectedChatFinal
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
                    IconButton(
                      onPressed: () {
                        forwardMessage();
                        // Navigator.pop(context);
                      },
                      icon: const Icon(Icons.send),
                    ),
                    const SizedBox(
                      width: 10,
                    )
                  ],
                ),
              ),
            )
          : null,
      appBar: AppBar(
        title: const Text("Chuyển tiếp"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Text("${selectedChatFinal.length} đã chọn"),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
                padding: EdgeInsets.only(left: 40), child: Text("Gần đây")),
            for (int i = 0; i < all.length; i++)
              InkWell(
                onTap: () {
                  setState(() {
                    // ignore: collection_methods_unrelated_type
                    if (selectedChatFinal
                        .map((e) => e.id)
                        .contains(all[i].id)) {
                      selectedChatFinal.remove(all[i]);
                    } else {
                      selectedChatFinal.add(all[i]);
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
                            all[i].timeThread != null
                                ? Text(
                                    formatTime(all[i].timeThread!),
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      ),
                      Radio<String>(
                        value: all[i].id!,
                        groupValue: selectedChatFinal
                                .map((e) => e.id)
                                .contains(all[i].id)
                            ? all[i].id
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
