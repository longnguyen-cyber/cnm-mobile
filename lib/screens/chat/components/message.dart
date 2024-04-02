import 'package:flutter/material.dart';
import 'package:zalo_app/model/user.model.dart';
import 'package:zalo_app/screens/chat/components/avatar.dart';
import 'package:zalo_app/screens/chat/components/message_bubble.dart';
import 'package:zalo_app/screens/chat/enums/messenger_type.dart';

class Message extends StatefulWidget {
  const Message({
    super.key,
    required this.threadId,
    required this.sender,
    required this.type,
    required this.content,
    required this.messageType,
    required this.timeSent,
    required this.onFuctionReply,
    required this.exist,
    required this.isRecall,
  });
  final bool exist;
  final bool isRecall;
  final User sender;
  final String type;
  final String threadId;
  final String content;
  final MessageType messageType;
  final DateTime timeSent;
  final Function(String, String) onFuctionReply;

  @override
  State<Message> createState() => _MessageState();
}

class _MessageState extends State<Message> {
  Map<String, bool> nameExit = {};

  @override
  void initState() {
    super.initState();
    nameExit[widget.sender.name!] = false;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        widget.exist == true
            ? Avatar(imageUrl: widget.sender.avatar!, radius: 12)
            : const SizedBox(width: 30),
        Column(
          children: <Widget>[
            MessageBubble(
              threadId: widget.threadId,
              user: widget.sender,
              type: widget.type,
              content: widget.content,
              timeSent: widget.timeSent,
              onFuctionReply: widget.onFuctionReply,
              isRecall: widget.isRecall,
              receiveId: '',
            ),
          ],
        ),
      ],
    );
  }
}
