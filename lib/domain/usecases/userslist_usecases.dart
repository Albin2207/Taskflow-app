import '../entities/api_user_entity.dart';
import '../repositories/api_user_repositories.dart';

// Get Users UseCase
class GetUsersUseCase {
  final ApiUsersRepository _repository;

  GetUsersUseCase(this._repository);

  Future<UsersListResult> call(int page) async {
    return await _repository.getUsers(page);
  }
}

// Get User by ID UseCase
class GetUserByIdUseCase {
  final ApiUsersRepository _repository;

  GetUserByIdUseCase(this._repository);

  Future<ApiUserEntity> call(int id) async {
    return await _repository.getUserById(id);
  }
}

// Create User UseCase
class CreateUserUseCase {
  final ApiUsersRepository _repository;

  CreateUserUseCase(this._repository);

  Future<ApiUserEntity> call(ApiUserEntity user) async {
    return await _repository.createUser(user);
  }
}

// Update User UseCase
class UpdateUserUseCase {
  final ApiUsersRepository _repository;

  UpdateUserUseCase(this._repository);

  Future<ApiUserEntity> call(ApiUserEntity user) async {
    return await _repository.updateUser(user);
  }
}

// Delete User UseCase
class DeleteUserUseCase {
  final ApiUsersRepository _repository;

  DeleteUserUseCase(this._repository);

  Future<void> call(int id) async {
    await _repository.deleteUser(id);
  }
}