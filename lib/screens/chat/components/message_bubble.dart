// ignore_for_file: collection_methods_unrelated_type

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:popover/popover.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zalo_app/config/socket/socket.dart';
import 'package:zalo_app/config/socket/socket_event.dart';
import 'package:zalo_app/config/socket/socket_message.dart';
import 'package:zalo_app/model/emoji.model.dart';
import 'package:zalo_app/model/user.model.dart';
import 'package:zalo_app/screens/chat/components/voice.dart';
import 'package:zalo_app/screens/chat/enums/function_chat.dart';
import 'package:zalo_app/screens/chat/enums/reaction.dart';

import 'constants/constants.dart';
import 'utils/caculate_text.dart';

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
      required this.emojis,
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
  final List<EmojiModel> emojis;
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
  var emojiMap = {
    Reaction.like.name: likeEmoji,
    Reaction.love.name: loveEmoji,
    Reaction.laugh.name: laughingEmoji,
    Reaction.sad.name: sadEmoji,
    Reaction.angry.name: angryEmoji,
  };
  bool isReactionSelected = false;
  late List<Map<String, dynamic>> reactionIcon = [];

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

    for (var e in widget.emojis) {
      var emoji = emojiMap[e.emoji];
      if (emoji != null) {
        if (mounted) {
          setState(() {
            reactionIcon
                .add({'emoji': e.emoji, 'icon': emoji, 'quantity': e.quantity});
          });
        }
      }
    }
// response:{
//     "emoji": "love",
//     "stoneId": "c376010a-fcd0-4aea-9094-77d162b56632",
//     "receiveId": "65dd4ae4cbeffa04dbbc5b16",
//     "typeEmoji": "add",
//     "type": "chat"
// }
    SocketConfig.listen(SocketEvent.updatedEmojiThread, (response) {
      String emoji = response['emoji'];
      var index =
          reactionIcon.indexWhere((element) => element['emoji'] == emoji);
      String stoneId = response['stoneId'];
      if (userExisting?.id == response['receiveId']) {
        if (stoneId != widget.stoneId) return;
        if (index != -1) {
          if (mounted) {
            setState(() {
              if (response['typeEmoji'] == 'add') {
                reactionIcon[index]['quantity']++;
              } else {
                reactionIcon[index]['quantity']--;
                if (reactionIcon[index]['quantity'] == 0) {
                  reactionIcon.removeAt(index);
                }
              }
            });
          }
        } else {
          if (response['typeEmoji'] == 'add') {
            var emojiIcon = emojiMap[emoji];
            if (emojiIcon != null) {
              if (mounted) {
                setState(() {
                  reactionIcon
                      .add({'emoji': emoji, 'icon': emojiIcon, 'quantity': 1});
                });
              }
            }
          }
        }
      }
    });
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
    return Stack(
      children: [
        Align(
          alignment: alignment,
          child: GestureDetector(
            onLongPress: () {
              // if (!widget.isRecall!) {
              showPopover(
                context: context,
                bodyBuilder: (context) => ListItems(
                    isRecall: widget.isRecall!,
                    senderId: widget.user.id!,
                    userId: userExisting!.id!,
                    onReactionSelected: handleReaction,
                    onFunctionSelected: handleFunction),
                onPop: () => print('Popover was popped!'),
                direction: PopoverDirection.bottom,
                width: size.width * 0.8,
                height: null,
                arrowHeight: 0,
                arrowWidth: 0,
              );
              // }
            },
            child: Container(
              constraints: BoxConstraints(maxWidth: size.width * 0.66),
              width: caulateWidth(widget.content ?? '', size.width * 0.66),
              // width: 100,
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
                mainAxisAlignment: MainAxisAlignment.start,
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
          child: reactionIcon.isEmpty
              ? const SizedBox.shrink()
              : Row(
                  children: [
                    for (var reaction in reactionIcon)
                      // Text(reaction["quantity"].toString(),),
                      SizedBox(
                        width: 16, // Set the width
                        height: 16, // Set the height
                        child: reaction['icon'],
                      )
                  ],
                ),
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
    setState(() {
      isReactionSelected = true;
      Image emoji;
      switch (reaction) {
        case Reaction.love:
          emoji = loveEmoji;
          break;
        case Reaction.like:
          emoji = likeEmoji;
          break;
        case Reaction.laugh:
          emoji = laughingEmoji;
          break;
        case Reaction.sad:
          emoji = sadEmoji;
          break;
        case Reaction.angry:
          emoji = angryEmoji;
          break;
        default:
          isReactionSelected = false;
          Navigator.pop(context);
          return;
      }
      addEmojiIfNotExist(emoji, reaction.name);
      Navigator.pop(context);
    });
  }

  void addEmojiIfNotExist(Image emojiIcon, String emojiName) {
    for (var reaction in reactionIcon) {
      if (reaction['emoji'] == emojiName) {
        if (reaction['quantity'] == 1) {
          reactionIcon.remove(reaction);
          removeEmoji(emojiName);
          return;
        } else {
          reaction['quantity']++;
          return;
        }
      }
    }
    addEmoji(emojiName);

    reactionIcon.add({'emoji': emojiName, 'icon': emojiIcon, 'quantity': 1});
  }

  void addEmoji(String emoji) {
    var data = {
      "emoji": emoji,
      "stoneId": widget.stoneId,
      "receiveId": widget.receiveId,
      "typeEmoji": "add"
    };
    SocketConfig.emit(SocketMessage.emoji, data);
  }

  void removeEmoji(String emoji) {
    var data = {
      "emoji": emoji,
      "stoneId": widget.stoneId,
      "receiveId": widget.receiveId,
      "typeEmoji": "remove"
    };
    SocketConfig.emit(SocketMessage.emoji, data);
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
    required this.isRecall,
  });

  final Function(Reaction) onReactionSelected;
  final Function(FunctionChat) onFunctionSelected;
  final String senderId;
  final String userId;
  final bool isRecall;

  @override
  _ListItemsState createState() => _ListItemsState();
}

class _ListItemsState extends State<ListItems> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Wrap(
        // padding: const EdgeInsets.all(8),
        children: [
          Container(
            height: 50,
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                InkWell(
                    onTap: () {
                      widget.onReactionSelected(Reaction.love);
                    },
                    child: loveEmoji),
                InkWell(
                    onTap: () {
                      widget.onReactionSelected(Reaction.like);
                    },
                    child: likeEmoji),
                InkWell(
                    onTap: () {
                      widget.onReactionSelected(Reaction.laugh);
                    },
                    child: laughingEmoji),
                // InkWell(
                //     onTap: () {
                //       widget.onReactionSelected(Reaction.smile);
                //     },
                //     child: smileEmoji),
                InkWell(
                    onTap: () {
                      widget.onReactionSelected(Reaction.sad);
                    },
                    child: sadEmoji),
                InkWell(
                    onTap: () {
                      widget.onReactionSelected(Reaction.angry);
                    },
                    child: angryEmoji),
              ],
            ),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (widget.isRecall == false)
                MenuItemChat(
                  title: 'Trả lời',
                  icon: FontAwesomeIcons.reply,
                  color: Colors.purple,
                  func: FunctionChat.reply,
                  onClick: () {
                    widget.onFunctionSelected(FunctionChat.reply);
                  },
                ),
              if (widget.isRecall == false)
                MenuItemChat(
                  title: 'Chuyển tiếp',
                  icon: FontAwesomeIcons.share,
                  color: Colors.blue,
                  func: FunctionChat.share,
                  onClick: () {
                    widget.onFunctionSelected(FunctionChat.share);
                  },
                ),
              if (widget.senderId == widget.userId && widget.isRecall == false)
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
      child: InkWell(
        onTap: onClick,
        splashColor: Colors.grey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            const Spacer(),
            FaIcon(icon, color: color),
            const Spacer(),
            Text(
              title,
              style: TextStyle(fontSize: 9),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
