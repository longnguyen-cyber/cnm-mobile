// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:zalo_app/model/user.model.dart';

class Channel {
  final String? id;
  final String name;
  final bool isPublic;
  final List<User>? users;
  final String? userCreated;
  final DateTime? timeThread;
  Channel({
    this.id,
    required this.name,
    required this.isPublic,
    this.users,
    this.userCreated,
    this.timeThread,
  });

  Channel copyWith({
    String? id,
    String? name,
    bool? isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    List<User>? users,
    String? userCreated,
    DateTime? timeThread,
  }) {
    return Channel(
      id: id ?? this.id,
      name: name ?? this.name,
      isPublic: isPublic ?? this.isPublic,
      users: users ?? this.users,
      userCreated: userCreated ?? this.userCreated,
      timeThread: timeThread ?? this.timeThread,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'isPublic': isPublic,
      'users': users?.map((x) => x.toMap()).toList(),
      'userCreated': userCreated,
      'timeThread': timeThread?.millisecondsSinceEpoch,
    };
  }

  factory Channel.fromMap(Map<String, dynamic> map) {
    return Channel(
      id: map['id'] as String,
      name: map['name'] as String,
      isPublic: map['isPublic'] as bool,
      users: List<User>.from(
        (map['users'] as List<int>).map<User>(
          (x) => User.fromMap(x as Map<String, dynamic>),
        ),
      ),
      userCreated: map['userCreated'] as String,
      timeThread: DateTime.fromMillisecondsSinceEpoch(map['timeThread'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory Channel.fromJson(String source) =>
      Channel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Channel(id: $id, name: $name, isPublic: $isPublic, users: $users, userCreated: $userCreated, timeThread: $timeThread)';
  }

  @override
  bool operator ==(covariant Channel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.isPublic == isPublic &&
        listEquals(other.users, users) &&
        other.userCreated == userCreated &&
        other.timeThread == timeThread;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        isPublic.hashCode ^
        users.hashCode ^
        userCreated.hashCode ^
        timeThread.hashCode;
  }
}
