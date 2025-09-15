import '../entities/api_user_entity.dart';

class UsersListResult {
  final List<ApiUserEntity> users;
  final int totalPages;
  final int currentPage;
  final int totalUsers;

  UsersListResult({
    required this.users,
    required this.totalPages,
    required this.currentPage,
    required this.totalUsers,
  });
}

abstract class ApiUsersRepository {
  Future<UsersListResult> getUsers(int page);
  Future<ApiUserEntity> getUserById(int id);
  Future<ApiUserEntity> createUser(ApiUserEntity user);
  Future<ApiUserEntity> updateUser(ApiUserEntity user);
  Future<void> deleteUser(int id);
}