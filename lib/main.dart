
import 'package:classmark/Authentication/PasswordResetRequest.dart';
import 'package:classmark/Authentication/login.dart';
import 'package:classmark/Authentication/register.dart';
import 'package:classmark/Student/student_dashboard.dart';
import 'package:classmark/Teacher/CreateClass.dart';
import 'package:classmark/Teacher/teacher_dashboard.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    title: 'ClassMark',
    debugShowCheckedModeBanner: false,
    home: MyLogin(),
    routes: {
      'register': (context) => MyRegister(),
      'login': (context) => MyLogin(),
      'teacher_dashboard': (context) =>
          TeacherDashboard(), // Route for teacher dashboard
      'student_dashboard': (context) =>
          StudentDashboard(), // Route for student dashboard
      'create_class': (context) => CreateClassPage(),
      'forgot_password':(context)=>PasswordResetRequestScreen(),
    },
  ));
}
