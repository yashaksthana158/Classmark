
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'TeacherClassDashboard.dart'; // Import the class details page
import '../config_api.dart';

class TeacherDashboard extends StatefulWidget {
  @override
  _TeacherDashboardState createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  Future<List<dynamic>> fetchTeacherClasses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionCookie = prefs.getString('session_cookie');

    const String apiUrl = '${ApiConfig.baseUrl}/teacher/classes/';

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
        title: Text('Teacher Dashboard'),
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
                // Navigate to dashboard or other screens
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                _showLogoutConfirmationDialog(); // Show logout confirmation dialog
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            Expanded(
                child:
                    TeacherClassesList()), // Display the list of classes created by the teacher
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
              context, 'create_class'); // Navigates to class creation
        },
        child: Icon(Icons.add), // Plus sign icon
        backgroundColor: Colors.blue, // Customize the color as needed
      ),
    );
  }
}

class TeacherClassesList extends StatefulWidget {
  @override
  _TeacherClassesListState createState() => _TeacherClassesListState();
}

class _TeacherClassesListState extends State<TeacherClassesList> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: fetchTeacherClasses(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Show loading spinner while fetching data
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text("No classes created yet.");
        } else {
          // Display the list of classes created by the teacher
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var classData = snapshot.data![index];
              return ListTile(
                title: Text(classData['class_name']),
                subtitle: Text("Class Code: ${classData['class_code']}"),
                onTap: () {
                  // Navigate to the TeacherClassDashboard with the full class data
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TeacherClassDashboard(
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

  Future<List<dynamic>> fetchTeacherClasses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionCookie = prefs.getString('session_cookie');

    const String apiUrl = '${ApiConfig.baseUrl}/teacher/classes/';

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
