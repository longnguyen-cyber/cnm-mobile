import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:zalo_app/config/routes/app_route_constants.dart';
import 'package:zalo_app/utils/constants.dart';

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
        GoRouter.of(context).pushNamed(MyAppRouteConstants.detailChatRouteName,
            extra: {"id": map["id"], "type": map["type"]})
      },
      onLongPress: () => {
        GoRouter.of(context).pushNamed(MyAppRouteConstants.detailChatRouteName,
            extra: {"id": map["id"], "type": map["type"]})
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
        child: Row(
          children: <Widget>[
            const SizedBox(
              width: 10,
            ),
            map["user"] != null && map["user"]["avatar"] != null
                ? SizedBox(
                    height: 80,
                    width: 80,
                    child: Center(
                      child: CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(map["user"]["avatar"]),
                      ),
                    ),
                  )
                : Row(children: [
                    map["users"] != null
                        ? SizedBox(
                            height: 70,
                            width: 80,
                            child: GridView.count(
                              primary: false,
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.all(10),
                              crossAxisSpacing: 2,
                              mainAxisSpacing: 2,
                              crossAxisCount: 2,
                              children: [
                                for (var user in map["users"].take(4))
                                  user["avatar"] != null
                                      ? CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              user["avatar"] ?? ""))
                                      : Center(
                                          child: CircleAvatar(
                                            child: Text(
                                              user["name"][0],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 25,
                                              ),
                                            ),
                                          ),
                                        ),
                              ],
                            ),
                          )
                        : Container(),
                  ]),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    map["user"] != null ? map["user"]["name"] : map["name"],
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
            Container(
              width: size.width * 0.27,
              margin: const EdgeInsets.only(right: 0, top: 20),
              alignment: Alignment.topCenter,
              child: Text(
                caculateTime(
                  DateTime.parse(
                    map["timeThread"],
                  ),
                ),
                style: map["lastedThread"] != null
                    ? unReadMessageStyle.merge(const TextStyle(fontSize: 12))
                    : readMessageStyle.merge(const TextStyle(fontSize: 12)),
              ),
            )
          ],
        ),
      ),
    );
  }

  //caculate time with now
  String caculateTime(DateTime time) {
    var vietnameseTime = time.add(const Duration(hours: 7));
    var now = DateTime.now();
    var duration = now.difference(vietnameseTime);
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
