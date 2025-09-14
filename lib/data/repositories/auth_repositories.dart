import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repositories.dart';
import '../database/services/firebase_auth_service.dart';


class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _firebaseAuthDataSource;

  AuthRepositoryImpl(this._firebaseAuthDataSource);

  @override
  Future<UserEntity?> signInWithGoogle() async {
    return await _firebaseAuthDataSource.signInWithGoogle();
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuthDataSource.signOut();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    return await _firebaseAuthDataSource.getCurrentUser();
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _firebaseAuthDataSource.authStateChanges;
  }
}