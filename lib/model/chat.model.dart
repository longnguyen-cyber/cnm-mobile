// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:zalo_app/model/thread.model.dart';
import 'package:zalo_app/model/user.model.dart';

class Chat {
  final String? id;
  final String receiveId;
  final String senderId;
  final bool isFriend;
  final bool requestAdd;
  final List<Thread>? threads;

  final DateTime? timeThread;
  final User? user;
  Chat(
      {required this.id,
      required this.receiveId,
      required this.senderId,
      required this.isFriend,
      required this.requestAdd,
      required this.timeThread,
      this.user,
      this.threads});

  Chat copyWith({
    String? id,
    String? receiveId,
    String? senderId,
    DateTime? timeThread,
  }) {
    return Chat(
      id: id ?? this.id,
      receiveId: receiveId ?? this.receiveId,
      senderId: senderId ?? this.senderId,
      isFriend: isFriend,
      requestAdd: requestAdd,
      timeThread: timeThread ?? this.timeThread,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'receiveId': receiveId,
      'senderId': senderId,
      'timeThread': timeThread?.millisecondsSinceEpoch,
      "isFriend": isFriend,
      "requestAdd": requestAdd,
      "user": user?.toMap(),
      "threads": threads?.map((x) => x.toMap()).toList(),
    };
  }

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      id: map['id'] != null ? map['id'] as String : null,
      receiveId: map['receiveId'] != null ? map['receiveId'] as String : "",
      senderId: map['senderId'] != null ? map['senderId'] as String : "",
      isFriend: map['isFriend'] != null ? map['isFriend'] as bool : false,
      requestAdd: map['requestAdd'] != null ? map['requestAdd'] as bool : false,
      user: map['user'] != null
          ? User.fromMap(map['user'] as Map<String, dynamic>)
          : null,
      timeThread: map['timeThread'] != null
          ? DateTime.parse(map['timeThread'] as String)
          : null,
      threads: map['threads'] != null
          ? (map['threads'] as List<dynamic>)
              .map<Thread>((x) => Thread.fromMap(x as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  String toJson() => json.encode(toMap());

  factory Chat.fromJson(String source) =>
      Chat.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Chat(id: $id, receiveId: $receiveId, senderId: $senderId, isFriend: $isFriend, requestAdd: $requestAdd, timeThread: $timeThread, user: $user, threads: $threads)';
  }

  @override
  bool operator ==(covariant Chat other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.receiveId == receiveId &&
        other.senderId == senderId &&
        other.timeThread == timeThread;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        receiveId.hashCode ^
        senderId.hashCode ^
        timeThread.hashCode;
  }
}
