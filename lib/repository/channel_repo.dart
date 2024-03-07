import 'package:shared_preferences/shared_preferences.dart';
import 'package:zalo_app/model/channel.model.dart';
import 'package:zalo_app/model/common.model.dart';
import 'package:zalo_app/services/channel_service.dart';

class ChannelRepository {
  const ChannelRepository({
    required this.channelService,
  });
  final ChannelService channelService;

  Future<List<Channel>> getAllChannels() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token')!;
    var response = await channelService.getAllChannels(token);
    if (response != null) {
      return (response.data["data"] as List)
          .map((e) => Channel.fromMap(e))
          .toList();
    }
    return [];
  }

  Future<Channel?> getChannel(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token')!;

    var response = await channelService.getChannel(id, token);
    if (response != null) {
      var data = response.data["data"];

      return Channel.fromMap(data);
    }
    return null;
  }

  Future<void> deteteChannel(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token')!;
    await channelService.deteteChannel(id, token);
  }

  Future<void> deleteUserOfChannel(String id, List<String> users) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token')!;
    await channelService.deleteUserOfChannel(id, users, token);
  }

  Future<void> updateRoleUserOfChannel(
      String id, String userId, String role) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token')!;
    await channelService.updateRoleUserOfChannel(id, userId, role, token);
  }

  Future<void> leaveChannel(String id, String transferOwner) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token')!;
    await channelService.leaveChannel(id, transferOwner, token);
  }

  Future<void> addUserToChannel(String id, List<RoleUser> users) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token')!;
    await channelService.addUserToChannel(id, users, token);
  }

  Future<Channel?> createChannel(
      String name, bool isPublic, List<String> members) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token')!;

    var response = await channelService.createChannel({
      "name": name,
      "isPublic": isPublic,
      "members": members,
    }, token);
    if (response != null) {
      return Channel.fromMap(response.data);
    }

    return null;
  }

  Future<Channel?> updateChannel(String id, Object obj) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token')!;
    var response = await channelService.updateChannel(id, obj, token);
    if (response != null) {
      return Channel.fromMap(response.data);
    }
    return null;
  }
}
