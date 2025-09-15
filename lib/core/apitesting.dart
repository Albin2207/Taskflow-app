// // Add this test utility to help debug your API calls
// // You can call these methods from your UI temporarily to test

// import 'package:dio/dio.dart';
// import 'package:taskflow_app/data/models/api_user_model.dart' show ApiUserModel;


// class ApiTestUtility {
//   final Dio dio;

//   ApiTestUtility(this.dio);

//   Future<void> testAllEndpoints() async {
//     print('🧪 Starting API Tests for reqres.in');

//     try {
//       // Test GET users
//       await _testGetUsers();
      
//       // Test GET single user
//       await _testGetSingleUser();
      
//       // Test POST create user
//       await _testCreateUser();
      
//       // Test PUT update user
//       await _testUpdateUser();
      
//       // Test DELETE user
//       await _testDeleteUser();
      
//       print('✅ All API tests completed successfully!');
//     } catch (e) {
//       print('❌ API test failed: $e');
//     }
//   }

//   Future<void> _testGetUsers() async {
//     print('\n📝 Testing GET /users...');
//     try {
//       final response = await dio.get('/users?page=1');
//       print('✅ GET /users status: ${response.statusCode}');
//       print('📄 Response data keys: ${response.data.keys.toList()}');
      
//       final data = response.data['data'] as List;
//       print('👥 Found ${data.length} users');
//     } catch (e) {
//       print('❌ GET /users failed: $e');
//       rethrow;
//     }
//   }

//   Future<void> _testGetSingleUser() async {
//     print('\n📝 Testing GET /users/2...');
//     try {
//       final response = await dio.get('/users/2');
//       print('✅ GET /users/2 status: ${response.statusCode}');
//       print('📄 User data: ${response.data['data']}');
//     } catch (e) {
//       print('❌ GET /users/2 failed: $e');
//       rethrow;
//     }
//   }

//   Future<void> _testCreateUser() async {
//     print('\n📝 Testing POST /users...');
//     try {
//       final testUserData = {
//         'name': 'John Test',
//         'job': 'Developer',
//       };
      
//       final response = await dio.post(
//         '/users',
//         data: testUserData,
//         options: Options(
//           headers: {
//             'Content-Type': 'application/json',
//             'Accept': 'application/json',
//           },
//         ),
//       );
      
//       print('✅ POST /users status: ${response.statusCode}');
//       print('📄 Created user response: ${response.data}');
      
//       if (response.data.containsKey('id')) {
//         print('🎉 User created with ID: ${response.data['id']}');
//       }
//     } catch (e) {
//       print('❌ POST /users failed: $e');
//       if (e is DioException) {
//         print('📊 Status Code: ${e.response?.statusCode}');
//         print('📄 Error Response: ${e.response?.data}');
//       }
//       rethrow;
//     }
//   }

//   Future<void> _testUpdateUser() async {
//     print('\n📝 Testing PUT /users/2...');
//     try {
//       final testUserData = {
//         'name': 'John Updated',
//         'job': 'Senior Developer',
//       };
      
//       final response = await dio.put(
//         '/users/2',
//         data: testUserData,
//         options: Options(
//           headers: {
//             'Content-Type': 'application/json',
//             'Accept': 'application/json',
//           },
//         ),
//       );
      
//       print('✅ PUT /users/2 status: ${response.statusCode}');
//       print('📄 Updated user response: ${response.data}');
      
//       if (response.data.containsKey('updatedAt')) {
//         print('🎉 User updated at: ${response.data['updatedAt']}');
//       }
//     } catch (e) {
//       print('❌ PUT /users/2 failed: $e');
//       if (e is DioException) {
//         print('📊 Status Code: ${e.response?.statusCode}');
//         print('📄 Error Response: ${e.response?.data}');
//       }
//       rethrow;
//     }
//   }

//   Future<void> _testDeleteUser() async {
//     print('\n📝 Testing DELETE /users/2...');
//     try {
//       final response = await dio.delete(
//         '/users/2',
//         options: Options(
//           headers: {
//             'Content-Type': 'application/json',
//             'Accept': 'application/json',
//           },
//         ),
//       );
      
//       print('✅ DELETE /users/2 status: ${response.statusCode}');
      
//       if (response.statusCode == 204) {
//         print('🎉 User deleted successfully (204 No Content)');
//       } else {
//         print('📄 Delete response: ${response.data}');
//       }
//     } catch (e) {
//       print('❌ DELETE /users/2 failed: $e');
//       if (e is DioException) {
//         print('📊 Status Code: ${e.response?.statusCode}');
//         print('📄 Error Response: ${e.response?.data}');
//       }
//       rethrow;
//     }
//   }

//   // Method to test with your actual user models
//   Future<void> testWithUserModels() async {
//     print('\n Testing with ApiUserModel...');
    
//     try {
//       // Create a test user
//       final testUser = ApiUserModel(
//         id: 0, // Will be assigned by API
//         firstName: 'Test',
//         lastName: 'User',
//         email: 'test.user@example.com',
//         avatar: 'https://reqres.in/img/faces/1-image.jpg',
//       );

//       // Test create
//       final createData = testUser.toJsonForCreate();
//       print('Create payload: $createData');
      
//       final createResponse = await dio.post('/users', data: createData);
//       print('Create response: ${createResponse.data}');
      
//     } catch (e) {
//       print('Model test failed: $e');
//       rethrow;
//     }
//   }
// }