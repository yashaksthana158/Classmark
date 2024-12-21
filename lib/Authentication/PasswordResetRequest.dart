import 'package:classmark/Authentication/PasswordReset.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config_api.dart';

class PasswordResetRequestScreen extends StatefulWidget {
  @override
  _PasswordResetRequestScreenState createState() => _PasswordResetRequestScreenState();
}

class _PasswordResetRequestScreenState extends State<PasswordResetRequestScreen> {
  final TextEditingController _emailController = TextEditingController();
  String _message = '';

  Future<void> sendPasswordResetRequest() async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/password-reset-request/'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'email': _emailController.text,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => PasswordResetScreen()));
      setState(() {
        _message = 'Password reset email sent!';
      });
    } else {
      setState(() {
        _message = 'Email not found.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Password Reset Request'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendPasswordResetRequest,
              child: Text('Request Password Reset'),
            ),
            SizedBox(height: 20),
            Text(_message),
          ],
        ),
      ),
    );
  }
}
