import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
}
