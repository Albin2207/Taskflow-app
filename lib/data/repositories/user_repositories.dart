import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repositories.dart';
import '../database/local/user_database.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final LocalUserDataSource _localUserDataSource;

  UserRepositoryImpl(this._localUserDataSource);

  @override
  Future<void> saveUser(UserEntity user) async {
    final userModel = UserModel.fromEntity(user);
    await _localUserDataSource.saveUser(userModel);
  }

  @override
  Future<UserEntity?> getUser(String uid) async {
    return await _localUserDataSource.getUser(uid);
  }

  @override
  Future<void> deleteUser(String uid) async {
    await _localUserDataSource.deleteUser(uid);
  }

  @override
  Future<bool> userExists(String uid) async {
    return await _localUserDataSource.userExists(uid);
  }
}