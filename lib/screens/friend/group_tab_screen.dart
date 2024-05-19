// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:zalo_app/components/channel_item.dart';
import 'package:zalo_app/config/routes/app_route_constants.dart';
import 'package:zalo_app/model/channel.model.dart';
import 'package:zalo_app/services/api_service.dart';

class GroupTabScreen extends StatefulWidget {
  const GroupTabScreen({super.key});

  @override
  State<GroupTabScreen> createState() => _GroupTabScreenState();
}

class _GroupTabScreenState extends State<GroupTabScreen> {
  final api = API();
  List<Channel> channels = [];
  void getAll() async {
    String urlAll = "channels";

    final response = await api.get(urlAll, {});

    if (mounted) {
      setState(() {
        channels =
            (response["data"] as List).map((e) => Channel.fromMap(e)).toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getAll();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var topGroupItem = Row(
      children: <Widget>[
        Flexible(
          flex: 2,
          child: Container(
            padding: EdgeInsets.all(size.width * 0.01),
            decoration: BoxDecoration(
                color: Colors.blue.shade400,
                borderRadius: BorderRadius.circular(20)),
            child: SvgPicture.asset(
              'assets/icons/group-106.svg',
              width: size.width * 0.1,
              color: Colors.white,
            ),
          ),
        ),
        const Spacer(),
        Expanded(
          flex: 8,
          child: Container(
            padding: EdgeInsets.all(size.width * 0.01),
            child: TextButton(
              style: TextButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.transparent,
                  alignment: Alignment.centerLeft),
              onPressed: () {
                GoRouter.of(context)
                    .pushNamed(MyAppRouteConstants.createChannelRouteName);
              },
              child: const Text(
                'Tạo nhóm mới',
                style: TextStyle(fontSize: 16, color: Colors.blue),
              ),
            ),
          ),
        ),
      ],
    );
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(size.width * 0.02),
        width: size.width,
        child: SingleChildScrollView(
          child: Column(
            children: [
              topGroupItem,
              SizedBox(
                height: size.height * 0.01,
              ),
              const Divider(
                color: Colors.grey,
              ),
              SizedBox(
                height: size.height * 0.01,
              ),
              const Row(
                children: <Widget>[
                  SizedBox(
                    width: 10,
                  ),
                  Text('Danh sách nhóm', style: TextStyle(fontSize: 16)),
                  Spacer(),
                  // Text('Xem tất cả',
                  //     style: TextStyle(fontSize: 16, color: Colors.blue)),
                ],
              ),
              for (int i = 0; i < channels.length; i++)
                ChannelItem(obj: channels[i]),
            ],
          ),
        ),
      ),
    );
  }
}
