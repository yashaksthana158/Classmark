import 'package:classmark/Student/class(Student)/StudentClassDashboard.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../config_api.dart';

class JoinClass extends StatefulWidget {
  @override
  _JoinClassState createState() => _JoinClassState();
}

class _JoinClassState extends State<JoinClass> {
  TextEditingController _classCodeController = TextEditingController();

  Future<void> _joinClass() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionCookie = prefs.getString('session_cookie');

    const String apiUrl = '${ApiConfig.baseUrl}/join_class/';

    Map<String, String> requestData = {
      'class_code': _classCodeController.text,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Cookie": sessionCookie ?? " ", // Ensure session cookie is sent
        },
        body: json.encode(requestData),
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);

        // Pass class code and attendance data to StudentClassDashboard
        String classCode = responseData['class_code'];
        List<dynamic> attendance = responseData['attendance'] ?? [];

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Class joined successfully!")),
        );

        // Navigate to the StudentClassDashboard with the full class data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudentClassDashboard(
              classData: {
                'class_code': classCode,
                'attendance': attendance,
              },
            ),
          ),
        );

        


        // Navigate back to StudentDashboard or handle accordingly
       /*  Navigator.pop(context); */
      } else {
        var responseData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${responseData['error']}")),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Join Class'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _classCodeController,
              decoration: InputDecoration(labelText: 'Enter Class Code'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _joinClass,
              child: Text('Join Class'),
            ),
          ],
        ),
      ),
    );
  }
}
