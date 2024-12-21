
import 'dart:convert'; // For JSON encoding/decoding
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'TeacherClassDashboard.dart'; // Import TeacherClassDashboard for navigation
import 'package:classmark/config_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'dart:io'; // For file operations
import 'package:path_provider/path_provider.dart';

class TeacherAttendanceView extends StatefulWidget {
  final Map<String, dynamic> classData;

  TeacherAttendanceView({required this.classData});

  @override
  _TeacherAttendanceViewState createState() => _TeacherAttendanceViewState();
}

class _TeacherAttendanceViewState extends State<TeacherAttendanceView> {
  List<dynamic> studentsAttendance = [];
  bool isLoading = true;
  bool hasError = false;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchAttendanceData();
  }

  // Fetch attendance data from the backend API
  Future<void> _fetchAttendanceData() async {
    final classCode = widget.classData['class_code'];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionCookie = prefs.getString('session_cookie');

    Map<String, String> queryParameters = {
      if (selectedDate != null)
        'date': DateFormat('yyyy-MM-dd').format(selectedDate!),
    };

    final uri = Uri.parse('${ApiConfig.baseUrl}/attendance/$classCode')
        .replace(queryParameters: queryParameters);

    try {
      final response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        "Cookie": sessionCookie ?? "",
      });

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse.containsKey('attendance')) {
          setState(() {
            studentsAttendance = jsonResponse['attendance'] ?? [];
            isLoading = false;
            hasError = false;
          });
        } else {
          setState(() {
            studentsAttendance = [];
            isLoading = false;
          });
        }
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  // Date picker for attendance data filtering
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        isLoading = true;
      });
      _fetchAttendanceData();
    }
  }

  // Function to export attendance as XLSX
  Future<void> _exportAttendanceXLSX() async {
    final classCode = widget.classData['class_code'];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionCookie = prefs.getString('session_cookie');

    final url = Uri.parse('${ApiConfig.baseUrl}/attendance/$classCode/export/xlsx/');
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      "Cookie": sessionCookie ?? "",
    });

    if (response.statusCode == 200) {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/attendance_$classCode.xlsx');
      await file.writeAsBytes(response.bodyBytes);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("XLSX file saved to ${directory.path}")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to export XLSX")));
    }
  }

  // Function to export attendance as PDF
  Future<void> _exportAttendancePDF() async {
    final classCode = widget.classData['class_code'];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionCookie = prefs.getString('session_cookie');

    final url = Uri.parse('${ApiConfig.baseUrl}/attendance/$classCode/export/pdf/');
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      "Cookie": sessionCookie ?? "",
    });

    if (response.statusCode == 200) {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/attendance_$classCode.pdf');
      await file.writeAsBytes(response.bodyBytes);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("PDF file saved to ${directory.path}")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to export PDF")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance: ${widget.classData['class_code']}'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : hasError
              ? Center(child: Text('Failed to load attendance data.'))
              : studentsAttendance.isEmpty
                  ? Center(child: Text('No attendance data available.'))
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () => _selectDate(context),
                                child: Text('Select Date'),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: [
                                DataColumn(label: Text('Student Name')),
                                DataColumn(label: Text('Status')),
                              ],
                              rows: studentsAttendance.map((student) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(student['student_name'] ?? 'Unknown')),
                                    DataCell(Text(student['status'])),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                onPressed: _exportAttendanceXLSX,
                                child: Text('Export XLSX'),
                              ),
                              ElevatedButton(
                                onPressed: _exportAttendancePDF,
                                child: Text('Export PDF'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
    );
  }
}
