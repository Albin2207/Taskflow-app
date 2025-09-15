import 'package:dio/dio.dart';
import '../../models/api_user_model.dart';

class ApiUsersListResponse {
  final List<ApiUserModel> users;
  final int totalPages;
  final int currentPage;
  final int totalUsers;

  ApiUsersListResponse({
    required this.users,
    required this.totalPages,
    required this.currentPage,
    required this.totalUsers,
  });
}

abstract class ApiDataSource {
  Future<ApiUsersListResponse> getUsers(int page);
  Future<ApiUserModel> getUserById(int id);
  Future<ApiUserModel> createUser(ApiUserModel user);
  Future<ApiUserModel> updateUser(ApiUserModel user);
  Future<void> deleteUser(int id);
}

class ApiDataSourceImpl implements ApiDataSource {
  final Dio dio;

  ApiDataSourceImpl({required this.dio});

  @override
  Future<ApiUsersListResponse> getUsers(int page) async {
    try {
      final response = await dio.get('/users', queryParameters: {'page': page});
      
      final data = response.data;
      final usersJson = data['data'] as List;
      final users = usersJson.map((json) => ApiUserModel.fromJson(json)).toList();

      return ApiUsersListResponse(
        users: users,
        totalPages: data['total_pages'] as int,
        currentPage: data['page'] as int,
        totalUsers: data['total'] as int,
      );
    } on DioException catch (e) {
      throw Exception('Failed to fetch users: ${e.message}');
    }
  }

  @override
  Future<ApiUserModel> getUserById(int id) async {
    try {
      final response = await dio.get('/users/$id');
      final userData = response.data['data'];
      return ApiUserModel.fromJson(userData);
    } on DioException catch (e) {
      throw Exception('Failed to fetch user: ${e.message}');
    }
  }

  @override
  Future<ApiUserModel> createUser(ApiUserModel user) async {
    try {
      final response = await dio.post('/users', data: user.toJsonForCreate());
      
      // reqres.in returns the created user with an id
      final responseData = response.data;
      return ApiUserModel(
        id: int.tryParse(responseData['id'].toString()) ?? DateTime.now().millisecondsSinceEpoch,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        avatar: user.avatar,
      );
    } on DioException catch (e) {
      throw Exception('Failed to create user: ${e.message}');
    }
  }

  @override
  Future<ApiUserModel> updateUser(ApiUserModel user) async {
    try {
      final response = await dio.put('/users/${user.id}', data: user.toJsonForCreate());
      
      // Return the updated user
      return user;
    } on DioException catch (e) {
      throw Exception('Failed to update user: ${e.message}');
    }
  }

  @override
  Future<void> deleteUser(int id) async {
    try {
      await dio.delete('/users/$id');
    } on DioException catch (e) {
      throw Exception('Failed to delete user: ${e.message}');
    }
  }
}