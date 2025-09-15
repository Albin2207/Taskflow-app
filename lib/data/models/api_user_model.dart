import '../../domain/entities/api_user_entity.dart';

class ApiUserModel extends ApiUserEntity {
  const ApiUserModel({
    required super.id,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.avatar,
  });

  // Factory constructor for parsing reqres.in response format
  factory ApiUserModel.fromJson(Map<String, dynamic> json) {
    return ApiUserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      avatar: json['avatar'] as String,
    );
  }

  // Convert to JSON in reqres.in format
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'avatar': avatar,
    };
  }

  // Method specifically for create/update operations
  // reqres.in expects different format for write operations
  Map<String, dynamic> toJsonForCreate() {
    return {
      'name': '$firstName $lastName',
      'job': 'Developer', // reqres.in requires a job field
      // Note: reqres.in doesn't actually use first_name/last_name for create/update
      // but we can add them as additional fields
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'avatar': avatar,
    };
  }

  // Convert from domain entity to model
  factory ApiUserModel.fromEntity(ApiUserEntity entity) {
    return ApiUserModel(
      id: entity.id,
      email: entity.email,
      firstName: entity.firstName,
      lastName: entity.lastName,
      avatar: entity.avatar,
    );
  }

  // Create a copy with updated values
  ApiUserModel copyWith({
    int? id,
    String? email,
    String? firstName,
    String? lastName,
    String? avatar,
  }) {
    return ApiUserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatar: avatar ?? this.avatar,
    );
  }
}