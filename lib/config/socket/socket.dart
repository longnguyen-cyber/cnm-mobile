import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketConfig {
  static late io.Socket socket;

  //connect to the socket server
  static void connect(String token) {
    socket = io.io(
        dotenv.env["BASE_URL"]!,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .setAuth({
              'Authorization': 'Bearer $token'
            }) // set the authorization header
            .build());
    socket.connect();
    if (kDebugMode) {
      print('Connected to the socket server');
    }
  }

  //disconnect from the socket server
  static void disconnect() {
    socket.disconnect();
  }

  //listen to the socket server
  static void listen(String event, Function callback) {
    socket.on(event, (data) {
      callback(data);
    });
  }

  //emit to the socket server
  static void emit(String event, dynamic data) {
    socket.emit(event, data);
  }

  //close the socket connection
  static void close() {
    socket.close();
  }
}
