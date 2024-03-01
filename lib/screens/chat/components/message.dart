import 'package:flutter/material.dart';
import 'package:zalo_app/screens/chat/components/avatar.dart';
import 'package:zalo_app/screens/chat/components/message_bubble.dart';
import 'package:zalo_app/screens/chat/enums/messenger_type.dart';

class Message extends StatelessWidget {
  const Message({
    super.key,
    required this.sender,
    required this.avatar,
    required this.content,
    required this.type,
    required this.timeSent,
  });
  final String sender;
  final String avatar;
  final String content;
  final MessageType type;
  final String timeSent;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Avatar(imageUrl: avatar, radius: 12),
        Column(
          children: <Widget>[
            MessageBubble(
              user: sender,
              content: content,
              type: type,
              timeSent: timeSent,
            ),
          ],
        ),
      ],
    );
  }
}
