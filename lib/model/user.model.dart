// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class User {
  final String? id;
  final String? name;
  late final String? password;
  final String? displayName;
  final String? status;
  final String? phone;
  late final String? email;
  final String? avatar;
  final bool? isTwoFactorAuthenticationEnabled;
  final String? twoFactorAuthenticationSecret;

  User({
    this.id,
    this.name,
    this.password,
    this.displayName,
    this.status,
    this.phone,
    this.email,
    this.avatar,
    this.isTwoFactorAuthenticationEnabled,
    this.twoFactorAuthenticationSecret,
  });

  User copyWith({
    String? id,
    String? name,
    String? password,
    String? displayName,
    String? status,
    String? phone,
    String? email,
    String? avatar,
    bool? isTwoFactorAuthenticationEnabled,
    String? twoFactorAuthenticationSecret,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      password: password ?? this.password,
      displayName: displayName ?? this.displayName,
      status: status ?? this.status,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      isTwoFactorAuthenticationEnabled: isTwoFactorAuthenticationEnabled ??
          this.isTwoFactorAuthenticationEnabled,
      twoFactorAuthenticationSecret:
          twoFactorAuthenticationSecret ?? this.twoFactorAuthenticationSecret,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'password': password,
      'displayName': displayName,
      'status': status,
      'phone': phone,
      'email': email,
      'avatar': avatar,
      'isTwoFactorAuthenticationEnabled': isTwoFactorAuthenticationEnabled,
      'twoFactorAuthenticationSecret': twoFactorAuthenticationSecret,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] != null ? map['id'] as String : null,
      name: map['name'] != null ? map['name'] as String : null,
      password: map['password'] != null ? map['password'] as String : null,
      displayName:
          map['displayName'] != null ? map['displayName'] as String : null,
      status: map['status'] != null ? map['status'] as String : null,
      phone: map['phone'] != null ? map['phone'] as String : null,
      email: map['email'] != null ? map['email'] as String : null,
      avatar: map['avatar'] != null ? map['avatar'] as String : null,
      isTwoFactorAuthenticationEnabled:
          map['isTwoFactorAuthenticationEnabled'] != null
              ? map['isTwoFactorAuthenticationEnabled'] as bool
              : null,
      twoFactorAuthenticationSecret:
          map['twoFactorAuthenticationSecret'] != null
              ? map['twoFactorAuthenticationSecret'] as String
              : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'User(id: $id, name: $name, password: $password, displayName: $displayName, status: $status, phone: $phone, email: $email, avatar: $avatar, isTwoFactorAuthenticationEnabled: $isTwoFactorAuthenticationEnabled, twoFactorAuthenticationSecret: $twoFactorAuthenticationSecret)';
  }

  @override
  bool operator ==(covariant User other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.password == password &&
        other.displayName == displayName &&
        other.status == status &&
        other.phone == phone &&
        other.email == email &&
        other.avatar == avatar &&
        other.isTwoFactorAuthenticationEnabled ==
            isTwoFactorAuthenticationEnabled &&
        other.twoFactorAuthenticationSecret == twoFactorAuthenticationSecret;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        password.hashCode ^
        displayName.hashCode ^
        status.hashCode ^
        phone.hashCode ^
        email.hashCode ^
        avatar.hashCode ^
        isTwoFactorAuthenticationEnabled.hashCode ^
        twoFactorAuthenticationSecret.hashCode;
  }
}
