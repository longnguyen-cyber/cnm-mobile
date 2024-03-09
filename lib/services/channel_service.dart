import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:zalo_app/model/common.model.dart';

class ChannelService {
  final Dio _dio = Dio();
  var baseUrl = dotenv.env['API_URL'];

  Future<Response?> getAllChannels(String token) async {
    String url = "$baseUrl/channels";
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

  Future<Response?> getChannel(String id, String token) async {
    String url = "$baseUrl/channels/$id";
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

  Future<Response?> deteteChannel(String id, String token) async {
    String url = "$baseUrl/channels/$id";
    final response = await _dio.delete(
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

  Future<Response?> deleteUserOfChannel(
      String channelId, List<String> users, String token) async {
    String url = "$baseUrl/channels/$channelId/remove-user";
    final response = await _dio.delete(
      url,
      data: {"users": users},
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

  Future<Response?> updateRoleUserOfChannel(
      String channelId, String userId, String role, String token) async {
    String url = "$baseUrl/channels/$channelId/update-role";
    final response = await _dio.put(
      url,
      data: {"id": userId, "role": role},
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

  Future<Response?> leaveChannel(
      String channelId, String transferOwner, String token) async {
    String url = "$baseUrl/channels/$channelId/leave";
    final response = await _dio.put(
      url,
      data: {"transferOwner": transferOwner != "" ? transferOwner : null},
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

  Future<Response?> addUserToChannel(
      String channelId, List<RoleUser> users, String token) async {
    String url = "$baseUrl/channels/$channelId/user";
    final response = await _dio.post(
      url,
      data: users,
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

  Future<Response?> createChannel(
      Map<String, dynamic> data, String token) async {
    String url = "$baseUrl/channels";
    final response = await _dio.post(
      url,
      data: data,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );
    print(response.data);
    try {
      return response;
    } catch (e) {
      if (kDebugMode) {
        print("Error :$e");
      }
    }
    return null;
  }

  Future<Response?> updateChannel(String id, Object obj, String token) async {
    String url = "$baseUrl/channels/$id";
    final response = await _dio.put(
      url,
      data: obj,
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
