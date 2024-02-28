import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zalo_app/model/chat.model.dart';
import 'package:zalo_app/repository/chat_repo.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository chatRepo;

  ChatCubit({required this.chatRepo}) : super(ChatInitial());

  Future<void> getAllChats() async {
    try {
      var chats = await chatRepo.getAllChats();
      emit(GetAllChatsLoaded(chats: chats));
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<void> getChat(String id) async {
    try {
      var chat = await chatRepo.getChat(id);
      emit(GetChatLoaded(chat: chat!));
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<void> createChat(String receiveId) async {
    try {
      var chat = await chatRepo.createChat(receiveId);
      emit(CreateChatLoaded(chat: chat!));
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<void> reqAddFriend(String id, String receiveId) async {
    try {
      await chatRepo.reqAddFriend(id, receiveId);
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
      await chatRepo.whitelistFriendAccept();
      emit(WhitelistFriendAcceptLoaded());
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<void> waitlistFriendAccept() async {
    try {
      await chatRepo.waitlistFriendAccept();
      emit(WaitlistFriendAcceptLoaded());
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
