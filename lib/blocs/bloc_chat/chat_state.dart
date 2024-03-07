part of 'chat_cubit.dart';

@immutable
abstract class ChatState extends Equatable {
  const ChatState();
  @override
  List<Object> get props => [];
  Object? get prop => null;
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
  Object get prop => chat;
}

class CreateChatLoaded extends ChatState {
  final Chat chat;
  const CreateChatLoaded({required this.chat});
  @override
  List<Object> get props => [chat];
}

class DeleteChatLoaded extends ChatState {}

class NumberError extends ChatState {
  final String message;
  const NumberError({required this.message});
  @override
  List<Object> get props => [message];
}
