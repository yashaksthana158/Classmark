import 'package:classmark/Teacher/ClassworkTab.dart';
import 'package:classmark/Teacher/PeopleTab.dart';
import 'package:classmark/Teacher/StreamTab.dart';
import 'package:flutter/material.dart';
import 'QrCodePage.dart'; // Import QRCodePage for QR code generation
import '../config_api.dart';
import 'TeacherAttendanceView.dart'; // Import the attendance view

class TeacherClassDashboard extends StatefulWidget {
  final Map<String, dynamic> classData;

  TeacherClassDashboard({required this.classData});

  @override
  _TeacherClassDashboardState createState() => _TeacherClassDashboardState();
}

class _TeacherClassDashboardState extends State<TeacherClassDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /* List<dynamic> studentsAttendance = widget.classData['students_attendance'] ?? []; */

    return Scaffold(
      appBar: AppBar(
        title: Text('Class Dashboard: ${widget.classData['class_code']}'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Stream'),
            Tab(text: 'Classwork'),
            Tab(text: 'People'),
          ],
        ),
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
                Navigator.pop(context); // Close the drawer first
              },
            ),
            ListTile(
              leading: Icon(Icons.check),
              title: Text('Attendance'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TeacherAttendanceView(classData: widget.classData),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
       children: [
          StreamTab(), // Stream tab content
          ClassworkTab(), // Classwork tab content
          PeopleTab(classId: widget.classData['class_code']), // Pass people data to the people tab
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the QR Code page to display QR Code
          final qrCodeUrl = '${ApiConfig.baseUrl}/generate_qr/${widget.classData['class_code']}/';
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QrCodePage(qrCodeUrl: qrCodeUrl),
            ),
          );
        },
        child: Icon(Icons.qr_code), // QR code generator icon
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Position the FAB
    );
  }
}

