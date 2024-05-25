// ignore_for_file: use_build_context_synchronously, deprecated_member_use, unused_local_variable, avoid_init_to_null

import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:zalo_app/config/routes/app_route_constants.dart';
import 'package:zalo_app/config/socket/socket.dart';
import 'package:zalo_app/config/socket/socket_event.dart';
import 'package:zalo_app/config/socket/socket_message.dart';
import 'package:zalo_app/model/channel.model.dart';
import 'package:zalo_app/model/chat.model.dart';
import 'package:zalo_app/model/file.model.dart';
import 'package:zalo_app/model/thread.model.dart';
import 'package:zalo_app/model/user.model.dart';
import 'package:zalo_app/screens/chat/components/message_bubble.dart';
import 'package:zalo_app/screens/chat/components/record_widget_start.dart';
import 'package:zalo_app/screens/chat/enums/messenger_type.dart';
import 'package:zalo_app/services/api_service.dart';

import 'components/index.dart';

class DetailChatScreen extends StatefulWidget {
  const DetailChatScreen({super.key, required this.data});
  final dynamic data;

  // final ChatRoom chatRoom;

  @override
  State<DetailChatScreen> createState() => _DetailChatScreenState();
}

class _DetailChatScreenState extends State<DetailChatScreen> {
  User? userExisting = User();
  User? userTyping = User();
  FocusNode myFocusNode = FocusNode();
  final messageController = TextEditingController();
  bool isTextNotEmpty = false;
  final List<dynamic> messages = [];
  String _replyUser = "";
  String _replyContent = "";
  String _replyStoneId = "";
  late Thread replyThread;
  late bool blockChat = false;
  late bool isAdmin = false;

  bool _reply = false;
  List<Thread> threadsChannel = [];
  List<Thread> threadsChat = [];
  List<Thread> threadsCloud = [];
  List<Thread> threadsPosition = [];
  late dynamic data = null;
  late dynamic fileData = [];
  late AudioRecorder audioRecord;
  late AudioPlayer audioPlayer;
  bool isRecording = false;
  late bool showAllPin = false;

  String path = "";
  late String name;
  late dynamic members = [];
  List<Thread> pinThreads = [];
  List<User> mentionsDefault = [];
  List<User> mentionsShow = [];
  List<User> mentionsSelected = [];
  List<Map<String, String>> mentionsMap = [];
  late bool isMention = false;
  late bool notiAll = false;
  late bool hasAutoScrolled = false;
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  final scrollDuration = const Duration(seconds: 1);

  late bool typing = false;

  final api = API();
  void setPath() async {
    final dir = await getApplicationDocumentsDirectory();
    path = '${dir.path}/my_audio_file.wav';
  }

  void getData() async {
    String type = widget.data["type"];
    String id = widget.data["id"];
    if (mounted) {
      if (type == "chat") {
        final response = await api.get("chats/$id", {});
        if (response != null) {
          Chat chat = Chat.fromMap(response["data"]);
          setState(() {
            threadsChat = chat.threads!;
            data = chat;
          });

          for (var i = 0; i < threadsChat.length; i++) {
            if (threadsChat[i].pin == true) {
              pinThreads.insert(0, threadsChat[i]);
            }
          }

          setState(() {
            pinThreads = pinThreads;
          });
        }
      } else if (type == "cloud") {
        final response = await api.get("users/my-cloud", {});
        if (response != null) {
          setState(() {
            threadsCloud = (response["data"]["threads"] as List)
                .map((e) => Thread.fromMap(e))
                .toList();
          });
        }
      } else {
        final response = await api.get("channels/$id", {});
        if (response != null) {
          Channel channel = Channel.fromMap(response["data"]);
          User user = channel.users!
              .firstWhere((element) => element.id == userExisting!.id);
          setState(() {
            threadsChannel = channel.threads!;
            data = channel;
            if (channel.disableThread == true) {
              blockChat = true;
            } else {
              blockChat = false;
            }

            mentionsShow = channel.users!;
            mentionsDefault = channel.users!;

            if (user.role == "AMDIN" || user.role == "CO-ADMIN") {
              isAdmin = true;
            } else {
              isAdmin = false;
            }
          });

          for (var i = 0; i < threadsChannel.length; i++) {
            if (threadsChannel[i].pin == true) {
              pinThreads.insert(0, threadsChannel[i]);
            }
          }

          setState(() {
            pinThreads = pinThreads;
          });
        }
      }
    }
  }

  void getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token") ?? "";
    var userOfToken = prefs.getString(token) ?? "";
    // SocketConfig.connect(token);
    if (userOfToken != "") {
      userExisting = User.fromJson(userOfToken);
    } else {
      userExisting = null;
    }
    setState(() {
      userExisting = userExisting;
    });
  }

  @override
  void dispose() {
    super.dispose();
    audioPlayer.dispose();
    audioRecord.dispose();
  }

  @override
  void initState() {
    super.initState();
    audioRecord = AudioRecorder();
    audioPlayer = AudioPlayer();
    getUser();
    getData();
    setPath();
    name = widget.data["name"];

    SocketConfig.listen(SocketEvent.typing, (response) {
      if (mounted) {
        userTyping = User.fromMap(response["user"]);
        if (userTyping!.id != userExisting!.id) {
          if (response["receiveId"] != null) {
            if (response["receiveId"] == userExisting!.id &&
                response["chatId"] == widget.data["id"]) {
              setState(() {
                typing = true;
                userTyping = User.fromMap(response["user"]);
              });
            }
          } else if (response["members"] != null) {
            var members = (response["members"] as List).map((e) => e).toList();
            if (response["channelId"] == widget.data["id"] &&
                members.contains(userExisting!.id)) {
              setState(() {
                typing = true;
                userTyping = User.fromMap(response["user"]);
              });
            }
          }
        }
      }
    });
    SocketConfig.listen(SocketEvent.channelWS, (response) {
      String? userId = userExisting!.id;
      var status = response['status'];
      var data = response['data'];
      if (status == 200) {
        if (mounted) {
          var type = data["type"];
          var channel = data["channel"];
          var userIds = (channel["users"] as List)
              .map((e) => User.fromMap(e))
              .toList()
              .map((e) => e.id)
              .toList();
          if (type != "deleteChannel") {
            Thread thread = Thread.fromMap(channel["lastedThread"]);
            setState(() {
              if (userIds.contains(userId)) {
                if (type == "updateChannel") {
                  name = channel["name"];
                  setState(() {
                    blockChat = channel["disableThread"];
                  });
                  threadsChannel.add(thread);
                } else if (type == "addUserToChannel") {
                  members =
                      (channel["users"] as List).map((e) => e["id "]).toList();
                  threadsChannel.add(thread);
                } else if (type == "deleteChannel") {
                  GoRouter.of(context)
                      .pushNamed(MyAppRouteConstants.mainRouteName);
                } else if (type == "removeUserFromChannel") {
                  // all[index] = channel;
                  members =
                      (channel["users"] as List).map((e) => e["id "]).toList();
                  var removeMember = data["removeMember"];
                  if (removeMember == (userId)) {
                    GoRouter.of(context)
                        .pushNamed(MyAppRouteConstants.mainRouteName);
                  } else {
                    threadsChannel.add(thread);
                  }
                } else if (type == "leaveChannel") {
                  // all[index] = channel;
                  String userLeave = data["userLeave"];
                  members =
                      (channel["users"] as List).map((e) => e["id "]).toList();

                  if (userLeave == userId) {
                    GoRouter.of(context)
                        .pushNamed(MyAppRouteConstants.mainRouteName);
                  } else {
                    threadsChannel.add(thread);
                  }
                } else if (type == "updateRoleUserInChannel") {
                  threadsChannel.add(thread);
                }
              }
            });
          }
        }
      }
    });
    SocketConfig.listen(SocketEvent.updatedSendThread, (response) {
      if (mounted) {
        if (response["typeMsg"] == "recall" ||
            response["typeMsg"] == "delete") {
          setState(() {
            if (response["type"] == "chat") {
              var indexOfThread = threadsChat.indexWhere(
                  (element) => element.stoneId == response['stoneId']);
              if (indexOfThread != -1) {
                if (response["typeMsg"] == "delete") {
                  threadsChat.removeAt(indexOfThread);
                } else {
                  threadsChat[indexOfThread].isRecall = true;
                  if (response["typeRecall"] == "image") {
                    threadsChat[indexOfThread].messages = response["messages"];
                    threadsChat[indexOfThread].files = [];
                  } else {
                    threadsChat[indexOfThread].messages!.message =
                        response["messages"]["message"];
                  }
                }
              }
            } else {
              var indexOfThread = threadsChannel.indexWhere(
                  (element) => element.stoneId == response['stoneId']);
              if (indexOfThread != -1) {
                if (response["typeMsg"] == "delete") {
                  threadsChannel.removeAt(indexOfThread);
                } else {
                  threadsChannel[indexOfThread].isRecall = true;

                  threadsChannel[indexOfThread].messages!.message =
                      "Tin nhắn đã bị thu hồi";
                }
              }
            }
          });
        } else if (response["typeMsg"] == "update") {
          List<Thread> snapThreads = [];
          if (response["type"] == "chat") {
            snapThreads = threadsChat;
          } else {
            snapThreads = threadsChannel;
          }
          if (snapThreads.isNotEmpty) {
            int indexOfThread = snapThreads.indexWhere(
                (element) => element.stoneId == response['stoneId']);
            if (indexOfThread != -1) {
              //add to pin thread
              setState(() {
                if (response["pin"] == true) {
                  pinThreads.insert(0, snapThreads[indexOfThread]);
                } else {
                  pinThreads.removeWhere(
                      (element) => element.stoneId == response['stoneId']);
                }
              });
              //update for threads of chat or channel
              setState(() {
                if (response["type"] == "chat") {
                  threadsChat[indexOfThread].pin = response["pin"];
                } else {
                  threadsChannel[indexOfThread].pin = response["pin"];
                }
              });
            }
          }
        } else {
          //send new message
          // ignore: prefer_typing_uninitialized_variables
          var data;
          var members = response['members'] != null
              ? (response['members'] as List<dynamic>).map((e) => e).toList()
              : [];
          if (response['messages'] != null &&
              response['messages']['message'] != null &&
              response['fileCreateDto'] == null) {
            data = {
              "stoneId": response['stoneId'],
              "messages": {"message": response['messages']['message']},
              "user": response['user'],
              "isReply": response['isReply'],
              "isRecall": response['isRecall'],
              "createdAt": response['timeThread'] as String,
              "receiveId": response['receiveId']
            };
          } else if (response['messages'] == null &&
              response['fileCreateDto'] != null) {
            data = {
              "stoneId": response['stoneId'],
              "user": response['user'],
              "isReply": response['isReply'],
              "isRecall": response['isRecall'],
              "createdAt": response['timeThread'] as String,
              "receiveId": response['receiveId'],
              "files": response['fileCreateDto']
            };
          } else {
            data = {
              "stoneId": response['stoneId'],
              "user": response['user'],
              "isReply": response['isReply'],
              "isRecall": response['isRecall'],
              "messages": {"message": response['messages']['message']},
              "createdAt": response['timeThread'] as String,
              "receiveId": response['receiveId'],
              "files": response['fileCreateDto']
            };
          }

          if (response["replysTo"] != null) {
            data["replysTo"] = response["replysTo"];
            data["isReply"] = true;
          }
          Thread thread = Thread.fromMap(data);
          if (members.contains(userExisting!.id)) {
            var index = threadsChannel.length - 1;

            setState(() {
              if (thread.files!.isNotEmpty &&
                  thread.messages == null &&
                  response["receiveId"] != userExisting!.id &&
                  threadsChannel[index].stoneId != thread.stoneId) {
                //get latest thread and update file path
                threadsChannel[index].stoneId = thread.stoneId;
                for (var i = 0; i < thread.files!.length; i++) {
                  var path = thread.files![i].path;
                  threadsChannel[index].files![i].path = path;
                }
              } else {
                threadsChannel.add(thread);
              }
            });
          } else if ((response["receiveId"] == userExisting!.id ||
                  response["user"]["id"] == userExisting!.id) &&
              response["type"] == "chat") {
            setState(() {
              if (thread.files!.isNotEmpty &&
                  thread.messages == null &&
                  response["receiveId"] != userExisting!.id) {
                //get latest thread and update file path
                var index = threadsChat.length - 1;
                for (var i = 0; i < thread.files!.length; i++) {
                  var path = thread.files![i].path;
                  threadsChat[index].files![i].path = path;
                }
              } else {
                threadsChat.add(thread);
              }
            });
          } else if (response["user"]["id"] == userExisting!.id &&
              response["type"] == "cloud") {
            //cloud
            setState(() {
              if (thread.files!.isNotEmpty && thread.messages == null) {
                //get latest thread and update file path
                var index = threadsCloud.length - 1;
                for (var i = 0; i < thread.files!.length; i++) {
                  var path = thread.files![i].path;
                  threadsCloud[index].files![i].path = path;
                }
              } else {
                threadsCloud.add(thread);
              }
            });
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final String type = widget.data["type"];
    if (widget.data["type"] == "channel" && data != null) {
      members = widget.data["members"];
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (type == "channel")
              Text(
                "${members.length} thành viên",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              GoRouter.of(context).pushNamed(MyAppRouteConstants.moreRouteName,
                  extra: {"data": data, "type": type});
            },
            icon: const Icon(Icons.format_list_bulleted),
          ),
        ],
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            GoRouter.of(context).pushNamed(MyAppRouteConstants.mainRouteName);
          },
        ),
      ),
      body: type == 'channel'
          ? common(viewInsets, threadsChannel, type)
          : type == 'cloud'
              ? common(viewInsets, threadsCloud, type)
              : common(viewInsets, threadsChat, type),
    );
  }

  String convertToSize(int bytes) {
    double kb = bytes / 1024;
    if (kb > 1024) {
      double mb = kb / 1024;
      if (mb > 1024) {
        double gb = mb / 1024;
        return '${gb.toStringAsFixed(2)} GB';
      }
      return '${mb.toStringAsFixed(2)} MB';
    } else {
      return '${kb.toStringAsFixed(2)} KB';
    }
  }

  SafeArea common(EdgeInsets viewInsets, List<Thread> threads, String type) {
    Size size = MediaQuery.of(context).size;
    // ScrollController controller = ScrollController();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (controller.hasClients) {
    //     controller.jumpTo(controller.position.maxScrollExtent);
    //   }
    // });
    if (threads.isNotEmpty && !hasAutoScrolled) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (itemScrollController.isAttached) {
          itemScrollController.jumpTo(index: threads.length - 1);
          setState(() {
            hasAutoScrolled = true;
          });
        }
      });
    }
    bool isDifferentDay(int index) {
      if (index == threads.length - 1) {
        return false; // Always false for the last message
      }

      DateTime currentMessageDate = (threads[index].createdAt!);
      DateTime nextMessageDate = (threads[index + 1].createdAt!);

      return currentMessageDate.day != nextMessageDate.day ||
          currentMessageDate.month != nextMessageDate.month ||
          currentMessageDate.year != nextMessageDate.year;
    }

    setState(() {
      if (threads.isNotEmpty) {
        threadsPosition = threads;
      }
    });
    return SafeArea(
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            color: Colors.blueGrey[50],
            child: Padding(
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 8.0,
                bottom: (viewInsets.bottom > 0) ? 8.0 : 0.0,
              ),
              child: OrientationBuilder(
                builder: (BuildContext context, Orientation orientation) =>
                    Column(
                  children: <Widget>[
                    Expanded(
                      child: ScrollablePositionedList.builder(
                        itemCount: threads.length,
                        itemScrollController: itemScrollController,
                        itemPositionsListener: itemPositionsListener,
                        itemBuilder: (BuildContext context, int index) {
                          Thread thread = threads[index];
                          List<Widget> children = [];
                          if (_replyStoneId.isNotEmpty) {
                            replyThread = threads.firstWhere(
                                (element) => element.stoneId == _replyStoneId);
                          }

                          if (thread.user == null) {
                            children.add(
                              Center(
                                child: Text(
                                  thread.messages!.message,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            );
                          } else {
                            bool nameExisted = index > 0 &&
                                threads[index - 1].user != null &&
                                threads[index - 1].user!.name ==
                                    thread.user!.name;
                            if (thread.user!.id == userExisting!.id) {
                              children.add(
                                MessageBubble(
                                  stoneId: thread.stoneId!,
                                  user: userExisting!,
                                  receiveId: thread.receiveId != null
                                      ? thread.receiveId!
                                      : "",
                                  type: type,
                                  typeRecall: thread.messages != null
                                      ? "text"
                                      : "image",
                                  content: thread.messages != null
                                      ? thread.messages!.message
                                      : "",
                                  timeSent: (thread.createdAt!),
                                  emojis: thread.emojis != null
                                      ? thread.emojis!
                                      : [],
                                  files: thread.files!,
                                  isRecall: thread.isRecall,
                                  isReply: thread.isReply,
                                  id: widget.data["id"],
                                  isPin: thread.pin ?? false,
                                  replyThread: thread.isReply == true
                                      ? thread.replysTo
                                      : null,
                                  onFuctionReply: (sender, content, stonedId) {
                                    setState(() {
                                      _reply = true;
                                      _replyUser = sender;
                                      _replyContent = content;
                                      _replyStoneId = stonedId;
                                    });
                                  },
                                ),
                              );
                            } else {
                              children.add(
                                Message(
                                  id: widget.data["id"],
                                  stoneId: thread.stoneId!,
                                  sender: thread.user!,
                                  type: type,
                                  receiveId: thread.senderId != null
                                      ? thread.senderId!
                                      : "",
                                  content: thread.messages != null
                                      ? thread.messages!.message
                                      : "",
                                  messageType: MessageType.text,
                                  timeSent: thread.createdAt!,
                                  isPin: thread.pin ?? false,
                                  onFuctionReply: (sender, content, stoneId) {
                                    setState(() {
                                      _reply = true;
                                      _replyUser = sender;
                                      _replyContent = content;
                                      _replyStoneId = stoneId;
                                    });
                                  },
                                  isReply: thread.isReply,
                                  replyThread: thread.isReply == true
                                      ? thread.replysTo
                                      : null,
                                  exist: !nameExisted,
                                  isRecall: thread.isRecall!,
                                  emojis: thread.emojis!,
                                  files: thread.files!,
                                ),
                              );
                            }
                          }

                          if (isDifferentDay(index)) {
                            DateTime currentMessageDate =
                                (threads[index].createdAt!);
                            DateTime now = DateTime.now();

                            String formattedDate;
                            if (currentMessageDate.year == now.year &&
                                currentMessageDate.month == now.month &&
                                currentMessageDate.day == now.day - 1) {
                              formattedDate = 'Hôm nay';
                            } else {
                              formattedDate = DateFormat('dd/MM/yyyy')
                                  .format(currentMessageDate);
                            }

                            children.add(
                              Column(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 0, horizontal: 60),
                                    child: const Divider(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    formattedDate,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          // Add a space above the first message if have pin thread
                          if (true) {
                            children.insert(0, const SizedBox(height: 40));
                          }

                          return Wrap(children: children);
                        },
                      ),
                    ),
                    _reply
                        ? Row(children: <Widget>[
                            Container(
                              width: size.width * 0.9,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white54,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                  ),
                                  Container(
                                    width: 3, // Độ rộng của đường kẻ thẳng đứng
                                    height:
                                        40, // Chiều cao tối thiểu để giữ khoảng cách giữa hai đoạn văn bản
                                    color: Colors
                                        .blue, // Màu sắc của đường kẻ thẳng
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: '  $_replyUser\n',
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 16),
                                        ),
                                        TextSpan(
                                          text: _replyContent,
                                          style: const TextStyle(
                                              color: Colors.grey, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    child: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _reply = false;
                                        });
                                      },
                                      icon: const Icon(Icons.close),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ])
                        : Container(),
                    const SizedBox(height: 10),
                    blockChat == true
                        ? isAdmin
                            ? sendThread(threads, size)
                            : SizedBox(
                                height: 50,
                                width: size.width,
                                child: const Center(
                                  child: Text(
                                    "Chỉ có quản trị viên mới có thể gửi tin nhắn",
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              )
                        : sendThread(threads, size),
                    const SizedBox(height: 8.0),
                  ],
                ),
              ),
            ),
          ),
          pinThreads.isNotEmpty
              ? Positioned(
                  child: SingleChildScrollView(
                    child: Container(
                      width: size.width,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      child: showAllPin
                          ? Column(
                              children: [
                                for (var i = 0; i < pinThreads.length; i++)
                                  pinThread(pinThreads[i]),
                                TextButton(
                                    onPressed: () {
                                      setState(() {
                                        showAllPin = false;
                                      });
                                    },
                                    child: const Text("Thu gọn"))
                              ],
                            )
                          : pinThread(pinThreads[0]),
                    ),
                  ),
                )
              : Container(),
          isMention
              ? Positioned(
                  bottom: 60,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 350,
                    ),
                    child: Container(
                      width: size.width,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Colors.grey,
                          ),
                        ),
                        color: Colors.white,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            mentionsSelected.isEmpty
                                ? InkWell(
                                    onTap: () {
                                      setState(() {
                                        mentionsSelected = mentionsShow;
                                        isMention = false;
                                        notiAll = true;
                                      });
                                      transferSelectedMentionsToText();
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.alternate_email_outlined,
                                            color: Colors.blueAccent,
                                          ),
                                          SizedBox(
                                            width: 8,
                                          ),
                                          Text("Báo cho cả nhóm"),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(),
                            for (var i = 0; i < mentionsShow.length; i++)
                              InkWell(
                                onTap: () {
                                  handleSelectUserMetion(mentionsShow[i]);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  child: Row(
                                    children: [
                                      mentionsShow[i].avatar != null
                                          ? CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  "${mentionsShow[i].avatar}"),
                                              radius: 15,
                                            )
                                          : CircleAvatar(
                                              radius: 15,
                                              child: Text(
                                                mentionsShow[i].name?[0] ?? '',
                                                style: const TextStyle(
                                                    fontSize: 40.0),
                                              ),
                                            ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(mentionsShow[i].name!),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : Container(),
          typing
              ? Positioned(
                  bottom: 56,
                  child: Container(
                    margin: const EdgeInsets.only(left: 50, right: 10),
                    width: size.width,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: Text(
                        "${userTyping!.name} đang nhập...",
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),
                )
              : Container(),
          Positioned(
            bottom: 60,
            right: 0,
            child: ValueListenableBuilder<Iterable<ItemPosition>>(
              valueListenable: itemPositionsListener.itemPositions,
              builder: (context, positions, child) {
                int maxIndex = 0;
                if (positions.isNotEmpty) {
                  maxIndex = positions
                      .where((ItemPosition position) =>
                          position.itemTrailingEdge > 0)
                      .reduce((ItemPosition max, ItemPosition position) =>
                          position.index > max.index ? position : max)
                      .index;
                }
                // Show the button only if the last item is not visible
                return maxIndex >= threads.length - 4
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 10),
                        child: Container(
                          width: 35.0,
                          height: 35.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            //shadow
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 1,
                                offset: const Offset(0, 1),
                              ),
                            ],
                            shape: BoxShape.circle,
                          ),
                          child: InkWell(
                            onTap: () {
                              scrollTo(threads.length - 1);
                            },
                            child: const Center(
                              child: Icon(Icons.keyboard_arrow_down_sharp,
                                  size: 35),
                            ),
                          ),
                        ),
                      );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> handleSelectUserMetion(User metionUser) async {
    User selectedMention = User(
      id: metionUser.id,
      name: metionUser.name,
      // Add other fields as necessary
    );
    await Future.delayed(Duration.zero);
    setState(() {
      mentionsSelected.add(selectedMention);
      notiAll = false;
      isMention = false;
    });
    transferSelectedMentionsToText();
    // Filter mentionsDefault and assign the result to mentionsShow
    List<User> mentionsChange = mentionsDefault
        .where((element) => element.id != selectedMention.id)
        .toList();
    setState(() {
      mentionsShow = mentionsChange;
    });
  }

  transferSelectedMentionsToText() {
    if (mentionsSelected.isNotEmpty && !notiAll) {
      User mention = mentionsSelected[mentionsSelected.length - 1];
      String mentionText = mention.name!;
      setState(() {
        List<String> targetMentions = messageController.text.split("@");

        String currentText = targetMentions[targetMentions.length - 1];
        if (mentionText.contains(currentText)) {
          messageController.text = messageController.text.replaceRange(
              messageController.text.length - currentText.length,
              messageController.text.length,
              "$mentionText ");
        } else {
          messageController.text += "$mentionText ";
        }
        messageController.selection = TextSelection.fromPosition(
          TextPosition(offset: messageController.text.length),
        );

        // Add the mention to mentionsMap
        mentionsMap.add({mention.id!: mention.name!});

        myFocusNode.requestFocus();
      });
    }
    if (notiAll) {
      setState(() {
        messageController.text = "@all ";
        messageController.selection = TextSelection.fromPosition(
          TextPosition(offset: messageController.text.length),
        );
        myFocusNode.requestFocus();
      });
    }
  }

  Row sendThread(
    List<Thread> threads,
    Size size,
  ) {
    handleFilePicked() async {
      FilePickerResult? result = await FilePicker.platform
          .pickFiles(withReadStream: true, allowMultiple: true);

      List<PlatformFile> files = result!.files;
      if (files.isNotEmpty) {
        // add to thread show in UI
        setState(() {});
        List<FileModel> fileList = [];
        for (var file in files) {
          FileModel fileModel = FileModel(
              path: file.path!,
              filename: file.name,
              size: convertToSize(file.size));
          fileList.add(fileModel);
        }
        setState(() {
          threads.add(Thread(
              files: fileList,
              createdAt: DateTime.now().subtract(const Duration(hours: 7)),
              user: userExisting,
              stoneId: "11111111"));
        });

        final response = await api.uploadFiles(files);
        if (response == null) {
          //remove thread
          SnackBar snackBar = const SnackBar(
            content: Text("Tải file thất bại"),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          setState(() {
            threads.removeLast();
          });
        } else {
          setState(() {
            for (var i = 0;
                i < threads[threads.length - 1].files!.length;
                i++) {
              var path = response[i]["path"];
              threads[threads.length - 1].files![i].path = path;
            }
            fileData = response;
          });

          _sendMessage();
        }
      }
    }

    Future<void> sendRecord() async {
      var path = await audioRecord.stop();
      var uuid = const Uuid();
      String randomFileName = uuid.v4();
      if (path != null) {
        // Create an instance of FlutterSoundHelper
        final FlutterSoundHelper audioHelper = FlutterSoundHelper();

        // Convert the audio file to mp3
        final String mp3Path = path!.replaceFirst('.wav', '.mp3');
        await audioHelper.convertFile(path, Codec.pcm16WAV, mp3Path, Codec.mp3);
        // Now you have an mp3 file at the path mp3Path
        path = mp3Path;
        // Read the mp3 file as bytes
        final mp3File = File(mp3Path);
        FileModel fileModel = FileModel(path: mp3Path);
        setState(() {
          threads.add(Thread(
              files: [fileModel],
              createdAt: DateTime.now().subtract(const Duration(hours: 7)),
              user: userExisting,
              stoneId: "11111111"));
        });
        final bytes = await mp3File.readAsBytes();

        // Get the file extension and size
        final extension = mp3Path.split(".").last;
        final size = bytes.length;

        // Create the data object
        var data = {
          "filename": randomFileName + p.basename(mp3File.path),
          "extension": extension,
          "size": size,
          "bytes": bytes,
        };

        final response = await api.uploadFile(data);
        setState(() {
          fileData = [response];
        });
        _sendMessage();
        Navigator.pop(context);
      }
    }

    triggerMentions(String text) {
      List<String> targetMentions = text.split("@");

      if (text.contains("@")) {
        if (data != null) {
          String searchTarget = targetMentions[targetMentions.length - 1];
          if (data is Channel) {
            Channel channel = data;
            List<User> users = channel.users!;
            List<User> mentionsSearch = [];
            for (var user in users) {
              String? name = user.name;
              if (name != null &&
                  name.toLowerCase().contains(searchTarget.toLowerCase())) {
                mentionsSearch.add(user);
              }
            }
            setState(() {
              if (mentionsSelected.isNotEmpty) {
                mentionsSearch = mentionsSearch.where((element) {
                  return mentionsSelected.any((element2) {
                    return element.id != element2.id;
                  });
                }).toList();
              }

              if (mentionsSelected.length == mentionsDefault.length) {
                mentionsSearch = [];
                isMention = false;
              }

              mentionsShow = mentionsSearch;
            });
          }
        }
      }
    }

    typingMsg() {
      late String receiveId;
      late dynamic members;
      String type = widget.data["type"];
      String id = widget.data["id"];
      bool isChannel = false;
      bool isChat = false;
      type == "channel"
          ? isChannel = true
          : type == "chat"
              ? isChat = true
              : null;

      if (isChannel) {
        members = widget.data["members"].map((e) => e).toList();
      } else if (isChat) {
        receiveId = widget.data["receiverId"];
      }
      if (messageController.text.isNotEmpty || fileData.length > 0) {
        var data = {
          if (isChannel) ...{
            "channelId": id,
            "members": members,
          } else if (isChat) ...{
            "chatId": id,
            "receiveId": receiveId,
          }
        };

        SocketConfig.emit(SocketMessage.typing, data);
      }
    }

    return Row(
      children: [
        IconButton(
          onPressed: () async {
            final ImagePicker picker = ImagePicker();
            final XFile? image =
                await picker.pickImage(source: ImageSource.camera);
            if (image != null) {
              // Read the image file into a Uint8List
              FileModel fileModel = FileModel(path: image.path);
              setState(() {
                threads.add(Thread(
                    files: [fileModel],
                    createdAt:
                        DateTime.now().subtract(const Duration(hours: 7)),
                    user: userExisting,
                    stoneId: "11111111"));
              });

              final bytes = await image.readAsBytes();

              // Get the file extension
              final extension = image.path.split(".").last;
              final size = bytes.length;

              var data = {
                "filename": image.name,
                "extension": extension,
                "size": size,
                "bytes": bytes,
              };
              final response = await api.uploadFile(data);
              setState(() {
                fileData = [response];
              });

              _sendMessage();
            }
          },
          icon: const Icon(Icons.camera_alt),
        ),
        Expanded(
          child: TextFormField(
            controller: messageController,
            focusNode: myFocusNode,
            onChanged: (value) {
              if (value.isNotEmpty) {
                typingMsg();
              }
              String textTyping = value.split(" ").last;
              if (textTyping.contains("@")) {
                setState(() {
                  isMention = true;
                });
                triggerMentions(value);
              } else {
                setState(() {
                  isMention = false;
                });
              }

              if (value.isEmpty) {
                setState(() {
                  mentionsSelected = [];
                  mentionsMap = [];
                });
              } else {
                for (Map<String, String> mention in List.from(mentionsMap)) {
                  // Create a copy of mentionsMap to avoid concurrent modification
                  String id = mention.keys.first;
                  if (!value.contains("@${mention[id]}")) {
                    // If a mention is not in the value, remove it from mentionsMap and selectionUser
                    setState(() {
                      mentionsMap.remove(mention);
                      mentionsSelected.removeWhere((user) => user.id == id);
                    });
                  }
                }
              }
              setState(() {
                isTextNotEmpty = value.isNotEmpty;
              });
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Tin nhắn',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
                borderSide: BorderSide.none,
              ),
              // Kiểm tra biến isTextNotEmpty để xác định icon sẽ hiển thị
              suffixIcon: isTextNotEmpty
                  ? IconButton(
                      onPressed: () {
                        // Xử lý sự kiện khi trường văn bản không trống
                        _sendMessage();
                      },
                      icon: const Icon(Icons.send),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => handleFilePicked(),
                          icon: const Icon(Icons.attach_file),
                        ),
                        IconButton(
                          onPressed: () {
                            showModalBottomSheet(
                                context: context,
                                builder: (BuildContext context) {
                                  _startRecord();
                                  return Container(
                                    height: size.height * 0.4,
                                    width: size.width,
                                    // color: Colors.white,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                    ),
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Container(
                                            width: size.width * 0.8,
                                            height: 50,
                                            decoration: BoxDecoration(
                                                color: Colors.grey,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        18.0)),
                                            child: const Center(
                                                child: Text(
                                              'Đang ghi âm...',
                                            )),
                                          ),
                                          const SizedBox(height: 20),
                                          const CircularProgressIndicator(),
                                          const SizedBox(height: 20),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              RecordFunction(
                                                icon: FontAwesomeIcons.trash,
                                                title: 'Huỷ',
                                                onPressed: () async {
                                                  await audioRecord.stop();
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              RecordFunction(
                                                icon: Icons.send,
                                                title: 'Gửi',
                                                onPressed: sendRecord,
                                              ),
                                            ],
                                          )
                                        ]),
                                  );
                                });
                          },
                          icon: const Icon(Icons.mic),
                        ),

                        // Thêm các IconButton khác nếu cần
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  void scrollTo(int index) => itemScrollController.scrollTo(
      index: index,
      duration: scrollDuration,
      curve: Curves.easeInOutCubic,
      alignment: 0);

  void jumpTo(int index) =>
      itemScrollController.jumpTo(index: index, alignment: 0);
  GestureDetector pinThread(Thread thread) {
    String text = thread.messages!.message;
    int lengthEnable = showAllPin ? 30 : 20;
    if (text.toString().length > lengthEnable) {
      text = "${text.toString().substring(0, lengthEnable)}...";
    } else {
      text = text;
    }
    return GestureDetector(
      onTap: () {
        // GoRouter.of(context).pushNamed(MyAppRouteConstants.mainRouteName);
        //go to position of thread use stoneId
        //find index of thread in threadsPosition
        int index = threadsPosition
            .indexWhere((element) => element.stoneId == thread.stoneId);
        if (index != -1) {
          setState(() {
            showAllPin = false;
          });
          jumpTo(index);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 3),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey, width: 1.0),
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 5),
            const Icon(Icons.message_rounded, color: Colors.blue),
            const SizedBox(width: 5),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Tin nhắn",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text("${thread.user!.name}: $text"),
              ],
            ),
            const Spacer(),
            pinThreads.length <= 1 || showAllPin
                ? Container()
                : TextButton(
                    onPressed: () {
                      setState(() {
                        showAllPin = true;
                      });
                    },
                    child: const Text(
                      "Xem tất cả",
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _startRecord() async {
    if (await audioRecord.hasPermission()) {
      await audioRecord.start(const RecordConfig(), path: path);
      setState(() {
        isRecording = true;
      });
    }
  }

  bool checkTimeSentWithCurrentTime(DateTime time) {
    var timeSent = time.toLocal().toString().split(" ")[0];
    var now = DateTime.now().toString().split(" ")[0];

    return timeSent == now;
  }

  void _sendMessage() async {
    late String receiveId;
    late dynamic members;
    late String cloudId;
    String type = widget.data["type"];
    String id = widget.data["id"];
    bool isChannel = false;
    bool isChat = false;
    bool isCloud = false;
    type == "channel"
        ? isChannel = true
        : type == "chat"
            ? isChat = true
            : isCloud = true;

    if (isChannel) {
      members = widget.data["members"].map((e) => e["id"]).toList();
    } else if (isChat) {
      receiveId = widget.data["receiverId"];
    } else {
      cloudId = widget.data["id"];
    }

    if (messageController.text.isNotEmpty || fileData.length > 0) {
      var data = {
        if (messageController.text.isNotEmpty)
          "messages": {"message": messageController.text},
        if (fileData.length > 0) "fileCreateDto": fileData,
        if (_replyStoneId.isNotEmpty) "replyId": _replyStoneId,
        if (_replyStoneId.isNotEmpty) "replysTo": replyThread.toMap(),
        if (mentionsSelected.isNotEmpty)
          "mentions": mentionsSelected.map((e) => e.id).toList(),
        if (isChannel) ...{
          "channelId": id,
          "name": name,
          "members": members,
        } else if (isChat) ...{
          "chatId": id,
          "receiveId": receiveId,
        } else ...{
          "cloudId": cloudId,
        }
      };
      setState(() {
        _reply = false;
      });
      SocketConfig.emit(SocketMessage.sendThread, data);

      if (messageController.text.isNotEmpty) {
        setState(() {
          isTextNotEmpty = false;
        });
        messageController.clear();
      }
    }
  }
}
