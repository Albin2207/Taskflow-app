import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_user_case.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final GetUserUseCase getUserUseCase;

  UserBloc({required this.getUserUseCase}) : super(UserInitial()) {
    on<UserLoadRequested>(_onUserLoadRequested);
  }

  Future<void> _onUserLoadRequested(
    UserLoadRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final user = await getUserUseCase();
      if (user != null) {
        emit(UserLoaded(user));
      } else {
        emit(const UserError('No user found'));
      }
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}