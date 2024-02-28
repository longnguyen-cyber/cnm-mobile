part of 'chat_cubit.dart';

@immutable
abstract class ChatState extends Equatable {
  const ChatState();
  @override
  List<Object> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class GetAllChatsLoaded extends ChatState {
  final List<Chat> chats;
  const GetAllChatsLoaded({required this.chats});
  @override
  List<Object> get props => [chats];
}

class GetChatLoaded extends ChatState {
  final Chat chat;
  const GetChatLoaded({required this.chat});
  @override
  List<Object> get props => [chat];
}

class CreateChatLoaded extends ChatState {
  final Chat chat;
  const CreateChatLoaded({required this.chat});
  @override
  List<Object> get props => [chat];
}

class ReqAddFriendLoaded extends ChatState {}

class AcceptAddFriendLoaded extends ChatState {}

class DeleteFriendLoaded extends ChatState {}

class DeleteChatLoaded extends ChatState {}

class WhitelistFriendAcceptLoaded extends ChatState {}

class WaitlistFriendAcceptLoaded extends ChatState {}

class UnfriendLoaded extends ChatState {}

class NumberError extends ChatState {
  final String message;
  const NumberError({required this.message});
  @override
  List<Object> get props => [message];
}
