import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// chat:
// -getChats
// -getChat
// -createChat
// -reqAddFriend
// -acceptAddFriend
// -whitelistFriendAccept
// -waitlistFriendAccept
// -unfriend
class ChatService {
  final Dio _dio = Dio();
  var baseUrl = dotenv.env['API_URL'];

  Future<Response?> getChats(String token) async {
    String url = "$baseUrl/chats";
    final response = await _dio.get(
      url,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );
    try {
      return response;
    } catch (e) {
      if (kDebugMode) {
        print("Error :$e");
      }
    }
    return null;
  }

  Future<Response?> getChat(String id, String token) async {
    String url = "$baseUrl/chats/$id";
    final response = await _dio.get(
      url,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );
    try {
      return response;
    } catch (e) {
      if (kDebugMode) {
        print("Error :$e");
      }
    }
    return null;
  }

  Future<Response?> createChat(String receiveId, String token) async {
    String url = "$baseUrl/chats";
    final response = await _dio.post(
      url,
      data: {
        "receiveId": receiveId,
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );
    try {
      return response;
    } catch (e) {
      if (kDebugMode) {
        print("Error :$e");
      }
    }
    return null;
  }

  Future<Response?> reqAddfriend(
      String id, String receiveId, String token) async {
    String url = "$baseUrl/chats/$id/reqAddFriend";
    final response = await _dio.put(
      url,
      data: {
        "receiveId": receiveId,
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );
    try {
      return response;
    } catch (e) {
      if (kDebugMode) {
        print("Error :$e");
      }
    }
    return null;
  }

  Future<Response?> acceptAddFriend(String id, String token) async {
    String url = "$baseUrl/chats/$id/acceptAddFriend";
    final response = await _dio.put(
      url,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );
    try {
      return response;
    } catch (e) {
      if (kDebugMode) {
        print("Error :$e");
      }
    }
    return null;
  }

  Future<Response?> whitelistFriendAccept(String token) async {
    String url = "$baseUrl/chats/friend/whitelistFriendAccept";
    final response = await _dio.get(
      url,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );
    try {
      return response;
    } catch (e) {
      if (kDebugMode) {
        print("Error :$e");
      }
    }
    return null;
  }

  Future<Response?> waitlistFriendAccept(String token) async {
    String url = "$baseUrl/chats/friend/waitlistFriendAccept";
    final response = await _dio.put(
      url,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );
    try {
      return response;
    } catch (e) {
      if (kDebugMode) {
        print("Error :$e");
      }
    }
    return null;
  }

  Future<Response?> unfriend(String id, String token) async {
    String url = "$baseUrl/chats/$id/unfriend";
    final response = await _dio.post(
      url,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );
    try {
      return response;
    } catch (e) {
      if (kDebugMode) {
        print("Error :$e");
      }
    }
    return null;
  }
}
