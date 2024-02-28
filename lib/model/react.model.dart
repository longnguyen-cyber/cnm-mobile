// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Reaction {
  final String? id;
  final String react;
  final int quantity;
  final String userId;
  Reaction({
    required this.id,
    required this.react,
    required this.quantity,
    required this.userId,
  });

  Reaction copyWith({
    String? id,
    String? react,
    int? quantity,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? userId,
  }) {
    return Reaction(
      id: id ?? this.id,
      react: react ?? this.react,
      quantity: quantity ?? this.quantity,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'react': react,
      'quantity': quantity,
      'userId': userId,
    };
  }

  factory Reaction.fromMap(Map<String, dynamic> map) {
    return Reaction(
      id: map['id'] as String,
      react: map['react'] as String,
      quantity: map['quantity'] as int,
      userId: map['userId'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Reaction.fromJson(String source) =>
      Reaction.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Reaction(id: $id, react: $react, quantity: $quantity, userId: $userId)';
  }

  @override
  bool operator ==(covariant Reaction other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.react == react &&
        other.quantity == quantity &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return id.hashCode ^ react.hashCode ^ quantity.hashCode ^ userId.hashCode;
  }
}
