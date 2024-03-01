import 'package:flutter/material.dart';
import 'package:zalo_app/screens/chat/components/message_bubble.dart';
import 'package:zalo_app/screens/chat/constants.dart';
import 'package:zalo_app/screens/chat/enums/messenger_type.dart';

import 'components/index.dart';

class DetailChatScreen extends StatefulWidget {
  const DetailChatScreen({
    super.key,
    // required this.chatRoom
  });

  // final ChatRoom chatRoom;

  @override
  State<DetailChatScreen> createState() => _DetailChatScreenState();
}

class _DetailChatScreenState extends State<DetailChatScreen> {
  final messageController = TextEditingController();
  bool isTextNotEmpty = false;
  final List<dynamic> messages = [];

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
        body: SafeArea(
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
                    child: ListView(children: const <Widget>[
                  Message(
                    avatar: 'https://i.pravatar.cc/300',
                    content: 'Hello',
                    sender: 'user',
                    timeSent: '10:29',
                    type: MessageType.text,
                  ),
                  MessageBubble(
                    user: sender,
                    content: 'Hello, I am Here',
                    type: MessageType.text,
                    timeSent: '10:29',
                  )
                ])),
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
        )));
  }

  void _sendMessage() {
    // xử lý tin nhắn
  }
}
