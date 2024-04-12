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
}
