import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class API {
  final Dio _dio = Dio();
  var baseUrl = dotenv.env['API_URL'];

  get(String url, dynamic data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token") ?? "";
    final response = await _dio
        .get(
      "$baseUrl/$url",
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    )
        .onError((error, stackTrace) {
      if (kDebugMode) {
        print("Error :$error");
      }
      return Future.value(Response(
        requestOptions: RequestOptions(path: url),
        statusCode: 500,
      ));
    });
    try {
      return response.data;
    } catch (e) {
      if (kDebugMode) {
        print("Error :$e");
      }
    }
    return null;
  }

  post(String url, dynamic data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token") ?? "";
    try {
      final response = await _dio.post(
        "$baseUrl/$url",
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return response.data;
    } catch (error) {
      if (kDebugMode) {
        print("Error :$error");
        final errorResponse = Response(
          requestOptions: RequestOptions(path: url),
          statusCode: 500,
        );
        print(errorResponse);
      }
    }
  }
}
