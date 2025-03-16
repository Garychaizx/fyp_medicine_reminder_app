import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medicine_reminder/pages/change_password_page.dart';
import 'package:medicine_reminder/pages/nearby_pharmacy_page.dart'; // For date formatting

class ProfilePage extends StatelessWidget {
  final Map<String, dynamic> userData;

  const ProfilePage({Key? key, required this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Convert the Firebase Timestamp to a formatted date string
    String formatTimestamp(dynamic timestamp) {
      if (timestamp != null) {
        // Check if the timestamp is a Firebase Timestamp
        final DateTime dateTime = timestamp.toDate();
        return DateFormat('yMMMd').format(dateTime); // Format as "Jan 1, 2023"
      }
      return 'N/A';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4F1),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.brown[800],
                      child: Text(
                        userData['name'][0].toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white,fontSize: 24, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userData['name'],
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(userData['email'],
                            style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Account Details
            const Text(
              'Account Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.calendar_today,
                  color: Color(0xFF4E2A2A)),
              title: const Text('Age'),
              subtitle: Text(userData['age'].toString()),
            ),
            ListTile(
              leading: const Icon(Icons.date_range,
                  color: Color(0xFF4E2A2A)),
              title: const Text('Created At'),
              subtitle: Text(formatTimestamp(
                  userData['created_at'])), // Use formatted timestamp
            ),

            const SizedBox(height: 20),

            // Settings
            const Text(
              'Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              leading:
                  const Icon(Icons.lock, color: Color(0xFF4E2A2A)),
              title: const Text('Password & Security'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangePasswordPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
