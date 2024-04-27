import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:http_parser/http_parser.dart';

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

  put(String url, dynamic data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token") ?? "";
    try {
      final response = await _dio.put(
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

      print(response);
      return response.data;
    } catch (error) {
      if (error is DioError) {
        // Here's the error message
        print("Dio error: ${error.message}");

        // Here's the error response data
        print("Dio error response data: ${error.response?.data}");

        // Here's the request that caused the error
        print("Dio error request: ${error.requestOptions.path}");

        // Handle the error
        if (error.response?.statusCode == 400) {
          return {"status": 400};
          // Handle 400 error
        } else if (error.response?.statusCode == 500) {
          // Handle 500 error
        }
      } else if (kDebugMode) {
        print("Error :$error");
        final errorResponse = Response(
          requestOptions: RequestOptions(path: url),
          statusCode: 500,
        );
        print(errorResponse);
        return errorResponse;
      }
    }
  }

  String convertToSize(int bytes) {
    double kb = bytes / 1024;
    if (kb > 1024) {
      double mb = kb / 1024;
      if (mb > 1024) {
        double gb = mb / 1024;
        return '${gb.toStringAsFixed(2)} GB';
      }
      return '${mb.toStringAsFixed(2)} MB';
    } else {
      return '${kb.toStringAsFixed(2)} KB';
    }
  }

  uploadFiles(List<PlatformFile> files) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token") ?? "";
    var formData = FormData();
    //fileName, size, path
    dynamic filesData = [];

    for (var file in files) {
      if (file.readStream != null) {
        List<int> bytes = await file.readStream!.toBytes();
        String extension = file.name.split(".").last;
        filesData.add({
          "filename": file.name,
          "size": file.size,
          "path": "",
        });
        formData.files.add(
          MapEntry(
            "files",
            MultipartFile.fromBytes(
              bytes,
              filename: file.name,
              contentType: MediaType("File", extension),
            ),
          ),
        );
      }
    }

    final response = await _dio.post(
      "$baseUrl/upload",
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );
    if (response.data["status"] == 400) {
      return null;
    }
    if (response.data != null) {
      for (var file in response.data["data"]) {
        for (var element in filesData) {
          if (element["filename"] == file["filename"]) {
            element["path"] = file["path"];
            element["size"] = file["size"];
          }
        }
      }
    }

    return filesData;
  }

  uploadFile(dynamic data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token") ?? "";
    var formData = FormData();
    formData.files.add(
      MapEntry(
        "file",
        MultipartFile.fromBytes(
          data["bytes"],
          filename: data["filename"],
          contentType: MediaType("File", data["extension"]),
        ),
      ),
    );

    final response = await _dio.post(
      "$baseUrl/upload/single",
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );
    return {
      "filename": response.data["data"]["filename"],
      "path": response.data["data"]["path"],
      "size": response.data["data"]["size"],
    };
  }
}
