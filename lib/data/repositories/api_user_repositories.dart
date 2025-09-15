import '../../domain/entities/api_user_entity.dart';
import '../../domain/repositories/api_user_repositories.dart';
import '../database/services/api_service.dart';
import '../models/api_user_model.dart';


class ApiUsersRepositoryImpl implements ApiUsersRepository {
  final ApiDataSource _apiDataSource;

  ApiUsersRepositoryImpl(this._apiDataSource);

  @override
  Future<UsersListResult> getUsers(int page) async {
    final response = await _apiDataSource.getUsers(page);
    return UsersListResult(
      users: response.users,
      totalPages: response.totalPages,
      currentPage: response.currentPage,
      totalUsers: response.totalUsers,
    );
  }

  @override
  Future<ApiUserEntity> getUserById(int id) async {
    return await _apiDataSource.getUserById(id);
  }

  @override
  Future<ApiUserEntity> createUser(ApiUserEntity user) async {
    final userModel = ApiUserModel(
      id: user.id,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      avatar: user.avatar,
    );
    return await _apiDataSource.createUser(userModel);
  }

  @override
  Future<ApiUserEntity> updateUser(ApiUserEntity user) async {
    final userModel = ApiUserModel(
      id: user.id,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      avatar: user.avatar,
    );
    return await _apiDataSource.updateUser(userModel);
  }

  @override
  Future<void> deleteUser(int id) async {
    await _apiDataSource.deleteUser(id);
  }
}