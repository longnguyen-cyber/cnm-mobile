import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zalo_app/config/routes/app_route_constants.dart';
import 'package:zalo_app/model/channel.model.dart';

class ChannelItem extends StatefulWidget {
  const ChannelItem({
    super.key,
    required this.obj,
  });

  final Channel obj;

  @override
  State<ChannelItem> createState() => ChannelItemState();
}

class ChannelItemState extends State<ChannelItem> {
  @override
  Widget build(BuildContext context) {
    var channel = widget.obj;

    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => {
        GoRouter.of(context).pushNamed(MyAppRouteConstants.detailChatRouteName,
            extra: {"id": channel.id, "type": "channel"})
      },
      onLongPress: () => {
        GoRouter.of(context).pushNamed(MyAppRouteConstants.detailChatRouteName,
            extra: {"id": channel.id, "type": "channel"})
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
            Row(children: [
              SizedBox(
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
                    for (var user in channel.users!.take(4))
                      CircleAvatar(
                        backgroundImage: NetworkImage(user.avatar!),
                      ),
                  ],
                ),
              )
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
                    channel.name,
                  ),
                  SizedBox(
                    height: size.height * 0.01,
                  ),
                  Text(
                    (channel.lastedThread != null
                        ? (channel.lastedThread!.messages!.message
                                    .toString()
                                    .length >
                                30
                            ? "${channel.lastedThread!.messages!.message.toString().substring(0, 30)}..."
                            : channel.lastedThread!.messages!.message
                                .toString())
                        : "New message"),
                  )
                ],
              ),
            ),
            Container(
              width: size.width * 0.27,
              margin: const EdgeInsets.only(right: 0, top: 20),
              alignment: Alignment.topCenter,
              child: Text(
                caculateTime(channel.timeThread!),
              ),
            )
          ],
        ),
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
