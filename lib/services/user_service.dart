import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// user:
// -login
// -2fa/generate
// -2fa/turn-on
// -2fa/authenticate
// -register
// -getUser
// -updateUser
// -searchUser
class UserService {
  final Dio _dio = Dio();
  var baseUrl = dotenv.env['API_URL'];

  Future<Response?> login(String email, String password) async {
    String url = "$baseUrl/users/login";

    final response = await _dio.post(url, data: {
      "email": email,
      "password": password,
    }).onError((error, stackTrace) {
      if (kDebugMode) {
        print("Error :$error");
      }
      return Future.value(Response(
        requestOptions: RequestOptions(path: url),
        statusCode: 500,
      ));
    });

    try {
      return response;
    } catch (e) {
      if (kDebugMode) {
        print("Error :$e");
      }
    }
    return null;
  }

  Future<Response?> register(String email, String password, String name) async {
    String url = "http://localhost:8080/api/users/register";

    final response = await _dio.post(url, data: {
      "name": name,
      "email": email,
      "password": password,
    });
    try {
      return response;
    } catch (e) {
      if (kDebugMode) {
        print("Error :$e");
      }
    }
    return null;
  }

  Future<Response?> twoFactorGenerate(String email) async {
    String url = "$baseUrl/users/2fa/generate";
    final response = await _dio.post(url, data: {
      "email": email,
    });
    try {
      return response;
    } catch (e) {
      if (kDebugMode) {
        print("Error :$e");
      }
    }
    return null;
  }

  Future<Response?> twoFactorTurnOn(String email, String code) async {
    String url = "$baseUrl/users/2fa/turn-on";
    final response = await _dio.post(url, data: {
      "email": email,
      "code": code,
    });
    try {
      return response;
    } catch (e) {
      if (kDebugMode) {
        print("Error :$e");
      }
    }
    return null;
  }

  Future<Response?> twoFactorAuthenticate(String email, String code) async {
    String url = "$baseUrl/users/2fa/authenticate";
    final response = await _dio.post(url, data: {
      "email": email,
      "code": code,
    });
    try {
      return response;
    } catch (e) {
      if (kDebugMode) {
        print("Error :$e");
      }
    }
    return null;
  }

  Future<Response?> getUser(String id, String token) async {
    String url = "$baseUrl/users/$id";
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

  Future<Response?> updateUser(Object obj, String token) async {
    String url = "$baseUrl/users/update";

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

  Future<Response?> searchUser(String name, String token) async {
    String url = "$baseUrl/users/search/$name";
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
}
