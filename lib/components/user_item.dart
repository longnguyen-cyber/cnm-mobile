import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:zalo_app/config/routes/app_route_constants.dart';
import 'package:zalo_app/model/user.model.dart';

class UserItem extends StatefulWidget {
  const UserItem({
    super.key,
    required this.obj,
  });

  final User obj;

  @override
  State<UserItem> createState() => UserItemState();
}

class UserItemState extends State<UserItem> {
  @override
  Widget build(BuildContext context) {
    var user = widget.obj;

    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => {
        GoRouter.of(context)
            .pushNamed(MyAppRouteConstants.profileRouteName, extra: user)
      },
      onLongPress: () => {
        GoRouter.of(context)
            .pushNamed(MyAppRouteConstants.profileRouteName, extra: user)
      },
      child: Container(
        width: size.width,
        height: 80,
        margin: const EdgeInsets.only(left: 10),
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
            Center(
              child: user.avatar != null
                  ? CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(user.avatar!),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(1000),
                      ),
                      height: 50,
                      width: 50,
                      child: Center(
                        child: Text(
                          user.name![0],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                          ),
                        ),
                      ),
                    ),
            ),
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
                    user.name!,
                  ),
                  SizedBox(
                    height: size.height * 0.01,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
