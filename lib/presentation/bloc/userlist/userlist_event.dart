import 'package:equatable/equatable.dart';
import '../../../domain/entities/api_user_entity.dart';

abstract class UsersEvent extends Equatable {
  const UsersEvent();

  @override
  List<Object?> get props => [];
}

class LoadUsersEvent extends UsersEvent {
  final int page;
  final bool isRefresh;

  const LoadUsersEvent({this.page = 1, this.isRefresh = false});

  @override
  List<Object?> get props => [page, isRefresh];
}

class LoadMoreUsersEvent extends UsersEvent {}

class CreateUserEvent extends UsersEvent {
  final ApiUserEntity user;

  const CreateUserEvent(this.user);

  @override
  List<Object?> get props => [user];
}

class UpdateUserEvent extends UsersEvent {
  final ApiUserEntity user;

  const UpdateUserEvent(this.user);

  @override
  List<Object?> get props => [user];
}

class DeleteUserEvent extends UsersEvent {
  final int userId;

  const DeleteUserEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}