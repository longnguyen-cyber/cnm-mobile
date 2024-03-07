import 'package:flutter/material.dart';
import 'package:zalo_app/screens/chat/components/avatar.dart';
import 'package:zalo_app/screens/chat/components/message_bubble.dart';


enum MessageType { sent, received }

class Message extends StatefulWidget {
  const Message({
    super.key,
    required this.sender,
    required this.avatar,
    required this.content,
    // required this.type,
    required this.timeSent,
  });

  final String sender;
  final String avatar;
  final String content;
  // final MessageType type;
  final String timeSent;

  @override
  _MessageState createState() => _MessageState();
}

class _MessageState extends State<Message> {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Avatar(imageUrl: widget.avatar, radius: 12),
        Column(
          children: <Widget>[
            MessageBubble(
              user: widget.sender,
              content: widget.content,
              // type: MessageType.text,
              timeSent: widget.timeSent,
            ),
          ],
        ),
      ],
    );
  }
}
