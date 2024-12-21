import 'package:flutter/material.dart';

class StreamTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Hardcoded cover photo URL
    String coverPhotoUrl = 'https://storage.googleapis.com/celestial-torus-431513-k8.appspot.com/Flutterdemo/product-display-podium-with-marble-wall-leaves-shadow-3d-podium-illustration-render.jpg';

    // Hardcoded announcements data
    List<Map<String, String>> announcements = [
      {
        'title': 'Welcome to the Class',
        'body': 'This is the first announcement.',
        'date': '2024-10-01',
      },
      {
        'title': 'Assignment Reminder',
        'body': 'Remember to submit your assignment by Friday.',
        'date': '2024-10-02',
      },
    ];

    return ListView(
      children: [
        // Big cover photo
        Container(
          height: 200.0,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(coverPhotoUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: 10.0),
        
        // Announcements Section
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "Announcements",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 10.0),
        
        // List of Announcements
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(), // Disable scrolling inside the list
          itemCount: announcements.length,
          itemBuilder: (context, index) {
            var announcement = announcements[index];
            return Card(
              child: ListTile(
                title: Text(announcement['title']!),
                subtitle: Text(announcement['body']!),
                trailing: Text(announcement['date']!),
              ),
            );
          },
        ),
      ],
    );
  }
}
