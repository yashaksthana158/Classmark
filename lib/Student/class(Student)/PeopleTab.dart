import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:classmark/config_api.dart';

class PeopleTab extends StatefulWidget {
  final String classId;

  PeopleTab({required this.classId});

  @override
  _PeopleTabState createState() => _PeopleTabState();
}

class _PeopleTabState extends State<PeopleTab> {
  late Future<List<dynamic>> peopleData;

  @override
  void initState() {
    super.initState();
    peopleData = fetchPeopleInClass();
  }

  Future<List<dynamic>> fetchPeopleInClass() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionCookie = prefs.getString('session_cookie');

    final String apiUrl = '${ApiConfig.baseUrl}/class/${widget.classId}/people/';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        "Cookie": sessionCookie ?? " ",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['people'];
    } else {
      throw Exception('Failed to load people');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: peopleData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text("No people in this class.");
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var person = snapshot.data![index];
              return ListTile(
                title: Text(person['name']),
                subtitle: Text(person['role']),
              );
            },
          );
        }
      },
    );
  }
}
