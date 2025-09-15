import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

// Add this screen temporarily to test your API calls
class ApiDebugScreen extends StatefulWidget {
  const ApiDebugScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ApiDebugScreenState createState() => _ApiDebugScreenState();
}

class _ApiDebugScreenState extends State<ApiDebugScreen> {
  final Dio dio = Dio(BaseOptions(
    baseUrl: 'https://reqres.in/api',
    headers: {'Content-Type': 'application/json'},
  ));
  
  String output = 'Ready to test...';
  bool isLoading = false;

  Future<void> testCreateUser() async {
    setState(() {
      isLoading = true;
      output = 'Testing create user...';
    });

    try {
      final response = await dio.post('/users', data: {
        'name': 'John Doe',
        'job': 'Developer'
      });
      
      setState(() {
        output = 'SUCCESS: Status ${response.statusCode}\n'
                'Response: ${response.data}';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        output = 'ERROR: $e';
        if (e is DioException) {
          output += '\nStatus: ${e.response?.statusCode}';
          output += '\nResponse: ${e.response?.data}';
        }
        isLoading = false;
      });
    }
  }

  Future<void> testUpdateUser() async {
    setState(() {
      isLoading = true;
      output = 'Testing update user...';
    });

    try {
      final response = await dio.put('/users/2', data: {
        'name': 'Jane Updated',
        'job': 'Senior Developer'
      });
      
      setState(() {
        output = 'SUCCESS: Status ${response.statusCode}\n'
                'Response: ${response.data}';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        output = 'ERROR: $e';
        if (e is DioException) {
          output += '\nStatus: ${e.response?.statusCode}';
          output += '\nResponse: ${e.response?.data}';
        }
        isLoading = false;
      });
    }
  }

  Future<void> testDeleteUser() async {
    setState(() {
      isLoading = true;
      output = 'Testing delete user...';
    });

    try {
      final response = await dio.delete('/users/2');
      
      setState(() {
        output = 'SUCCESS: Status ${response.statusCode}\n'
                'Response: ${response.data ?? 'No content (expected for delete)'}';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        output = 'ERROR: $e';
        if (e is DioException) {
          output += '\nStatus: ${e.response?.statusCode}';
          output += '\nResponse: ${e.response?.data}';
        }
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('API Debug')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : testCreateUser,
                    child: Text('Test CREATE'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : testUpdateUser,
                    child: Text('Test UPDATE'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : testDeleteUser,
                    child: Text('Test DELETE'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(output),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}