import 'package:shared_preferences/shared_preferences.dart';
import 'package:zalo_app/config/socket/socket.dart';
import 'package:zalo_app/model/user.model.dart';
import 'package:zalo_app/services/user_service.dart';

class UserRepository {
  const UserRepository({
    required this.userService,
  });
  final UserService userService;

  //pass
  Future<User?> login(String email, String password) async {
    final Future<SharedPreferences> prefs0 = SharedPreferences.getInstance();
    final response = await userService.login(email, password);

    if (response != null) {
      User user = User.fromMap(response.data["data"]);
      final SharedPreferences prefs = await prefs0;
      prefs.setString("token", response.data["data"]["token"]);
      prefs.setString(response.data["data"]["token"], user.toJson());
      SocketConfig.connect(response.data["data"]["token"]);
      return user;
    } else {
      return null;
    }
  }

  //pass
  Future<User?> register(String email, String password, String name) async {
    final Future<SharedPreferences> prefs0 = SharedPreferences.getInstance();
    final response = await userService.register(email, password, name);
    if (response != null) {
      User user = User.fromMap(response.data["data"]);
      final SharedPreferences prefs = await prefs0;
      prefs.setString("token", response.data["data"]["token"]);
      return user;
    } else {
      return null;
    }
  }
}
