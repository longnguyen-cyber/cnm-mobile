import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zalo_app/blocs/bloc_channel/channel_cubit.dart';
import 'package:zalo_app/blocs/bloc_chat/chat_cubit.dart';
import 'package:zalo_app/config/socket/socket.dart';
import 'package:zalo_app/config/socket/socket_event.dart';
import 'package:zalo_app/config/socket/socket_message.dart';
import 'package:zalo_app/model/channel.model.dart';
import 'package:zalo_app/model/chat.model.dart';
import 'package:zalo_app/model/thread.model.dart';
import 'package:zalo_app/model/user.model.dart';
import 'package:zalo_app/screens/chat/components/message_bubble.dart';
import 'package:zalo_app/screens/chat/enums/messenger_type.dart';

import 'components/index.dart';

class DetailChatScreen extends StatefulWidget {
  const DetailChatScreen({
    super.key,
    required this.id,
    required this.type,
    // required this.chatRoom
  });
  final String id;
  final String type;

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

  void getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token") ?? "";
    var userOfToken = prefs.getString(token) ?? "";
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

    SocketConfig.listen(SocketEvent.updatedSendThread, (response) {
      var members =
          (response['members'] as List<dynamic>).map((e) => e["id"]).toList();

      if (members.contains(userExisting!.id)) {
        if (mounted) {
          if (widget.id == response['channelId']) {
            setState(() {
              threadsChannel.add(Thread.fromMap(response['thread']));
            });
          } else {
            setState(() {
              threadsChat.add(Thread.fromMap(response['thread']));
            });
          }
        }
      }
      print(threadsChannel);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tin nhắn', style: TextStyle(color: Colors.white)),
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
      body: widget.type == 'channel'
          ? BlocBuilder<ChannelCubit, ChannelState>(
              builder: (context, state) {
                if (state is ChannelInitial) {
                  context.read<ChannelCubit>().getChannel(widget.id);
                  return const CircularProgressIndicator();
                } else if (state is GetChannelLoaded) {
                  Channel channel = state.channel;
                  threadsChannel = channel.threads!;
                  return common(viewInsets, threadsChannel);
                } else {
                  return const CircularProgressIndicator();
                }
              },
            )
          : BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                if (state is ChatInitial) {
                  context.read<ChatCubit>().getChat(widget.id);
                  return const CircularProgressIndicator();
                } else if (state is GetChatLoaded) {
                  context.read<ChatCubit>().getChat(widget.id);

                  Chat chat = state.chat;
                  threadsChat = chat.threads!;
                  return common(viewInsets, threadsChat);
                } else {
                  print('error');
                  return const CircularProgressIndicator();
                }
              },
            ),
    );
  }

  SafeArea common(EdgeInsets viewInsets, List<Thread> threads) {
    bool isTodayTextShown = false;
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
                  bool nameExisted = index > 0 &&
                      threads[index - 1].user!.name == thread.user!.name;

                  List<Widget> children = [];

                  if (thread.user!.id == userExisting!.id) {
                    children.add(
                      MessageBubble(
                        user: userExisting!,
                        content: thread.messages!.message,
                        timeSent: (thread.createdAt!),
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
                        sender: thread.user!,
                        content: thread.messages!.message,
                        type: MessageType.text,
                        timeSent: thread.createdAt!,
                        onFuctionReply: (sender, content) {
                          setState(() {
                            _reply = true;
                            _replyUser = sender;
                            _replyContent = content;
                          });
                        },
                        exist: !nameExisted,
                      ),
                    );
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
                onPressed: () {
                  // TODO: Send an image
                },
                icon: const Icon(Icons.more_vert),
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
                              onPressed: () {
                                // Xử lý sự kiện cho icon 1
                              },
                              icon: const Icon(Icons.attach_file),
                            ),
                            IconButton(
                              onPressed: () {
                                // Xử lý sự kiện cho icon 2
                              },
                              icon: const Icon(Icons.mic),
                            ),
                            IconButton(
                              onPressed: () {
                                // Xử lý sự kiện cho icon 2
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
    //     "messages":{
    //   "message":"test mention 2"
    // },
    // "channelId":"65e480261644570261cadca4"
    // xử lý tin nhắn
    // if (messageController.text.isNotEmpty) {
    //   SocketConfig.emit(SocketMessage.sendThread, {
    //     "messages": {
    //       "message": messageController.text,
    //     },
    //     "channelId": widget.id,
    //   });
    //   messageController.clear();
    // }
  }
}
