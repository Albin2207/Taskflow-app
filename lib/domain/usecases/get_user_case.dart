import '../entities/user_entity.dart';
import '../repositories/auth_repositories.dart';
import '../repositories/user_repositories.dart';


class GetUserUseCase {
  final UserRepository _userRepository;
  final AuthRepository _authRepository;

  GetUserUseCase(this._userRepository, this._authRepository);

  Future<UserEntity?> call() async {
    try {
      final currentUser = await _authRepository.getCurrentUser();
      if (currentUser != null) {
        // First try to get from local database
        final localUser = await _userRepository.getUser(currentUser.uid);
        return localUser ?? currentUser;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: ${e.toString()}');
    }
  }
}