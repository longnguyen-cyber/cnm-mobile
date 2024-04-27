// model settings {
//   id         String   @id @default(auto()) @map("_id") @db.ObjectId
//   createdAt  DateTime @default(now())
//   updatedAt  DateTime @updatedAt
//   userId     String?  @unique @db.ObjectId
//   user       users?   @relation(fields: [userId], references: [id])
//   notify     Boolean? @default(true)
//   blockGuest Boolean  @default(false)
// }

import 'dart:convert';

class Setting {
  String id;
  bool notify;
  bool blockGuest;

  Setting({
    required this.id,
    required this.notify,
    required this.blockGuest,
  });

  Setting copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    bool? notify,
    bool? blockGuest,
  }) {
    return Setting(
      id: id ?? this.id,
      notify: notify ?? this.notify,
      blockGuest: blockGuest ?? this.blockGuest,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'notify': notify,
      'blockGuest': blockGuest,
    };
  }

  factory Setting.fromMap(Map<String, dynamic> map) {
    return Setting(
      id: map['id'] as String,
      notify: map['notify'] as bool,
      blockGuest: map['blockGuest'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory Setting.fromJson(String source) =>
      Setting.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Setting(id: $id, notify: $notify, blockGuest: $blockGuest)';
  }

  @override
  // ignore: hash_and_equals
  bool operator ==(covariant Setting other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.notify == notify &&
        other.blockGuest == blockGuest;
  }
}
