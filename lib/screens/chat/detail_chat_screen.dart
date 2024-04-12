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

  final messageController = TextEditingController();
  bool isTextNotEmpty = false;
  final List<dynamic> messages = [];
  String _replyUser = "";
  String _replyContent = "";
  bool _reply = false;
  List<Thread> threadsChannel = [];
  List<Thread> threadsChat = [];
  late dynamic data;
  late dynamic fileData = [];
  late AudioRecorder audioRecord;
  late AudioPlayer audioPlayer;
  bool isRecording = false;
  String path = "";
  late String name;
  late dynamic members;

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
        }
      } else {
        final response = await api.get("channels/$id", {});
        if (response != null) {
          Channel channel = Channel.fromMap(response["data"]);
          setState(() {
            threadsChannel = channel.threads!;
            data = channel;
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
                    //create new message in thread[index]

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

          Thread thread = Thread.fromMap(data);
          if (members.contains(userExisting!.id)) {
            setState(() {
              if (thread.files!.isNotEmpty &&
                  thread.messages == null &&
                  response["receiveId"] != userExisting!.id) {
                //get latest thread and update file path
                var index = threadsChannel.length - 1;
                for (var i = 0; i < thread.files!.length; i++) {
                  var path = thread.files![i].path;
                  threadsChannel[index].files![i].path = path;
                }
              } else {
                threadsChannel.add(thread);
              }
            });
          } else if (response["receiveId"] == userExisting!.id ||
              response["user"]["id"] == userExisting!.id) {
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
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);

    name = widget.data["name"];
    final String type = widget.data["type"];
    if (widget.data["type"] == "channel") {
      members = widget.data["members"];
    }

    return Scaffold(
        appBar: AppBar(
          title: Column(
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 20,
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
                GoRouter.of(context).pushNamed(
                    MyAppRouteConstants.moreRouteName,
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
            : common(viewInsets, threadsChat, type));
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
    ScrollController controller = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.hasClients) {
        controller.jumpTo(controller.position.maxScrollExtent);
      }
    });
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
            content: Text("Upload file thất bại"),
          );
          // ignore: use_build_context_synchronously
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
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    }

    return SafeArea(
        child: Container(
      width: double.infinity,
      color: Colors.blueGrey[50],
      child: Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 8.0,
            bottom: (viewInsets.bottom > 0) ? 8.0 : 0.0,
          ),
          child: Column(children: <Widget>[
            Expanded(
              child: ListView.builder(
                controller: controller,
                itemCount: threads.length,
                itemBuilder: (BuildContext context, int index) {
                  Thread thread = threads[index];
                  List<Widget> children = [];

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
                        threads[index - 1].user!.name == thread.user!.name;
                    if (thread.user!.id == userExisting!.id) {
                      children.add(
                        MessageBubble(
                          stoneId: thread.stoneId!,
                          user: userExisting!,
                          receiveId:
                              thread.receiveId != null ? thread.receiveId! : "",
                          type: type,
                          typeRecall:
                              thread.messages != null ? "text" : "image",
                          content: thread.messages != null
                              ? thread.messages!.message
                              : "",
                          timeSent: (thread.createdAt!),
                          emojis: thread.emojis != null ? thread.emojis! : [],
                          files: thread.files!,
                          isReply: thread.isReply,
                          isRecall: thread.isRecall,
                          onFuctionReply: (sender, content) {
                            setState(() {
                              _reply = true;
                              _replyUser = sender;
                              _replyContent = content;
                            });
                          },
                        ),
                      );
                    } else {
                      children.add(
                        Message(
                          stoneId: thread.stoneId!,
                          sender: thread.user!,
                          type: type,
                          receiveId:
                              thread.senderId != null ? thread.senderId! : "",
                          content: thread.messages != null
                              ? thread.messages!.message
                              : "",
                          messageType: MessageType.text,
                          timeSent: thread.createdAt!,
                          onFuctionReply: (sender, content) {
                            setState(() {
                              _reply = true;
                              _replyUser = sender;
                              _replyContent = content;
                            });
                          },
                          exist: !nameExisted,
                          isRecall: thread.isRecall!,
                          emojis: thread.emojis!,
                          files: thread.files!,
                        ),
                      );
                    }
                  }

                  if (isDifferentDay(index)) {
                    DateTime currentMessageDate = (threads[index].createdAt!);
                    DateTime now = DateTime.now();

                    String formattedDate;
                    if (currentMessageDate.year == now.year &&
                        currentMessageDate.month == now.month &&
                        currentMessageDate.day == now.day - 1) {
                      formattedDate = 'Hôm nay';
                    } else {
                      formattedDate =
                          DateFormat('dd/MM/yyyy').format(currentMessageDate);
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
                            color: Colors.blue, // Màu sắc của đường kẻ thẳng
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
                                      color: Colors.black, fontSize: 16),
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
            Row(children: [
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
                onChanged: (value) {
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
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  RecordFunction(
                                                    icon:
                                                        FontAwesomeIcons.trash,
                                                    title: 'Huỷ',
                                                    onPressed: () async {
                                                      await audioRecord.stop();
                                                      // ignore: use_build_context_synchronously
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
              )),
            ]),
            const SizedBox(height: 8.0),
          ])),
    ));
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
    if (widget.data["type"] == "channel") {
      members = widget.data["members"].map((e) => e).toList();
    } else {
      receiveId = widget.data["receiverId"];
    }

    if (messageController.text.isNotEmpty) {
      if (widget.data["type"] == "channel") {
        SocketConfig.emit(SocketMessage.sendThread, {
          "messages": {
            "message": messageController.text,
          },
          "channelId": widget.data["id"],
          "members": members,
        });
      } else {
        SocketConfig.emit(SocketMessage.sendThread, {
          "messages": {
            "message": messageController.text,
          },
          "chatId": widget.data["id"],
          "receiveId": receiveId,
        });
      }
      setState(() {
        isTextNotEmpty = false;
      });
      messageController.clear();
    } else if (fileData.length > 0) {
      if (widget.data["type"] == "channel") {
        SocketConfig.emit(SocketMessage.sendThread, {
          "channelId": widget.data["id"],
          "members": members,
          "fileCreateDto": fileData
        });
      } else {
        SocketConfig.emit(SocketMessage.sendThread, {
          "chatId": widget.data["id"],
          "receiveId": receiveId,
          "fileCreateDto": fileData
        });
      }
    }
  }
}

//


