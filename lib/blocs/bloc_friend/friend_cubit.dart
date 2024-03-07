import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zalo_app/model/chat.model.dart';
import 'package:zalo_app/repository/chat_repo.dart';

part 'friend_state.dart';

class FriendCubit extends Cubit<FriendState> {
  final ChatRepository chatRepo;

  FriendCubit({required this.chatRepo}) : super(FriendInitial());

  Future<bool> reqAddFriend(String receiveId) async {
    try {
      var rs = await chatRepo.reqAddFriend(receiveId);
      return rs;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return false;
  }

  Future<bool> unReqAddFriend(String chatId) async {
    try {
      var rs = await chatRepo.unReqAddFriend(chatId);
      return rs;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return false;
  }

  Future<void> getFriendChatWaittingAccept(String receiveId) async {
    try {
      var friend = await chatRepo.getFriendChatWaittingAccept(receiveId);
      emit(FriendChatWaittingAccept(chat: friend!));
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<void> reqAddFriendHaveChat(String id, String receiveId) async {
    try {
      await chatRepo.reqAddFriendHaveChat(id, receiveId);
      emit(ReqAddFriendLoaded());
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<void> acceptAddFriend(String id) async {
    try {
      await chatRepo.acceptAddFriend(id);
      emit(AcceptAddFriendLoaded());
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<void> whitelistFriendAccept() async {
    try {
      var friends = await chatRepo.whitelistFriendAccept();
      emit(WhitelistFriendAcceptLoaded(chats: friends));
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<void> waitlistFriendAccept() async {
    try {
      var waitings = await chatRepo.waitlistFriendAccept();
      print("waitlist: $waitings");
      emit(WaitlistFriendAcceptLoaded(wattings: waitings));
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<void> unfriend(String id) async {
    try {
      await chatRepo.unfriend(id);
      emit(UnfriendLoaded());
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }
}
