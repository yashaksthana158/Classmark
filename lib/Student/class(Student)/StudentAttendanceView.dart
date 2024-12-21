

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../../config_api.dart';

class StudentAttendanceView extends StatefulWidget {
  final Map<String, dynamic> classData;

  StudentAttendanceView({required this.classData});

  @override
  _StudentAttendanceViewState createState() => _StudentAttendanceViewState();
}

class _StudentAttendanceViewState extends State<StudentAttendanceView> {
  List<dynamic> attendance = [];
  bool isLoading = true;
  bool hasError = false;
  DateTime? selectedDate;
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    _fetchAttendanceData();
  }

  Future<void> _fetchAttendanceData() async {
    final classCode = widget.classData['class_code'];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionCookie = prefs.getString('session_cookie');
    final url = Uri.parse('${ApiConfig.baseUrl}/attendance/$classCode');

    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        "Cookie": sessionCookie ?? " ",
      });

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        setState(() {
          attendance = jsonResponse['attendance'] ?? [];
          isLoading = false;
        });
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        startDate = null;
        endDate = null;
        isLoading = true;
      });
      _fetchAttendanceData();
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final List<DateTime>? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    )?.then((value) {
      if (value != null) {
        return [value.start, value.end];
      }
      return null;
    });

    if (picked != null && picked.length == 2) {
      setState(() {
        startDate = picked[0];
        endDate = picked[1];
        selectedDate = null;
        isLoading = true;
      });
      _fetchAttendanceData();
    }
  }

  Future<void> _exportAttendanceXLSX() async {
    final classCode = widget.classData['class_code'];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionCookie = prefs.getString('session_cookie');
    final url = Uri.parse('${ApiConfig.baseUrl}/attendance/$classCode/export/xlsx/');
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/attendance_$classCode.xlsx';
    final file = File(filePath);

    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      "Cookie": sessionCookie ?? " ",
    });

    if (response.statusCode == 200) {
      await file.writeAsBytes(response.bodyBytes);
      print('Attendance exported as XLSX at $filePath');
    }
  }

  Future<void> _exportAttendancePDF() async {
    final classCode = widget.classData['class_code'];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionCookie = prefs.getString('session_cookie');
    final url = Uri.parse('${ApiConfig.baseUrl}/attendance/$classCode/export/pdf/');
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/attendance_$classCode.pdf';
    final file = File(filePath);

    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      "Cookie": sessionCookie ?? " ",
    });

    if (response.statusCode == 200) {
      await file.writeAsBytes(response.bodyBytes);
      print('Attendance exported as PDF at $filePath');
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
                      ElevatedButton(
                        onPressed: () => _selectDateRange(context),
                        child: Text('Select Date Range'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: attendance.length,
                    itemBuilder: (context, index) {
                      final record = attendance[index];
                      return ListTile(
                        title: Text("Status: ${record['status']}"),
                        subtitle: Text("Date: ${record['date']}"),
                      );
                    },
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
