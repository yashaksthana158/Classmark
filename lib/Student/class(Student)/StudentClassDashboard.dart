import 'package:flutter/material.dart';
import 'StreamTab.dart'; // Import the stream tab
import 'ClassworkTab.dart'; // Import the classwork tab
import 'PeopleTab.dart'; // Import the people tab
import 'StudentAttendanceView.dart'; // Import attendance view
import 'QRViewExample.dart'; // Import QRViewExample for QR scanning

class StudentClassDashboard extends StatefulWidget {
  final Map<String, dynamic> classData;

  StudentClassDashboard({required this.classData});

  @override
  _StudentClassDashboardState createState() => _StudentClassDashboardState();
}

class _StudentClassDashboardState extends State<StudentClassDashboard>
    with SingleTickerProviderStateMixin {
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
    // Retrieve attendance data if available
    /* List<dynamic> attendance = widget.classData['attendance'] ?? []; */
    
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
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Class Dashboard'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.text_fields_outlined),
              title: Text('Attendance'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentAttendanceView(
                        classData: widget.classData), // Pass class data
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
          // Navigate to QR scanner page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => QRViewExample()),
          );
        },
        child: Icon(Icons.qr_code_scanner),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
