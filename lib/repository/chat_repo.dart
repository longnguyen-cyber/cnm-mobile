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
      return (response.data["data"] as List)
          .map((e) => Chat.fromMap(e))
          .toList();
    }
    return [];
  }

  Future<Chat?> getChat(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token')!;
    var response = await chatService.getChat(id, token);
    if (response != null) {
      return Chat.fromMap(response.data["data"]);
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

  Future<bool> reqAddFriend(String receiveId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token')!;
    var response = await chatService.reqAddfriend(receiveId, token);
    if (response != null) {
      return response.data["status"] == 200;
    }
    return false;
  }

  Future<bool> unReqAddFriend(String chatId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token')!;
    var response = await chatService.unReqAddFriend(chatId, token);
    if (response != null) {
      return response.data["status"] == 200;
    }
    return false;
  }

  Future<Chat?> getFriendChatWaittingAccept(String receiveId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token')!;
    var response =
        await chatService.getFriendChatWaittingAccept(receiveId, token);
    if (response != null) {
      return Chat.fromMap(response.data["data"]);
    }
    return null;
  }

  Future<void> reqAddFriendHaveChat(String id, String receiveId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token')!;
    await chatService.reqAddFriendHaveChat(id, receiveId, token);
  }

  Future<void> acceptAddFriend(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token')!;
    await chatService.acceptAddFriend(id, token);
  }

  Future<List<Chat>> whitelistFriendAccept() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token')!;
    var response = await chatService.whitelistFriendAccept(token);
    if (response != null) {
      return (response.data["data"] as List)
          .map((e) => Chat.fromMap(e))
          .toList();
    }
    return [];
  }

  Future<List<Chat>> waitlistFriendAccept() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token')!;
    var response = await chatService.waitlistFriendAccept(token);
    if (response != null) {
      return (response.data["data"] as List)
          .map((e) => Chat.fromMap(e))
          .toList();
    }
    return [];
  }

  Future<void> unfriend(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token')!;
    await chatService.unfriend(id, token);
  }
}
