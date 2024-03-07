part of 'friend_cubit.dart';

@immutable
abstract class FriendState extends Equatable {
  const FriendState();
  @override
  List<Object> get props => [];
  List<Object> get waiting => [];
  Object? get prop => null;
}

class FriendInitial extends FriendState {}

class FriendWaitInitial extends FriendState {}

class FriendLoading extends FriendState {}

class ReqAddFriendLoaded extends FriendState {}

class AcceptAddFriendLoaded extends FriendState {}

class DeleteFriendLoaded extends FriendState {}

class DeleteChatLoaded extends FriendState {}

class FriendChatWaittingAccept extends FriendState {
  final Chat chat;
  const FriendChatWaittingAccept({required this.chat});
  @override
  List<Object> get props => [];
  @override
  Object? get prop => chat;
}

class WhitelistFriendAcceptLoaded extends FriendState {
  final List<Chat> chats;
  const WhitelistFriendAcceptLoaded({required this.chats});
  @override
  List<Object> get props => [chats];
}

class WaitlistFriendAcceptLoaded extends FriendState {
  final List<Chat> wattings;
  const WaitlistFriendAcceptLoaded({required this.wattings});
  @override
  List<Object> get waiting => [wattings];
}

class UnfriendLoaded extends FriendState {}

class NumberError extends FriendState {
  final String message;
  const NumberError({required this.message});
  @override
  List<Object> get props => [message];
}
