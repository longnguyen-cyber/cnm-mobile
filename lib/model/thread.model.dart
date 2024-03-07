import 'dart:convert';

import 'package:flutter/foundation.dart';
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
    this.reactions,
    this.files,
    this.user,
    this.replys,
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
      messages: messages ?? messages,
      reactions: reactions ?? this.reactions,
      files: files ?? this.files,
      user: user ?? this.user,
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
      'replys': replys?.map((x) => x.toMap()).toList(),
    };
  }

  factory Thread.fromMap(Map<String, dynamic> map) {
    return Thread(
      id: map['id'] as String,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
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
      reactions: map['reactions'] != null
          ? (map['reactions'] as List<dynamic>)
              .map<Reaction>((e) => Reaction.fromMap(e as Map<String, dynamic>))
              .toList()
          : [],
      files: map['files'] != null
          ? (map['files'] as List<dynamic>)
              .map<File>((e) => File.fromMap(e as Map<String, dynamic>))
              .toList()
          : [],
      user: map['user'] != null
          ? User.fromMap(map['user'] as Map<String, dynamic>)
          : null,
      replys: map['replys'] != null
          ? (map['replys'] as List<dynamic>)
              .map<Thread>((e) => Thread.fromMap(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  String toJson() => json.encode(toMap());

  factory Thread.fromJson(String source) =>
      Thread.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Thread(id: $id, updatedAt: $updatedAt, isEdited: $isEdited, isReply: $isReply, isRecall: $isRecall, receiveId: $receiveId, senderId: $senderId, chatId: $chatId, channelId: $channelId, threadId: $threadId, messages: $messages, reactions: $reactions, files: $files, user: $user, replys: $replys)';
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
        replys.hashCode;
  }
}
