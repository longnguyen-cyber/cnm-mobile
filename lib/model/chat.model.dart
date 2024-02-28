// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Chat {
  final String? id;
  final String receiveId;
  final String senderId;
  final DateTime? timeThread;
  Chat({
    required this.id,
    required this.receiveId,
    required this.senderId,
    required this.timeThread,
  });

  Chat copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? receiveId,
    String? senderId,
    DateTime? timeThread,
  }) {
    return Chat(
      id: id ?? this.id,
      receiveId: receiveId ?? this.receiveId,
      senderId: senderId ?? this.senderId,
      timeThread: timeThread ?? this.timeThread,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'receiveId': receiveId,
      'senderId': senderId,
      'timeThread': timeThread?.millisecondsSinceEpoch,
    };
  }

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      id: map['id'] as String,
      receiveId: map['receiveId'] as String,
      senderId: map['senderId'] as String,
      timeThread: DateTime.fromMillisecondsSinceEpoch(map['timeThread'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory Chat.fromJson(String source) =>
      Chat.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Chat(id: $id, receiveId: $receiveId, senderId: $senderId, timeThread: $timeThread)';
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
