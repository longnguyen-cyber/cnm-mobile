import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zalo_app/model/channel.model.dart';
import 'package:zalo_app/model/chat.model.dart';
import 'package:zalo_app/model/file.model.dart';

class MoreInfo extends StatefulWidget {
  const MoreInfo({
    super.key,
    this.data,
  });
  final dynamic data;

  @override
  State<MoreInfo> createState() => _MoreInfoState();
}

class _MoreInfoState extends State<MoreInfo> {
  late Channel? channel = null;
  final Dio _dio = Dio();
  List<FileModel> files = [];
  var baseUrl = dotenv.env['API_URL'];
  Future<void> getChannel() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var token = prefs.getString("token") ?? "";

    String url = "$baseUrl/channels/65e480261644570261cadca4";
    final response = await _dio.get(
      url,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    setState(() {
      channel = Channel.fromMap(response.data["data"]);
      for (var thread in channel!.threads!) {
        for (var file in thread.files!) {
          files.add(file);
        }
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getChannel();
    files = List.generate(
      5,
      (index) => FileModel(
        id: 'id_$index', // Generate unique IDs
        filename: 'file_${index + 1}.txt', // Generate filenames
        path: 'https://picsum.photos/200/300', // Generate random URLs
        size: Random().nextInt(1024 * 1024), // Random size between 0 and 1MB
      ),
    );
    print(files);
  }

  @override
  Widget build(BuildContext context) {
    // final String id = widget.data["id"];
    // final String name = widget.data["name"];
    // final String type = widget.data["type"];
    // late List<dynamic> members = [];
    // if (widget.data["type"] == "channel") {
    //   members = widget.data["users"];
    // }

    // ignore: avoid_init_to_null
    // late Channel? channel = null;
    // ignore: avoid_init_to_null
    late Chat? chat = null;
    if (widget.data["type"] == "channel") {
      channel = widget.data["data"];
    } else {
      chat = widget.data["data"];
    }
    // print("channel: $channel");
    channel!.threads!.map((e) => {print(e)});
    // print(channel!.threads);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tùy chọn"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        //style for appbar
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            chat != null
                ? SizedBox(
                    height: 80,
                    width: 80,
                    child: Center(
                      child: CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(chat.user!.avatar ?? ""),
                      ),
                    ),
                  )
                : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
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
                          for (var user in channel!.users!.take(4))
                            user.avatar != null
                                ? CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(user.avatar ?? ""))
                                : Center(
                                    child: CircleAvatar(
                                      child: Text(
                                        user.name.toString()[0],
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
                  ]),
            Center(
              child: Text(
                chat != null ? chat.user!.name.toString() : channel!.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            //create lagre divider
            const Divider(
              height: 20,
              thickness: 4,
            ),
            InkWell(
              child: Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  child: const Text("add new member")),
              //dont border rad
              onTap: () {
                print("add new member");
              },
            ),
            const Divider(
              height: 20,
              thickness: 4,
            ),
            const Row(
              children: [
                SizedBox(
                  width: 10,
                ),
                Icon(Icons.folder_open_sharp),
                SizedBox(
                  width: 10,
                ),
                Text("Ảnh, file, link đã gửi"),
              ],
            ),
            Row(
              children: [
                const SizedBox(
                  width: 35,
                ),
                for (int i = 0; i < files.length; i++)
                  //4 image and one more
                  if (i > 3)
                    Container(
                      width: 70,
                      height: 70,
                      color: Colors.blue,
                      child: Center(
                        child: Text(
                          "+${files.length - 4}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      width: 70,
                      height: 70,
                      child: Image.network(
                        files[i].path ?? "",
                        fit: BoxFit.cover,
                      ),
                    ),
              ],
            ),
            chat == null
                ? Column(
                    children: [
                      const Divider(
                        height: 20,
                        thickness: 4,
                      ),
                      const Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Icon(Icons.people_alt),
                          SizedBox(
                            width: 10,
                          ),
                          Text("Thành viên"),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Column(
                          children: [
                            for (var user in channel!.users!)
                              ListTile(
                                leading: user.avatar != null
                                    ? CircleAvatar(
                                        backgroundImage:
                                            NetworkImage(user.avatar ?? ""))
                                    : CircleAvatar(
                                        child: Text(
                                          user.name.toString()[0],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 25,
                                          ),
                                        ),
                                      ),
                                title: Text(user.name.toString()),
                              ),
                          ],
                        ),
                      )
                    ],
                  )
                : Container(),
            const Divider(
              height: 20,
              thickness: 2,
            ),
            GestureDetector(
              onTap: () {},
              child: const Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Icon(Icons.people_alt, color: Colors.red),
                  SizedBox(
                    width: 10,
                  ),
                  Text("Xóa lịch sử trò chuyện",
                      style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
            const Divider(
              height: 20,
              thickness: 2,
            ),
            GestureDetector(
              onTap: () {
                print("Rời nhóm");
              },
              child: const Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Icon(Icons.logout, color: Colors.red),
                  SizedBox(
                    width: 10,
                  ),
                  Text("Rời nhóm", style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}