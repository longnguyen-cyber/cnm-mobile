import 'package:flutter/material.dart';
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
    print(widget.id);
    print(widget.type);
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
          child: Column(children: [
            Expanded(
              child: ListView(
                children: threads.map((thread) {
                  if (thread.user!.id == userExisting!.id) {
                    return MessageBubble(
                      user: userExisting!,
                      content: thread.messages!.message,
                      type: MessageType.text,
                      timeSent: parseTime(thread.updatedAt!),
                    );
                  }
                  return Message(
                    sender: thread.user!,
                    content: thread.messages!.message,
                    type: MessageType.text,
                    timeSent: parseTime(thread.updatedAt!),
                  );
                }).toList(),
              ),
            ),
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
  String parseTime(DateTime time) {
    return '${time.hour}:${time.minute}';
  }

  void _sendMessage() {
    // xử lý tin nhắn
  }
}
