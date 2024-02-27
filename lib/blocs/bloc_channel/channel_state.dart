part of 'channel_cubit.dart';

@immutable
abstract class ChannelState extends Equatable {
  const ChannelState();
  @override
  List<Object> get props => [];
}

class ChannelInitial extends ChannelState {}

class ChannelLoading extends ChannelState {}

class GetAllChannelsLoaded extends ChannelState {
  final List<Channel> channels;
  const GetAllChannelsLoaded({required this.channels});
  @override
  List<Object> get props => [channels];
}

class GetChannelLoaded extends ChannelState {
  final Channel channel;
  const GetChannelLoaded({required this.channel});
  @override
  List<Object> get props => [channel];
}

class DeteteChannelLoaded extends ChannelState {}

class DeleteUserOfChannelLoaded extends ChannelState {}

class UpdateRoleUserOfChannelLoaded extends ChannelState {}

class LeaveChannelLoaded extends ChannelState {}

class AddUserToChannelLoaded extends ChannelState {}

class CreateChannelLoaded extends ChannelState {}

class UpdateChannelLoaded extends ChannelState {}

class NumberError extends ChannelState {
  final String message;
  const NumberError({required this.message});
  @override
  List<Object> get props => [message];
}
