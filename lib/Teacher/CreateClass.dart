import 'package:classmark/Teacher/TeacherClassDashboard.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../config_api.dart';

class CreateClassPage extends StatefulWidget {
  @override
  _CreateClassPageState createState() => _CreateClassPageState();
}

class _CreateClassPageState extends State<CreateClassPage> {
  TextEditingController _classNameController = TextEditingController();
  TextEditingController _classDescriptionController = TextEditingController();
  String apiUrl = '${ApiConfig.baseUrl}/create_class/';

  Future<void> _createClass() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionCookie = prefs.getString('session_cookie');

    Map<String, dynamic> requestData = {
      'class_name': _classNameController.text,
      'description': _classDescriptionController.text,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': sessionCookie ?? '', // Ensure session cookie is sent
        },
        body: json.encode(requestData),
      );

      if (response.statusCode == 201) {
        var responseData = json.decode(response.body);

        // Retrieve class code and any other data (like attendance)
        String classCode = responseData['class_code'];
        List<dynamic> studentsAttendance = responseData['students_attendance'] ?? [];

        print('Class created successfully with Code: $classCode');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Class created successfully!')),
        );

        // Navigate to TeacherClassDashboard with the class data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TeacherClassDashboard(
              classData: {
                'class_code': classCode,
                'students_attendance': studentsAttendance,
              },
            ),
          ),
        );
      } else {
        // Handle error response
        var responseData = json.decode(response.body);
        print('Error: ${responseData['error']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${responseData['error']}')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Class'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _classNameController,
              decoration: InputDecoration(labelText: 'Class Name'),
            ),
            TextField(
              controller: _classDescriptionController,
              decoration: InputDecoration(labelText: 'Class Description'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createClass,
              child: Text('Create Class'),
            ),
          ],
        ),
      ),
    );
  }
}
