part of 'user_cubit.dart';

@immutable
abstract class UserState extends Equatable {
  const UserState();
  @override
  List<Object> get props => [];
}

class UserInitial extends UserState {}

class LoginLoading extends UserState {}

class LoginLoaded extends UserState {
  final User user;
  const LoginLoaded({required this.user});
  @override
  List<Object> get props => [user];
}

class NumberError extends UserState {
  final String message;
  const NumberError({required this.message});
  @override
  List<Object> get props => [message];
}
