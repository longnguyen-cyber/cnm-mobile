import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zalo_app/blocs/bloc_channel/channel_cubit.dart';
import 'package:zalo_app/blocs/bloc_chat/chat_cubit.dart';
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
                  List<Thread> threads = channel.threads!;
                  return common(viewInsets, threads);
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
                  List<Thread> threads = chat.threads!;
                  return common(viewInsets, threads);
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
                itemCount: threads.length,
                itemBuilder: (BuildContext context, int index) {
                  Thread thread = threads[index];
                  bool nameExisted = index > 0 &&
                      threads[index - 1].user!.name == thread.user!.name;

                  if (thread.user!.id == userExisting!.id) {
                    return MessageBubble(
                      user: userExisting!,
                      content: thread.messages!.message,
                      timeSent: (thread.updatedAt!),
                      onFuctionReply: (sender, content) {
                        setState(() {
                          _reply = true;
                          _replyUser = sender;
                          _replyContent = content;
                        });
                      },
                    );
                  }
                  if (checkTimeSentWithCurrentTime(thread.updatedAt!)) {
                    List<Widget> children = [
                      Message(
                        sender: thread.user!,
                        content: thread.messages!.message,
                        type: MessageType.text,
                        timeSent: thread.updatedAt!,
                        onFuctionReply: (sender, content) {
                          setState(() {
                            _reply = true;
                            _replyUser = sender;
                            _replyContent = content;
                          });
                        },
                        exist: !nameExisted,
                      ),
                    ];

                    if (!isTodayTextShown) {
                      children.insert(
                          0,
                          const Column(
                            children: [
                              Divider(
                                color: Colors.grey,
                              ),
                              Center(
                                child: Text(
                                  "Hôm nay",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ));
                      isTodayTextShown = true;
                    }

                    return Column(children: children);
                  }

                  return Message(
                    sender: thread.user!,
                    content: thread.messages!.message,
                    type: MessageType.text,
                    timeSent: thread.updatedAt!,
                    onFuctionReply: (sender, content) {
                      setState(() {
                        _reply = true;
                        _replyUser = sender;
                        _replyContent = content;
                      });
                    },
                    exist: !nameExisted,
                  );
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

  //parse time to HH:ss with input Datetime
  bool checkTimeSentWithCurrentTime(DateTime timeSent) {
    var currentTime = DateTime.now();
    var timeSentString = timeSent.toString();
    var currentTimeString = currentTime.toString();
    if (timeSentString.substring(0, 10) == currentTimeString.substring(0, 10)) {
      return true;
    }
    return false;
  }

  void _sendMessage() {
    // xử lý tin nhắn
  }
}
