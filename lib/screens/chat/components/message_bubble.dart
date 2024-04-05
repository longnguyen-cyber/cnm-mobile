import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:popover/popover.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zalo_app/components/voice.dart';
import 'package:zalo_app/config/socket/socket.dart';
import 'package:zalo_app/config/socket/socket_message.dart';
import 'package:zalo_app/model/user.model.dart';
import 'package:zalo_app/screens/chat/enums/function_chat.dart';
import 'package:zalo_app/screens/chat/enums/reaction.dart';

class MessageBubble extends StatefulWidget {
  const MessageBubble(
      {super.key,
      required this.stoneId,
      required this.user,
      required this.type,
      this.content,
      required this.timeSent,
      this.files,
      this.videoUrl,
      this.reaction,
      this.isRecall,
      this.isReply,
      this.replyContent,
      this.replyUser,
      required this.onFuctionReply,
      this.receiveId,
      this.typeRecall});
  final String? receiveId;
  final String stoneId;
  final User user;
  final String type;
  final String? content;
  final DateTime timeSent;
  final List<String>? files;
  final String? videoUrl;
  final Reaction? reaction;
  final bool? isRecall;
  final bool? isReply;
  final String? replyContent;
  final String? replyUser;
  final String? typeRecall;
  final Function(String, String) onFuctionReply; // người rep và content

  @override
  // ignore: library_private_types_in_public_api
  _MessageBubbleState createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool isReactionSelected = false;
  Icon reactionIcon = const Icon(
    FontAwesomeIcons.heart,
  );

  User? userExisting = User();
  late List<AudioPlayer>? audioPlayers;

  void getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token") ?? "";
    var userOfToken = prefs.getString(token) ?? "";
    if (userOfToken != "") {
      userExisting = User.fromJson(userOfToken);
    } else {
      userExisting = null;
    }
    if (mounted) {
      setState(() {
        userExisting = userExisting;
      });
    }
  }

  initAudioPlayers() {
    if (widget.files == null) return;
    audioPlayers =
        List.generate(widget.files!.length, (index) => AudioPlayer());
  }

  @override
  void initState() {
    super.initState();
    getUser();
    initAudioPlayers();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    final alignment = (widget.user.name == userExisting!.name)
        ? Alignment.centerRight
        : Alignment.centerLeft;

    var color = (widget.user.name == userExisting!.name)
        ? Colors.white
        : const Color.fromARGB(255, 126, 218, 241);
    // print(checkTimeSentWithCurrentTime(widget.timeSent));
    return Stack(
      children: [
        Align(
          alignment: alignment,
          child: GestureDetector(
            onLongPress: () {
              if (!widget.isRecall!) {
                showPopover(
                  context: context,
                  bodyBuilder: (context) => ListItems(
                      senderId: widget.user.id!,
                      userId: userExisting!.id!,
                      onReactionSelected: handleReaction,
                      onFunctionSelected: handleFunction),
                  onPop: () => print('Popover was popped!'),
                  direction: PopoverDirection.bottom,
                  width: size.width * 0.8,
                  height: 200,
                  arrowHeight: 0,
                  arrowWidth: 0,
                );
              }
            },
            child: Container(
              constraints: BoxConstraints(maxWidth: size.width * 0.66),
              padding: const EdgeInsets.only(
                top: 8.0,
                bottom: 15.0,
                left: 8.0,
                right: 8.0,
              ),
              margin: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  (widget.isReply == null || widget.isReply == false)
                      ? Text(
                          widget.content ?? '',
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Colors.black,
                                  ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 3, // Độ rộng của đường kẻ thẳng đứng
                                  height:
                                      20, // Chiều cao tối thiểu để giữ khoảng cách giữa hai đoạn văn bản
                                  color:
                                      Colors.blue, // Màu sắc của đường kẻ thẳng
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                RichText(
                                  textAlign: TextAlign.left,
                                  text: TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: '  ${widget.replyUser}\n',
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 12),
                                      ),
                                      TextSpan(
                                        text: '${widget.replyContent}\n',
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                              ],
                            ),
                            Text(
                              widget.content ?? '',
                            )
                          ],
                        ),
                  if (widget.files != null)
                    // Image.network(widget.imageUrl!, width: size.width * 0.5)
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.files!.length,
                      itemBuilder: (context, index) {
                        String fileType = widget.files![index].split('.').last;
                        if (fileType == 'jpg' ||
                            fileType == 'jpeg' ||
                            fileType == 'png' ||
                            fileType == 'gif' ||
                            fileType == "webp") {
                          return imageFile(index, size);
                        } else if (fileType == 'mp3') {
                          AudioPlayer player = audioPlayers![index];
                          player.setReleaseMode(ReleaseMode.stop);

                          WidgetsBinding.instance
                              .addPostFrameCallback((_) async {
                            await player.setSourceUrl(widget.files![index]);
                          });

                          return PlayerWidget(
                            player: player,
                          );
                        }
                        return null;
                      },
                    )
                  else
                    const SizedBox.shrink(),
                  if (widget.videoUrl != null)
                    SizedBox(
                      width: size.width * 0.5,
                      child: const Text('Video show'),
                    )
                  else
                    const SizedBox.shrink(),
                  // Container()
                  Text(parseTime(widget.timeSent),
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ),
        // if (widget.reaction != null)
        Positioned(
          bottom: 0,
          right: 0,
          child: isReactionSelected ? reactionIcon : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Image imageFile(int index, Size size) {
    return Image.network(
      widget.files![index],
      width: size.width * 0.5,
      fit: BoxFit.cover,
    );
  }

  String parseTime(DateTime time) {
    var vietnameseTime = time.add(const Duration(hours: 7));
    // return '${vietnameseTime.hour}:${vietnameseTime.minute}';
    //if minute < 10, add 0 before minute
    if (vietnameseTime.minute < 10) {
      return '${vietnameseTime.hour}:0${vietnameseTime.minute}';
    }
    return '${vietnameseTime.hour}:${vietnameseTime.minute}';
  }

  bool checkTimeSentWithCurrentTime(DateTime timeSent) {
    var currentTime = DateTime.now();
    var timeSentString = timeSent.toString();
    var currentTimeString = currentTime.toString();
    if (timeSentString.substring(0, 10) == currentTimeString.substring(0, 10)) {
      return true;
    }
    return false;
  }

  void handleReaction(Reaction reaction) {
    switch (reaction) {
      case Reaction.like:
        setState(() {
          isReactionSelected = true;
          reactionIcon =
              const Icon(Icons.thumb_up_off_alt_rounded, color: Colors.blue);
        });
        break;

      case Reaction.love:
        setState(() {
          isReactionSelected = true;
          reactionIcon = const Icon(Icons.favorite, color: Colors.red);
        });
        break;
      case Reaction.laugh:
        setState(() {
          isReactionSelected = true;
          reactionIcon = const Icon(FontAwesomeIcons.solidFaceLaughSquint,
              color: Colors.deepPurple);
        });
        break;
      case Reaction.angry:
        setState(() {
          isReactionSelected = true;
          reactionIcon = const Icon(
            FontAwesomeIcons.solidFaceAngry,
            color: Colors.redAccent,
          );
        });
        break;
      default:
        setState(() {
          isReactionSelected = false;
        });
    }
  }

  void revertFnc() {
    var data = {
      "stoneId": widget.stoneId,
      "receiveId": widget.receiveId,
      "type": widget.type,
      "typeRecall": widget.typeRecall
    };
    SocketConfig.emit(SocketMessage.recallSendThread, data);
  }

  void deleteFnc() {
    var data = {
      "stoneId": widget.stoneId,
      "receiveId": widget.receiveId,
      "type": widget.type
    };
    SocketConfig.emit(SocketMessage.deleteThread, data);
  }

  void handleFunction(FunctionChat function) {
    switch (function) {
      case FunctionChat.delete:
        // delete fuc
        deleteFnc();
        break;
      case FunctionChat.revert:
        revertFnc();
        break;
      // revert fuc
      case FunctionChat.reply:
        String? sender = widget.user.name;
        String? content = widget.content;
        widget.onFuctionReply(sender!, content!);
        break;
      case FunctionChat.share:
        // share fuc
        break;
      default:
    }
  }
}

class ListItems extends StatefulWidget {
  const ListItems({
    super.key,
    required this.onReactionSelected,
    required this.onFunctionSelected,
    required this.senderId,
    required this.userId,
  });

  final Function(Reaction) onReactionSelected;
  final Function(FunctionChat) onFunctionSelected;
  final String senderId;
  final String userId;

  @override
  _ListItemsState createState() => _ListItemsState();
}

class _ListItemsState extends State<ListItems> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          Container(
            height: 50,
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                InkWell(
                    onTap: () {
                      widget.onReactionSelected(Reaction.like);
                    },
                    child: const IconButton(
                        onPressed: null,
                        icon: Icon(Icons.thumb_up_off_alt_rounded,
                            color: Colors.blue))),
                InkWell(
                    onTap: () {
                      widget.onReactionSelected(Reaction.love);
                    },
                    child: const IconButton(
                        onPressed: null,
                        icon: Icon(Icons.favorite, color: Colors.red))),
                InkWell(
                    onTap: () {
                      widget.onReactionSelected(Reaction.laugh);
                    },
                    child: const IconButton(
                        onPressed: null,
                        icon: Icon(FontAwesomeIcons.solidFaceLaughSquint,
                            color: Colors.deepPurple))),
                InkWell(
                    onTap: () {
                      widget.onReactionSelected(Reaction.angry);
                    },
                    child: const IconButton(
                        onPressed: null,
                        icon: FaIcon(
                          FontAwesomeIcons.solidFaceAngry,
                          color: Colors.redAccent,
                        ))),
                InkWell(
                    onTap: () {
                      widget.onReactionSelected(Reaction.none);
                    },
                    child: const IconButton(
                        onPressed: null,
                        icon: FaIcon(
                          FontAwesomeIcons.x,
                          color: Colors.black,
                        ))),
              ],
            ),
          ),
          const Divider(),
          SizedBox(
            height: 300,
            width: double.infinity,
            child: GridView.count(
              crossAxisCount: 4,
              children: <Widget>[
                MenuItemChat(
                  title: 'Trả lời',
                  icon: FontAwesomeIcons.reply,
                  color: Colors.purple,
                  func: FunctionChat.reply,
                  onClick: () {
                    widget.onFunctionSelected(FunctionChat.reply);
                  },
                ),
                MenuItemChat(
                  title: 'Chuyển tiếp',
                  icon: FontAwesomeIcons.share,
                  color: Colors.blue,
                  func: FunctionChat.share,
                  onClick: () {
                    widget.onFunctionSelected(FunctionChat.share);
                  },
                ),
                if (widget.senderId == widget.userId)
                  MenuItemChat(
                    title: 'Thu hồi',
                    icon: FontAwesomeIcons.rotateLeft,
                    color: Colors.red,
                    func: FunctionChat.revert,
                    onClick: () {
                      widget.onFunctionSelected(FunctionChat.revert);
                    },
                  ),
                if (widget.senderId == widget.userId)
                  MenuItemChat(
                      title: 'Xoá',
                      icon: FontAwesomeIcons.trash,
                      color: Colors.redAccent,
                      func: FunctionChat.delete,
                      onClick: () {
                        widget.onFunctionSelected(FunctionChat.delete);
                      })
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MenuItemChat extends StatelessWidget {
  const MenuItemChat({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.func,
    required this.onClick,
  });

  final String title;
  final IconData icon;
  final Color color;
  final FunctionChat func;
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: const Size(56, 56),
      child: Material(
        child: InkWell(
          onTap: onClick,
          splashColor: Colors.grey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              const Spacer(),
              FaIcon(icon, color: color),
              const Spacer(),
              Text(title),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
