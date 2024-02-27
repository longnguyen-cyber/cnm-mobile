import 'package:zalo_app/model/channel.model.dart';

class RoleUser {
  int id;
  String role;

  RoleUser({required this.id, required this.role});
}

class CreateChannel extends Channel {
  final List<String> members;

  CreateChannel(
    this.members, {
    required super.name,
    required super.isPublic,
  });
}