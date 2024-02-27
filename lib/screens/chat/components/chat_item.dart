import 'package:flutter/material.dart';
import 'package:zalo_app/screens/chat/detail_chat_screen.dart';

import '../constants.dart';

class ChatItem extends StatelessWidget {
  const ChatItem(
      {super.key,
      required this.displayName,
      required this.avatarUrl,
      required this.read,
      required this.lastMessage,
      required this.timeSent,
      this.prepareMessage});
  final String displayName;
  final String avatarUrl;
  final bool read;
  final String lastMessage;
  final String timeSent;
  final String? prepareMessage;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const DetailChatScreen()))
      },
      onLongPress: () => {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const DetailChatScreen()))
      },
      child: Container(
        width: size.width,
        height: size.height * 0.1,
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
          color: Colors.grey.shade300,
          width: 1,
        ))),
        child: Row(children: <Widget>[
          const Spacer(),
          CircleAvatar(
            radius: 35,
            backgroundImage: NetworkImage(avatarUrl),
          ),
          const Spacer(
            flex: 2,
          ),
          SizedBox(
            width: size.width * 0.65,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    displayName,
                    style: !read
                        ? unReadMessageStyle
                        : readMessageStyle.copyWith(color: Colors.black),
                  ),
                  SizedBox(
                    height: size.height * 0.01,
                  ),
                  Text(
                    lastMessage,
                    style: !read ? unReadMessageStyle : readMessageStyle,
                  )
                ]),
          ),
          SizedBox(
            width: size.width * 0.15,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              prepareMessage != null
                  ? Text(
                      'Đang gửi',
                      style: TextStyle(color: Colors.yellow.shade700),
                    )
                  : Text(
                      timeSent,
                      style: !read ? unReadMessageStyle : readMessageStyle,
                    ),
              if (!read)
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'N',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              else
                Container(),
            ]),
          )
        ]),
      ),
    );
  }
}
