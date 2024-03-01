import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zalo_app/config/routes/app_route_constants.dart';
import 'package:zalo_app/model/channel.model.dart';
import 'package:zalo_app/model/chat.model.dart';
import 'package:zalo_app/screens/chat/detail_chat_screen.dart';

import '../constants.dart';

class ChatItem extends StatefulWidget {
  const ChatItem({
    super.key,
    required this.obj,
  });

  final dynamic obj;

  @override
  State<ChatItem> createState() => _ChatItemState();
}

class _ChatItemState extends State<ChatItem> {
  @override
  Widget build(BuildContext context) {
    var map = widget.obj as Map<String, dynamic>;

    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => {
        GoRouter.of(context).pushNamed(MyAppRouteConstants.detailChatRouteName)
      },
      onLongPress: () => {
        GoRouter.of(context).pushNamed(MyAppRouteConstants.detailChatRouteName)
      },
      child: Container(
        width: size.width,
        height: 80,
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
          color: Colors.grey.shade300,
          width: 1,
        ))),
        child: Row(children: <Widget>[
          const SizedBox(
            width: 10,
          ),

          map["userReceive"] != null && map["userReceive"]["avatar"] != null
              ? SizedBox(
                  height: 80,
                  width: 80,
                  child: Center(
                    child: CircleAvatar(
                      radius: 25,
                      backgroundImage:
                          NetworkImage(map["userReceive"]["avatar"]),
                    ),
                  ),
                )
              : Row(children: [
                  //list image avatar from map["users"]
                  map["users"] != null
                      ? SizedBox(
                          height: 80,
                          width: 80,
                          child: GridView.count(
                            primary: false,
                            padding: const EdgeInsets.all(10),
                            crossAxisSpacing: 2,
                            mainAxisSpacing: 2,
                            crossAxisCount: 2,
                            children: [
                              for (var user in map["users"].take(4))
                                CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(user["avatar"] ?? ""),
                                ),
                            ],
                          ),
                        )
                      : Container(),
                ]),
          const SizedBox(
            width: 10,
          ),

          Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: size.width * 0.55,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      map["userReceive"] != null
                          ? map["userReceive"]["name"]
                          : map["name"],
                    ),
                    SizedBox(
                      height: size.height * 0.01,
                    ),
                    Text(
                      (map["lastedThread"] != null
                          ? (map["lastedThread"]["messages"]["message"]
                                      .toString()
                                      .length >
                                  30
                              ? "${map["lastedThread"]["messages"]["message"].toString().substring(0, 30)}..."
                              : map["lastedThread"]["messages"]["message"]
                                  .toString())
                          : "New message"),
                      style: map["lastedThread"] != null
                          ? unReadMessageStyle
                          : readMessageStyle,
                    )
                  ],
                ),
              ),
              SizedBox(
                width: size.width * 0.27,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        caculateTime(DateTime.parse(map["timeThread"])),
                        style: map["lastedThread"] != null
                            ? unReadMessageStyle
                                .merge(const TextStyle(fontSize: 12))
                            : readMessageStyle
                                .merge(const TextStyle(fontSize: 12)),
                      ),
                      // if (!widget.obj.read!)
                      //   Container(
                      //     padding: const EdgeInsets.all(3),
                      //     decoration: BoxDecoration(
                      //       color: Colors.red,
                      //       borderRadius: BorderRadius.circular(10),
                      //     ),
                      //     child: const Text(
                      //       'N',
                      //       style: TextStyle(color: Colors.white),
                      //     ),
                      //   )
                      // else
                      //   Container(),
                    ]),
              )
            ],
          ),
          // SizedBox(
          //   width: size.width * 0.5,
          //   child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       mainAxisAlignment: MainAxisAlignment.start,
          //       children: [
          //         const SizedBox(
          //           height: 10,
          //         ),
          //         Text(
          //           map["userReceive"] != null
          //               ? map["userReceive"]["name"]
          //               : map["name"],
          //         ),
          //         SizedBox(
          //           height: size.height * 0.01,
          //         ),
          //         Text(
          //           map["lastedThread"] != null
          //               ? map["lastedThread"]["messages"]["message"]
          //               : "New message",
          //           style: map["lastedThread"] != null
          //               ? unReadMessageStyle
          //               : readMessageStyle,
          //         )
          //       ]),
          // ),
        ]),
      ),
    );
  }

  //caculate time with now
  String caculateTime(DateTime time) {
    var now = DateTime.now();
    var duration = now.difference(time);
    if (duration.inDays > 0) {
      return "${duration.inDays} ngày trước";
    } else if (duration.inHours > 0) {
      return "${duration.inHours} giờ trước";
    } else if (duration.inMinutes > 0) {
      return "${duration.inMinutes} phút trước";
    } else {
      return "Vừa xong";
    }
  }
}
