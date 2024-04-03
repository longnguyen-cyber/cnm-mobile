import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zalo_app/model/user.model.dart';
import 'package:zalo_app/repository/user_repo.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final UserRepository userRepo;

  UserCubit({required this.userRepo}) : super(UserInitial());

  Future<bool> login(String email, String password) async {
    try {
      var user = await userRepo.login(email, password);
      if (user != null) {
        emit(LoginLoaded(user: user));
        return true;
      } else {
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return false;
  }

  Future<void> register(
      {required String email,
      required String password,
      required String username}) async {
    try {
      var user = await userRepo.register(email, password, username);
      emit(LoginLoaded(user: user!));
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<User?> getUser(String id) async {
    try {
      var user = await userRepo.getUser(id);
      return user;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return null;
  }

  Future<List<User>> searchUser({required String name}) async {
    try {
      var users = await userRepo.searchUser(name);
      return users;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return [];
  }

  Future<User?> updateUser(Object obj) async {
    try {
      var user = await userRepo.updateUser(obj);
      emit(LoginLoaded(user: user!));
      return user;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return null;
  }

  Future<User?> twoFactorGenerate(String email) async {
    try {
      var user = await userRepo.twoFactorGenerate(email);
      return user;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return null;
  }

  Future<User?> twoFactorTurnOn(String email, String code) async {
    try {
      var user = await userRepo.twoFactorTurnOn(email, code);
      return user;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return null;
  }
}
