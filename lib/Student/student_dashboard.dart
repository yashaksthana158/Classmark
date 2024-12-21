import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:classmark/Student/class(Student)/StudentClassDashboard.dart'; 
import 'package:classmark/Student/class(Student)/JoinClass.dart'; 
import '../config_api.dart';

class StudentDashboard extends StatefulWidget {
  @override
  _StudentDashboardState createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  Future<List<dynamic>> fetchStudentClasses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionCookie = prefs.getString('session_cookie');

    const String apiUrl = '${ApiConfig.baseUrl}/student/classes/';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        "Cookie": sessionCookie ?? " ", 
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['classes'];
    } else {
      throw Exception('Failed to load classes');
    }
  }

  // Function to log the user out
  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionCookie = prefs.getString('session_cookie');

    const String apiUrl = '${ApiConfig.baseUrl}/logout/'; // Backend logout API

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Cookie": sessionCookie ?? "", // Send session cookie if available
        },
      );
      print('Session Cookie: $sessionCookie');

      if (response.statusCode == 200) {
        // Successfully logged out
        // Clear session cookie from SharedPreferences
        await prefs.remove('session_cookie');

        // Show confirmation and redirect to login screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Logged out successfully")),
        );

        // Navigate back to the login screen
        Navigator.pushReplacementNamed(context, 'login');
      } else {
        // Handle failed logout
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to log out")),
        );
      }
    } catch (e) {
      print("Error during logout: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred during logout")),
      );
    }
  }

  // Confirmation dialog for logout
  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Logout'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _logout(); // Perform the logout
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Dashboard'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              onTap: () {
                // Close the drawer
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                _showLogoutConfirmationDialog();// Add your logout functionality here
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
                child:
                    JoinedClassesList()), // Display the list of joined classes
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => JoinClass()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue, 
      ),
    );
  }
}

class JoinedClassesList extends StatefulWidget {
  @override
  _JoinedClassesListState createState() => _JoinedClassesListState();
}

class _JoinedClassesListState extends State<JoinedClassesList> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: fetchStudentClasses(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Show loading spinner while fetching data
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text("No classes joined yet.");
        } else {
          // Display the list of classes the student has joined
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var classData = snapshot.data![index];
              return ListTile(
                title: Text(classData['class_name']),
                subtitle: Text("Class Code: ${classData['class_code']}"),
                onTap: () {
                  // Optionally navigate to the StudentClassDashboard with the full class data
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentClassDashboard(
                        classData: classData,
                      ),
                    ),
                  );
                },
              );
            },
          );
        }
      },
    );
  }

  Future<List<dynamic>> fetchStudentClasses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionCookie = prefs.getString('session_cookie');

    const String apiUrl = '${ApiConfig.baseUrl}/student/classes/';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        "Cookie": sessionCookie ?? " ", // Ensure session cookie is sent
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['classes'];
    } else {
      throw Exception('Failed to load classes');
    }
  }
}
