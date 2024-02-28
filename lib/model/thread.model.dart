import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:zalo_app/model/channel.model.dart';
import 'package:zalo_app/model/chat.model.dart';
import 'package:zalo_app/model/file.model.dart';
import 'package:zalo_app/model/message.model.dart';
import 'package:zalo_app/model/react.model.dart';
import 'package:zalo_app/model/user.model.dart';

class Thread {
  final String? id;
  final DateTime? updatedAt;
  final bool? isEdited;
  final bool? isReply;
  final bool? isRecall;
  final String? receiveId;
  final String? senderId;
  final String? chatId;
  final String? channelId;
  final String? threadId;
  final Message? messages;
  final List<Reaction>? reactions;
  final List<File>? files;
  final User? user;
  final Chat? chats;
  final Channel? channel;
  final Thread? reply;
  final List<Thread>? replys;
  Thread({
    required this.id,
    required this.updatedAt,
    this.isEdited,
    this.isReply,
    this.isRecall,
    this.receiveId,
    this.senderId,
    this.chatId,
    this.channelId,
    this.threadId,
    this.messages,
    required this.reactions,
    required this.files,
    this.user,
    this.chats,
    this.channel,
    this.reply,
    required this.replys,
  });

  Thread copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool? isEdited,
    bool? isReply,
    bool? isRecall,
    String? receiveId,
    String? senderId,
    String? chatId,
    String? channelId,
    String? threadId,
    Message? messages,
    List<Reaction>? reactions,
    List<File>? files,
    User? user,
    Chat? chats,
    Channel? channel,
    Thread? reply,
    List<Thread>? replys,
  }) {
    return Thread(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      isEdited: isEdited ?? this.isEdited,
      isReply: isReply ?? this.isReply,
      isRecall: isRecall ?? this.isRecall,
      receiveId: receiveId ?? this.receiveId,
      senderId: senderId ?? this.senderId,
      chatId: chatId ?? this.chatId,
      channelId: channelId ?? this.channelId,
      threadId: threadId ?? this.threadId,
      messages: messages ?? this.messages,
      reactions: reactions ?? this.reactions,
      files: files ?? this.files,
      user: user ?? this.user,
      chats: chats ?? this.chats,
      channel: channel ?? this.channel,
      reply: reply ?? this.reply,
      replys: replys ?? this.replys,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'isEdited': isEdited,
      'isReply': isReply,
      'isRecall': isRecall,
      'receiveId': receiveId,
      'senderId': senderId,
      'chatId': chatId,
      'channelId': channelId,
      'threadId': threadId,
      'messages': messages?.toMap(),
      'reactions': reactions?.map((x) => x.toMap()).toList(),
      'files': files?.map((x) => x.toMap()).toList(),
      'user': user?.toMap(),
      'chats': chats?.toMap(),
      'channel': channel?.toMap(),
      'reply': reply?.toMap(),
      'replys': replys?.map((x) => x.toMap()).toList(),
    };
  }

  factory Thread.fromMap(Map<String, dynamic> map) {
    return Thread(
      id: map['id'] as String,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] != null
          ? map['updatedAt'] as int
          : DateTime.now().millisecondsSinceEpoch),
      isEdited: map['isEdited'] != null ? map['isEdited'] as bool : null,
      isReply: map['isReply'] != null ? map['isReply'] as bool : null,
      isRecall: map['isRecall'] != null ? map['isRecall'] as bool : null,
      receiveId: map['receiveId'] != null ? map['receiveId'] as String : null,
      senderId: map['senderId'] != null ? map['senderId'] as String : null,
      chatId: map['chatId'] != null ? map['chatId'] as String : null,
      channelId: map['channelId'] != null ? map['channelId'] as String : null,
      threadId: map['threadId'] != null ? map['threadId'] as String : null,
      messages: map['messages'] != null
          ? Message.fromMap(map['messages'] as Map<String, dynamic>)
          : null,
      reactions: List<Reaction>.from(
        (map['reactions'] != null ? map['reactions'] as List<int> : [])
            .map<Reaction>(
          (x) => Reaction.fromMap(x as Map<String, dynamic>),
        ),
      ),
      files: List<File>.from(
        (map['files'] != null ? map['files'] as List<int> : []).map<File>(
          (x) => File.fromMap(x as Map<String, dynamic>),
        ),
      ),
      user: map['user'] != null
          ? User.fromMap(map['user'] as Map<String, dynamic>)
          : null,
      chats: map['chats'] != null
          ? Chat.fromMap(map['chats'] as Map<String, dynamic>)
          : null,
      channel: map['channel'] != null
          ? Channel.fromMap(map['channel'] as Map<String, dynamic>)
          : null,
      reply: map['reply'] != null
          ? Thread.fromMap(map['reply'] as Map<String, dynamic>)
          : null,
      replys: List<Thread>.from(
        (map['replys'] as List<int>).map<Thread>(
          (x) => Thread.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory Thread.fromJson(String source) =>
      Thread.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Thread(id: $id, updatedAt: $updatedAt, isEdited: $isEdited, isReply: $isReply, isRecall: $isRecall, receiveId: $receiveId, senderId: $senderId, chatId: $chatId, channelId: $channelId, threadId: $threadId, messages: $messages, reactions: $reactions, files: $files, user: $user, chats: $chats, channel: $channel, reply: $reply, replys: $replys)';
  }

  @override
  bool operator ==(covariant Thread other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.updatedAt == updatedAt &&
        other.isEdited == isEdited &&
        other.isReply == isReply &&
        other.isRecall == isRecall &&
        other.receiveId == receiveId &&
        other.senderId == senderId &&
        other.chatId == chatId &&
        other.channelId == channelId &&
        other.threadId == threadId &&
        other.messages == messages &&
        listEquals(other.reactions, reactions) &&
        listEquals(other.files, files) &&
        other.user == user &&
        other.chats == chats &&
        other.channel == channel &&
        other.reply == reply &&
        listEquals(other.replys, replys);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        updatedAt.hashCode ^
        isEdited.hashCode ^
        isReply.hashCode ^
        isRecall.hashCode ^
        receiveId.hashCode ^
        senderId.hashCode ^
        chatId.hashCode ^
        channelId.hashCode ^
        threadId.hashCode ^
        messages.hashCode ^
        reactions.hashCode ^
        files.hashCode ^
        user.hashCode ^
        chats.hashCode ^
        channel.hashCode ^
        reply.hashCode ^
        replys.hashCode;
  }
}
