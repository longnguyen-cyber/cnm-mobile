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
  });
  final User sender;
  final String content;
  final MessageType type;
  final String timeSent;

  @override
  State<Message> createState() => _MessageState();
}

class _MessageState extends State<Message> {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Avatar(imageUrl: widget.sender.avatar!, radius: 12),
        Column(
          children: <Widget>[
            MessageBubble(
              user: widget.sender,
              content: widget.content,
              type: widget.type,
              timeSent: widget.timeSent,
            ),
          ],
        ),
      ],
    );
  }
}
