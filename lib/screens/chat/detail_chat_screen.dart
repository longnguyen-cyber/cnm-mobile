import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zalo_app/config/routes/app_route_constants.dart';
import 'package:zalo_app/config/socket/socket.dart';
import 'package:zalo_app/config/socket/socket_event.dart';
import 'package:zalo_app/config/socket/socket_message.dart';
import 'package:zalo_app/model/channel.model.dart';
import 'package:zalo_app/model/chat.model.dart';
import 'package:zalo_app/model/thread.model.dart';
import 'package:zalo_app/model/user.model.dart';
import 'package:zalo_app/screens/chat/components/message_bubble.dart';
import 'package:zalo_app/screens/chat/controllers/voice_controller.dart';
import 'package:zalo_app/screens/chat/enums/messenger_type.dart';
import 'package:zalo_app/services/api_service.dart';

import 'components/index.dart';
import 'components/on_record_voice_message.dart';

class DetailChatScreen extends StatefulWidget {
  const DetailChatScreen({super.key, required this.data});
  final dynamic data;

  // final ChatRoom chatRoom;

  @override
  State<DetailChatScreen> createState() => _DetailChatScreenState();
}

class _DetailChatScreenState extends State<DetailChatScreen> {
  User? userExisting = User();

  final messageController = TextEditingController();
  bool isTextNotEmpty = false;
  final List<dynamic> messages = [];
  String _replyUser = "";
  String _replyContent = "";
  bool _reply = false;
  List<Thread> threadsChannel = [];
  List<Thread> threadsChat = [];
  late dynamic data;

  final api = API();

  void getData() async {
    String type = widget.data["type"];
    String id = widget.data["id"];
    if (mounted) {
      if (type == "chat") {
        final response = await api.get("chats/$id", {});
        if (response != null) {
          Chat chat = Chat.fromMap(response["data"]);
          setState(() {
            threadsChat = chat.threads!;
            data = chat;
          });
        }
      } else {
        final response = await api.get("channels/$id", {});
        if (response != null) {
          Channel channel = Channel.fromMap(response["data"]);
          setState(() {
            threadsChannel = channel.threads!;
            data = channel;
          });
        }
      }
    }
  }

  void getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token") ?? "";
    var userOfToken = prefs.getString(token) ?? "";
    // SocketConfig.connect(token);
    if (userOfToken != "") {
      userExisting = User.fromJson(userOfToken);
    } else {
      userExisting = null;
    }
    setState(() {
      userExisting = userExisting;
    });
  }

  @override
  void initState() {
    super.initState();
    getUser();
    getData();

    SocketConfig.listen(SocketEvent.updatedSendThread, (response) {
      var members = response['members'] != null
          ? (response['members'] as List<dynamic>).map((e) => e).toList()
          : [];

      if (mounted) {
        if (response["typeMsg"] == "recall" ||
            response["typeMsg"] == "delete") {
          setState(() {
            if (response["type"] == "chat") {
              var indexOfThread = threadsChat
                  .indexWhere((element) => element.id == response['threadId']);
              if (indexOfThread != -1) {
                if (response["typeMsg"] == "delete") {
                  threadsChat.removeAt(indexOfThread);
                } else {
                  threadsChat[indexOfThread].isRecall = true;
                  threadsChat[indexOfThread].messages!.message =
                      "Tin nhắn đã bị thu hồi";
                }
              }
            } else {
              var indexOfThread = threadsChannel
                  .indexWhere((element) => element.id == response['threadId']);
              if (indexOfThread != -1) {
                if (response["typeMsg"] == "delete") {
                  threadsChannel.removeAt(indexOfThread);
                } else {
                  threadsChannel[indexOfThread].isRecall = true;
                  threadsChannel[indexOfThread].messages!.message =
                      "Tin nhắn đã bị thu hồi";
                }
              }
            }
          });
        } else {
          //send new message
          var data = {
            "id": "234234234",
            "messages": {"message": response['messages']['message']},
            "user": response['user'],
            "isReply": response['isReply'],
            "isRecall": response['isRecall'],
            "createdAt": response['timeThread'] as String,
            "receiveId": response['receiveId']
          };
          Thread thread = Thread.fromMap(data);
          if (members.contains(userExisting!.id)) {
            setState(() {
              threadsChannel.add(thread);
            });
          } else if (response["receiveId"] == userExisting!.id ||
              response["user"]["id"] == userExisting!.id) {
            setState(() {
              threadsChat.add(thread);
            });
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);

    final String name = widget.data["name"];
    final String type = widget.data["type"];
    late dynamic members;
    if (widget.data["type"] == "channel") {
      members = widget.data["members"];
    }

    return Scaffold(
        appBar: AppBar(
          title: Column(
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
              if (type == "channel")
                Text(
                  "${members.length} thành viên",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {
                GoRouter.of(context).pushNamed(
                    MyAppRouteConstants.moreRouteName,
                    extra: {"data": data, "type": type});
              },
              icon: const Icon(Icons.format_list_bulleted),
            ),
          ],
          backgroundColor: Colors.blue,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: type == 'channel'
            ? common(viewInsets, threadsChannel, type)
            : common(viewInsets, threadsChat, type));
  }

  SafeArea common(EdgeInsets viewInsets, List<Thread> threads, String type) {
    Size size = MediaQuery.of(context).size;
    ScrollController controller = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.hasClients) {
        controller.jumpTo(controller.position.maxScrollExtent);
      }
    });
    bool isDifferentDay(int index) {
      if (index == threads.length - 1) {
        return false; // Always false for the last message
      }

      DateTime currentMessageDate = (threads[index].createdAt!);
      DateTime nextMessageDate = (threads[index + 1].createdAt!);

      return currentMessageDate.day != nextMessageDate.day ||
          currentMessageDate.month != nextMessageDate.month ||
          currentMessageDate.year != nextMessageDate.year;
    }

    handleFilePicked() async {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        // gửi file
      } else {
        // Xu ly khi khong chon file
      }
    }

    return SafeArea(
        child: Container(
      width: double.infinity,
      color: Colors.blueGrey[50],
      child: Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 8.0,
            bottom: (viewInsets.bottom > 0) ? 8.0 : 0.0,
          ),
          child: Column(children: <Widget>[
            Expanded(
              child: ListView.builder(
                controller: controller,
                itemCount: threads.length,
                itemBuilder: (BuildContext context, int index) {
                  Thread thread = threads[index];
                  List<Widget> children = [];
                  if (thread.user == null) {
                    children.add(
                      Text(
                        thread.messages!.message,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    );
                  } else {
                    bool nameExisted = index > 0 &&
                        threads[index - 1].user != null &&
                        threads[index - 1].user!.name == thread.user!.name;

                    if (thread.user!.id == userExisting!.id) {
                      children.add(
                        MessageBubble(
                          threadId: thread.id!,
                          user: userExisting!,
                          receiveId:
                              thread.receiveId != null ? thread.receiveId! : "",
                          type: type,
                          content: thread.messages!.message,
                          timeSent: (thread.createdAt!),
                          isReply: thread.isReply,
                          isRecall: thread.isRecall,
                          onFuctionReply: (sender, content) {
                            setState(() {
                              _reply = true;
                              _replyUser = sender;
                              _replyContent = content;
                            });
                          },
                        ),
                      );
                    } else {
                      children.add(
                        Message(
                          threadId: thread.id!,
                          sender: thread.user!,
                          type: type,
                          content: thread.messages!.message,
                          messageType: MessageType.text,
                          timeSent: thread.createdAt!,
                          onFuctionReply: (sender, content) {
                            setState(() {
                              _reply = true;
                              _replyUser = sender;
                              _replyContent = content;
                            });
                          },
                          exist: !nameExisted,
                          isRecall: thread.isRecall!,
                        ),
                      );
                    }
                  }

                  if (isDifferentDay(index)) {
                    DateTime currentMessageDate = (threads[index].createdAt!);
                    DateTime now = DateTime.now();

                    String formattedDate;
                    if (currentMessageDate.year == now.year &&
                        currentMessageDate.month == now.month &&
                        currentMessageDate.day == now.day - 1) {
                      formattedDate = 'Hôm qua';
                    } else {
                      formattedDate =
                          DateFormat('dd/MM/yyyy').format(currentMessageDate);
                    }

                    children.add(
                      Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 60),
                            child: const Divider(
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(children: children);
                },
              ),
            ),
            _reply
                ? Row(children: <Widget>[
                    Container(
                      width: size.width * 0.9,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white54,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                          ),
                          Container(
                            width: 3, // Độ rộng của đường kẻ thẳng đứng
                            height:
                                40, // Chiều cao tối thiểu để giữ khoảng cách giữa hai đoạn văn bản
                            color: Colors.blue, // Màu sắc của đường kẻ thẳng
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                  text: '  $_replyUser\n',
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 16),
                                ),
                                TextSpan(
                                  text: _replyContent,
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Positioned(
                            top: 0,
                            left: 0,
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _reply = false;
                                });
                              },
                              icon: const Icon(Icons.close),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ])
                : Container(),
            Row(children: [
              IconButton(
                onPressed: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? image =
                      await picker.pickImage(source: ImageSource.camera);
                },
                icon: const Icon(Icons.camera_alt),
              ),
              Expanded(
                  child: TextFormField(
                controller: messageController,
                onChanged: (value) {
                  setState(() {
                    isTextNotEmpty = value.isNotEmpty;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Tin nhắn',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    borderSide: BorderSide.none,
                  ),
                  // Kiểm tra biến isTextNotEmpty để xác định icon sẽ hiển thị
                  suffixIcon: isTextNotEmpty
                      ? IconButton(
                          onPressed: () {
                            // Xử lý sự kiện khi trường văn bản không trống
                            _sendMessage();
                          },
                          icon: const Icon(Icons.send),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => handleFilePicked(),
                              icon: const Icon(Icons.attach_file),
                            ),
                            IconButton(
                              onPressed: () {
                                showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext context) {
                                      VoiceController voiceController =
                                          VoiceController();
                                      voiceController.record();
                                      return OnRecordMessage(
                                          voiceController: voiceController);
                                    });
                              },
                              icon: const Icon(Icons.mic),
                            ),
                            IconButton(
                              onPressed: () async {
                                final ImagePicker picker = ImagePicker();
                                // Pick an image
                                final List<XFile> medias =
                                    await picker.pickMultipleMedia();
                              },
                              icon: const Icon(Icons.image),
                            ),
                            // Thêm các IconButton khác nếu cần
                          ],
                        ),
                ),
              )),
            ]),
            const SizedBox(height: 8.0),
          ])),
    ));
  }

  bool checkTimeSentWithCurrentTime(DateTime time) {
    var timeSent = time.toLocal().toString().split(" ")[0];
    var now = DateTime.now().toString().split(" ")[0];

    return timeSent == now;
  }

  void _sendMessage() {
    late String receiveId;
    late dynamic members;
    if (widget.data["type"] == "channel") {
      members = widget.data["members"].map((e) => e["id"]).toList();
    } else {
      receiveId = widget.data["receiverId"];
    }
    if (messageController.text.isNotEmpty) {
      if (widget.data["type"] == "channel") {
        SocketConfig.emit(SocketMessage.sendThread, {
          "messages": {
            "message": messageController.text,
          },
          "channelId": widget.data["id"],
          "members": members,
        });
      } else {
        SocketConfig.emit(SocketMessage.sendThread, {
          "messages": {
            "message": messageController.text,
          },
          "chatId": widget.data["id"],
          "receiveId": receiveId,
        });
      }
      messageController.clear();
    }
  }
}

//


