import 'package:flutter/material.dart';
import 'package:zalo_app/model/user.model.dart';
import 'package:zalo_app/screens/chat/components/avatar.dart';
import 'package:zalo_app/screens/chat/components/message_bubble.dart';
import 'package:zalo_app/screens/chat/enums/messenger_type.dart';

class Message extends StatefulWidget {
  const Message({
    super.key,
    required this.sender,
    required this.content,
    required this.type,
    required this.timeSent,
    required this.onFuctionReply,
    required this.exist,
  });
  final bool exist;
  final User sender;
  final String content;
  final MessageType type;
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
              user: widget.sender,
              content: widget.content,
              timeSent: widget.timeSent,
              onFuctionReply: widget.onFuctionReply,
              isReverse: true,
            ),
          ],
        ),
      ],
    );
  }
}
