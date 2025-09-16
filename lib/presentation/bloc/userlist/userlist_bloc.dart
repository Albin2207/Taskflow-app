import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/userslist_usecases.dart';
import '../notification/notification_bloc.dart';
import 'userlist_event.dart';
import 'userlist_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final GetUsersUseCase _getUsersUseCase;
  final CreateUserUseCase _createUserUseCase;
  final UpdateUserUseCase _updateUserUseCase;
  final DeleteUserUseCase _deleteUserUseCase;
  final NotificationBloc? _notificationBloc; // Optional for notifications

  UsersBloc({
    required GetUsersUseCase getUsersUseCase,
    required CreateUserUseCase createUserUseCase,
    required UpdateUserUseCase updateUserUseCase,
    required DeleteUserUseCase deleteUserUseCase,
    NotificationBloc? notificationBloc, // Optional parameter
  }) : _getUsersUseCase = getUsersUseCase,
       _createUserUseCase = createUserUseCase,
       _updateUserUseCase = updateUserUseCase,
       _deleteUserUseCase = deleteUserUseCase,
       _notificationBloc = notificationBloc,
       super(UsersInitial()) {
    on<LoadUsersEvent>(_onLoadUsers);
    on<LoadMoreUsersEvent>(_onLoadMoreUsers);
    on<CreateUserEvent>(_onCreateUser);
    on<UpdateUserEvent>(_onUpdateUser);
    on<DeleteUserEvent>(_onDeleteUser);
  }

  Future<void> _onLoadUsers(
    LoadUsersEvent event,
    Emitter<UsersState> emit,
  ) async {
    try {
      if (event.isRefresh && state is UsersLoaded) {
        final currentState = state as UsersLoaded;
        emit(currentState.copyWith(isLoadingMore: false));
      } else {
        emit(UsersLoading());
      }

      final result = await _getUsersUseCase(event.page);

      emit(
        UsersLoaded(
          users: result.users,
          currentPage: result.currentPage,
          totalPages: result.totalPages,
          hasReachedMax: result.currentPage >= result.totalPages,
        ),
      );

      // Trigger sync notification if this is a refresh
      if (event.isRefresh) {
        _notificationBloc?.add(NotificationSendSync(result.users.length));
      }
    } catch (e) {
      String errorMessage = _parseErrorMessage(e.toString());
      emit(UsersError(errorMessage));
    }
  }

  Future<void> _onLoadMoreUsers(
    LoadMoreUsersEvent event,
    Emitter<UsersState> emit,
  ) async {
    if (state is! UsersLoaded) return;

    final currentState = state as UsersLoaded;

    if (currentState.hasReachedMax || currentState.isLoadingMore) return;

    try {
      emit(currentState.copyWith(isLoadingMore: true));

      final nextPage = currentState.currentPage + 1;
      final result = await _getUsersUseCase(nextPage);

      final allUsers = List.of(currentState.users)..addAll(result.users);

      emit(
        UsersLoaded(
          users: allUsers,
          currentPage: result.currentPage,
          totalPages: result.totalPages,
          hasReachedMax: result.currentPage >= result.totalPages,
        ),
      );
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
      String errorMessage = _parseErrorMessage(e.toString());
      emit(UsersError(errorMessage));
    }
  }

  Future<void> _onCreateUser(
    CreateUserEvent event,
    Emitter<UsersState> emit,
  ) async {
    if (state is! UsersLoaded) {
      return;
    }

    final currentState = state as UsersLoaded;

    try {
      emit(UsersOperationLoading());

      // Validate user data before sending to API
      if (event.user.firstName.trim().isEmpty ||
          event.user.lastName.trim().isEmpty) {
        emit(const UsersError('First name and last name are required'));
        return;
      }

      final createdUser = await _createUserUseCase(event.user);

      // Show success message first
      emit(const UsersOperationSuccess('User created successfully'));

      // Trigger notification
      _notificationBloc?.add(NotificationSendUserCreated(createdUser.fullName));

      // Small delay to show the success message
      await Future.delayed(const Duration(milliseconds: 500));

      // OPTIMISTIC UPDATE: Add the new user to the current list and emit final state
      final updatedUsers = List.of(currentState.users)..add(createdUser);

      emit(
        UsersLoaded(
          users: updatedUsers,
          currentPage: currentState.currentPage,
          totalPages: currentState.totalPages,
          hasReachedMax: currentState.hasReachedMax,
        ),
      );
    } catch (e) {
      String errorMessage = _parseErrorMessage(e.toString());

      // Handle specific reqres.in errors
      if (errorMessage.contains('400')) {
        emit(const UsersError('Invalid user data. Please check all fields.'));
      } else if (errorMessage.contains('connection') ||
          errorMessage.contains('timeout')) {
        emit(
          const UsersError(
            'Connection error. Please check your internet connection.',
          ),
        );
      } else {
        emit(UsersError('Failed to create user: $errorMessage'));
      }
    }
  }

  Future<void> _onUpdateUser(
    UpdateUserEvent event,
    Emitter<UsersState> emit,
  ) async {
    // ignore: avoid_print
    print(
      '=== USER: ${event.user.firstName} ${event.user.lastName} ID: ${event.user.id} ===',
    );
    // ignore: avoid_print
    print('=== CURRENT STATE: ${state.runtimeType} ===');

    if (state is! UsersLoaded) {
      return;
    }

    final currentState = state as UsersLoaded;

    try {
      emit(UsersOperationLoading());

      // Validate user data before sending to API
      if (event.user.firstName.trim().isEmpty ||
          event.user.lastName.trim().isEmpty) {
        emit(const UsersError('First name and last name are required'));
        return;
      }

      await _updateUserUseCase(event.user);

      // Show success message first
      emit(const UsersOperationSuccess('User updated successfully'));

      // Trigger notification
      _notificationBloc?.add(NotificationSendUserUpdated(event.user.fullName));

      // Small delay to show the success message
      await Future.delayed(const Duration(milliseconds: 500));

      // OPTIMISTIC UPDATE: Update the user in the current list
      final updatedUsers =
          currentState.users.map((user) {
            if (user.id == event.user.id) {
              // ignore: avoid_print
              print(
                '=== FOUND USER TO UPDATE: ${user.id} -> ${event.user.firstName} ${event.user.lastName} ===',
              );
              return event.user;
            }
            return user;
          }).toList();

      // ignore: avoid_print
      print('=== UPDATED USERS LIST LENGTH: ${updatedUsers.length} ===');

      emit(
        UsersLoaded(
          users: updatedUsers,
          currentPage: currentState.currentPage,
          totalPages: currentState.totalPages,
          hasReachedMax: currentState.hasReachedMax,
        ),
      );
    } catch (e) {
      String errorMessage = _parseErrorMessage(e.toString());

      // Handle specific reqres.in errors
      if (errorMessage.contains('404')) {
        emit(const UsersError('User not found. It may have been deleted.'));
      } else if (errorMessage.contains('400')) {
        emit(const UsersError('Invalid user data. Please check all fields.'));
      } else if (errorMessage.contains('connection') ||
          errorMessage.contains('timeout')) {
        emit(
          const UsersError(
            'Connection error. Please check your internet connection.',
          ),
        );
      } else {
        emit(UsersError('Failed to update user: $errorMessage'));
      }
    }
  }

  Future<void> _onDeleteUser(
    DeleteUserEvent event,
    Emitter<UsersState> emit,
  ) async {
    if (state is! UsersLoaded) return;

    final currentState = state as UsersLoaded;

    // Find the user name before deletion for notification
    final userToDelete = currentState.users.firstWhere(
      (user) => user.id == event.userId,
      orElse: () => throw Exception('User not found'),
    );

    try {
      emit(UsersOperationLoading());

      await _deleteUserUseCase(event.userId);

      // Show success message first
      emit(const UsersOperationSuccess('User deleted successfully'));

      // Trigger notification
      _notificationBloc?.add(
        NotificationSendUserDeleted(userToDelete.fullName),
      );

      // Small delay to show the success message
      await Future.delayed(const Duration(milliseconds: 500));

      // OPTIMISTIC UPDATE: Remove the user from the current list
      final updatedUsers =
          currentState.users.where((user) => user.id != event.userId).toList();

      emit(
        UsersLoaded(
          users: updatedUsers,
          currentPage: currentState.currentPage,
          totalPages: currentState.totalPages,
          hasReachedMax: currentState.hasReachedMax,
        ),
      );
    } catch (e) {
      String errorMessage = _parseErrorMessage(e.toString());

      // Handle specific reqres.in errors
      if (errorMessage.contains('404')) {
        emit(const UsersError('User not found. It may already be deleted.'));
      } else if (errorMessage.contains('connection') ||
          errorMessage.contains('timeout')) {
        emit(
          const UsersError(
            'Connection error. Please check your internet connection.',
          ),
        );
      } else {
        emit(UsersError('Failed to delete user: $errorMessage'));
      }
    }
  }

  String _parseErrorMessage(String error) {
    // Clean up error messages for better user experience
    if (error.contains('SocketException') ||
        error.contains('Network is unreachable')) {
      return 'No internet connection';
    } else if (error.contains('Connection timeout')) {
      return 'Connection timeout. Please try again.';
    } else if (error.contains('Bad request')) {
      return 'Invalid data provided';
    } else if (error.contains('Unauthorized')) {
      return 'Authentication required';
    } else if (error.contains('Forbidden')) {
      return 'Access denied';
    } else if (error.contains('Not found')) {
      return 'Resource not found';
    } else if (error.contains('Internal server error')) {
      return 'Server error. Please try again later.';
    }

    // Return a cleaned version of the original error
    return error.replaceFirst('Exception: ', '').replaceFirst('Failed to ', '');
  }
}
