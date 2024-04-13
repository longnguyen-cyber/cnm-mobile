import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:zalo_app/model/file.model.dart';
import 'package:zalo_app/model/message.model.dart';
import 'package:zalo_app/model/emoji.model.dart';
import 'package:zalo_app/model/user.model.dart';

class Thread {
  final String? id;
  final DateTime? createdAt;
  late final bool? isEdited;
  final bool? isReply;
  bool? isRecall;
  final String? receiveId;
  final String? senderId;
  late String? stoneId;
  final String? chatId;
  final String? channelId;
  final String? threadId;
  late MessageModel? messages;
  final List<EmojiModel>? emojis;
  late List<FileModel>? files;
  final User? user;
  final Thread? replysTo;
  Thread({
    this.id,
    required this.createdAt,
    this.stoneId,
    this.isEdited,
    this.isReply,
    this.isRecall,
    this.receiveId,
    this.senderId,
    this.chatId,
    this.channelId,
    this.threadId,
    this.messages,
    this.emojis,
    this.files,
    this.user,
    this.replysTo,
  });

  Thread copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? deletedAt,
    bool? isEdited,
    bool? isReply,
    bool? isRecall,
    String? receiveId,
    String? senderId,
    String? stoneId,
    String? chatId,
    String? channelId,
    String? threadId,
    MessageModel? messages,
    List<EmojiModel>? emojis,
    List<FileModel>? files,
    User? user,
    List<Thread>? replys,
  }) {
    return Thread(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      isEdited: isEdited ?? this.isEdited,
      isReply: isReply ?? this.isReply,
      isRecall: isRecall ?? this.isRecall,
      receiveId: receiveId ?? this.receiveId,
      senderId: senderId ?? this.senderId,
      stoneId: stoneId ?? this.stoneId,
      chatId: chatId ?? this.chatId,
      channelId: channelId ?? this.channelId,
      threadId: threadId ?? this.threadId,
      messages: messages ?? messages,
      emojis: emojis ?? this.emojis,
      files: files ?? this.files,
      user: user ?? this.user,
      replysTo: replysTo ?? replysTo,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'isEdited': isEdited,
      'isReply': isReply,
      'isRecall': isRecall,
      'receiveId': receiveId,
      'senderId': senderId,
      'stoneId': stoneId,
      'chatId': chatId,
      'channelId': channelId,
      'threadId': threadId,
      'messages': messages?.toMap(),
      'emojis': emojis?.map((x) => x.toMap()).toList(),
      'files': files?.map((x) => x.toMap()).toList(),
      'user': user?.toMap(),
    };
  }

  factory Thread.fromMap(Map<String, dynamic> map) {
    return Thread(
      id: map['id'] != null ? map['id'] as String : null,
      createdAt: map['createdAt'] is String
          ? DateTime.parse(map['createdAt'] as String)
          : null,
      isEdited: map['isEdited'] != null ? map['isEdited'] as bool : null,
      isReply: map['isReply'] != null ? map['isReply'] as bool : null,
      isRecall: map['isRecall'] != null ? map['isRecall'] as bool : null,
      receiveId: map['receiveId'] != null ? map['receiveId'] as String : null,
      senderId: map['senderId'] != null ? map['senderId'] as String : null,
      stoneId: map['stoneId'] != null ? map['stoneId'] as String : null,
      chatId: map['chatId'] != null ? map['chatId'] as String : null,
      channelId: map['channelId'] != null ? map['channelId'] as String : null,
      threadId: map['threadId'] != null ? map['threadId'] as String : null,
      messages: map['messages'] != null
          ? MessageModel.fromMap(map['messages'] as Map<String, dynamic>)
          : null,
      emojis: map['emojis'] != null
          ? (map['emojis'] as List<dynamic>)
              .map<EmojiModel>(
                  (e) => EmojiModel.fromMap(e as Map<String, dynamic>))
              .toList()
          : [],
      files: map['files'] != null
          ? (map['files'] as List<dynamic>)
              .map<FileModel>(
                  (e) => FileModel.fromMap(e as Map<String, dynamic>))
              .toList()
          : [],
      user: map['user'] != null
          ? User.fromMap(map['user'] as Map<String, dynamic>)
          : null,
      replysTo: map['replysTo'] != null
          ? Thread.fromMap(map['replysTo'] as Map<String, dynamic>)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Thread.fromJson(String source) =>
      Thread.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Thread(id: $id, createdAt: $createdAt, isEdited: $isEdited, isReply: $isReply, isRecall: $isRecall, receiveId: $receiveId, senderId: $senderId, stoneId: $stoneId, chatId: $chatId, channelId: $channelId, threadId: $threadId, messages: $messages, emojis: $emojis, files: $files, user: $user, replysTo: $replysTo)';
  }

  @override
  bool operator ==(covariant Thread other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.createdAt == createdAt &&
        other.isEdited == isEdited &&
        other.isReply == isReply &&
        other.isRecall == isRecall &&
        other.receiveId == receiveId &&
        other.senderId == senderId &&
        other.stoneId == stoneId &&
        other.chatId == chatId &&
        other.channelId == channelId &&
        other.threadId == threadId &&
        other.messages == messages &&
        other.replysTo == replysTo &&
        listEquals(other.emojis, emojis) &&
        listEquals(other.files, files) &&
        other.user == user;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        createdAt.hashCode ^
        isEdited.hashCode ^
        isReply.hashCode ^
        isRecall.hashCode ^
        receiveId.hashCode ^
        senderId.hashCode ^
        stoneId.hashCode ^
        chatId.hashCode ^
        channelId.hashCode ^
        threadId.hashCode ^
        messages.hashCode ^
        emojis.hashCode ^
        files.hashCode ^
        user.hashCode ^
        replysTo.hashCode;
  }
}
