import 'package:equatable/equatable.dart';
import '../../../domain/entities/api_user_entity.dart';

abstract class UsersState extends Equatable {
  const UsersState();

  @override
  List<Object?> get props => [];

  int? get currentPage => null;

  get users => null;
}

class UsersInitial extends UsersState {}

class UsersLoading extends UsersState {}

class UsersLoaded extends UsersState {
  @override
  final List<ApiUserEntity> users;
  @override
  final int currentPage;
  final int totalPages;
  final bool isLoadingMore;
  final bool hasReachedMax;

  const UsersLoaded({
    required this.users,
    required this.currentPage,
    required this.totalPages,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
  });

  UsersLoaded copyWith({
    List<ApiUserEntity>? users,
    int? currentPage,
    int? totalPages,
    bool? isLoadingMore,
    bool? hasReachedMax,
  }) {
    return UsersLoaded(
      users: users ?? this.users,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [users, currentPage, totalPages, isLoadingMore, hasReachedMax];
}

class UsersError extends UsersState {
  final String message;

  const UsersError(this.message);

  @override
  List<Object?> get props => [message];
}

class UsersOperationLoading extends UsersState {}

class UsersOperationSuccess extends UsersState {
  final String message;

  const UsersOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}