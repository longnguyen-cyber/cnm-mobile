// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

// model messages {
//   id        String    @id @default(auto()) @map("_id") @db.ObjectId
//   message   String
//   createdAt DateTime  @default(now())
//   updatedAt DateTime  @updatedAt
//   deletedAt DateTime?
//   threadId  String?   @unique @db.ObjectId
//   thread    threads?  @relation(fields: [threadId], references: [id])
// }

class MessageModel {
  final String? id;
  String message;

  MessageModel({
    this.id,
    required this.message,
  });

  MessageModel copyWith({
    String? id,
    String? message,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      message: message ?? this.message,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'message': message,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] != null ? map['id'] as String : null,
      message: map['message'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory MessageModel.fromJson(String source) =>
      MessageModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Message(id: $id, message: $message)';
  }

  @override
  bool operator ==(covariant MessageModel other) {
    if (identical(this, other)) return true;

    return other.id == id && other.message == message;
  }

  @override
  int get hashCode {
    return id.hashCode ^ message.hashCode;
  }
}
