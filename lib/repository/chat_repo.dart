import 'package:shared_preferences/shared_preferences.dart';
import 'package:zalo_app/model/chat.model.dart';
import 'package:zalo_app/services/chat_service.dart';

class ChatRepository {
  const ChatRepository({
    required this.chatService,
  });
  final ChatService chatService;

  Future<List<Chat>> getAllChats() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token')!;
    var response = await chatService.getChats(token);
    if (response != null) {
      return (response.data as List).map((e) => Chat.fromJson(e)).toList();
    }
    return [];
  }

  Future<Chat?> getChat(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token')!;
    var response = await chatService.getChat(id, token);
    if (response != null) {
      return Chat.fromJson(response.data);
    }
    return null;
  }

  Future<Chat?> createChat(String receiveId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token')!;
    var response = await chatService.createChat(receiveId, token);
    if (response != null) {
      return Chat.fromJson(response.data);
    }
    return null;
  }

  Future<void> reqAddFriend(String id, String receiveId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token')!;
    await chatService.reqAddfriend(id, receiveId, token);
  }

  Future<void> acceptAddFriend(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token')!;
    await chatService.acceptAddFriend(id, token);
  }

  Future<void> whitelistFriendAccept() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token')!;
    await chatService.whitelistFriendAccept(token);
  }

  Future<void> waitlistFriendAccept() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token')!;
    await chatService.waitlistFriendAccept(token);
  }

  Future<void> unfriend(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token')!;
    await chatService.unfriend(id, token);
  }
}
