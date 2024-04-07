// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class EmojiModel {
  final String? id;
  final String emoji;
  final int quantity;
  final String? senderId;
  EmojiModel({
    this.id,
    required this.emoji,
    required this.quantity,
    this.senderId,
  });

  EmojiModel copyWith({
    String? id,
    String? emoji,
    int? quantity,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? senderId,
  }) {
    return EmojiModel(
      id: id ?? this.id,
      emoji: emoji ?? this.emoji,
      quantity: quantity ?? this.quantity,
      senderId: senderId ?? this.senderId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'react': emoji,
      'quantity': quantity,
      'senderId': senderId,
    };
  }

  factory EmojiModel.fromMap(Map<String, dynamic> map) {
    return EmojiModel(
      id: map['id'] != null ? map['id'] as String : null,
      emoji: map['emoji'] as String,
      quantity: map['quantity'] as int,
      senderId: map['senderId'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory EmojiModel.fromJson(String source) =>
      EmojiModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Emoji(id: $id, emoji: $emoji, quantity: $quantity, senderId: $senderId)';
  }

  @override
  bool operator ==(covariant EmojiModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.emoji == emoji &&
        other.quantity == quantity &&
        other.senderId == senderId;
  }

  @override
  int get hashCode {
    return id.hashCode ^ emoji.hashCode ^ quantity.hashCode ^ senderId.hashCode;
  }
}
