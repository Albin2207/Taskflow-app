import '../entities/user_entity.dart';
import '../repositories/auth_repositories.dart';
import '../repositories/user_repositories.dart';

class SignInUseCase {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  SignInUseCase(this._authRepository, this._userRepository);

  Future<UserEntity?> call() async {
    try {
      final user = await _authRepository.signInWithGoogle();
      if (user != null) {
        // Save user to local database
        await _userRepository.saveUser(user);
      }
      return user;
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }
}