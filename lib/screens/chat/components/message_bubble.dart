import 'package:flutter/material.dart';
import 'package:zalo_app/screens/chat/constants.dart';
import 'package:zalo_app/screens/chat/enums/messenger_type.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble(
      {super.key,
      required this.user,
      required this.content,
      required this.type,
      required this.timeSent});

  final String user;
  final String content;
  final MessageType type;
  final String timeSent;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    final alignment =
        (user == sender) ? Alignment.centerRight : Alignment.centerLeft;

    final color = (user == sender)
        ? Colors.white
        : const Color.fromARGB(255, 126, 218, 241);

    return Align(
      alignment: alignment,
      child: Container(
        constraints: BoxConstraints(maxWidth: size.width * 0.66),
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(
              8.0,
            ),
            border: Border.all(
              color: Colors.grey,
              width: 1.0,
            )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              content ?? '',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Colors.black,
                  ),
            ),
            Text(timeSent,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                )),
          ],
        ),
      ),
    );
  }
}
