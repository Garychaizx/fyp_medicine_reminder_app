import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

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
      // appBar: AppBar(
      //   title: const Text('Profile'),
      //   backgroundColor: Colors.deepPurple,
      // ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.deepPurple.shade100,
                      child: Text(
                        userData['name'][0].toUpperCase(),
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userData['name'],
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(userData['email'], style: const TextStyle(color: Colors.grey)),
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
              leading: const Icon(Icons.calendar_today, color: Colors.deepPurple),
              title: const Text('Age'),
              subtitle: Text(userData['age'].toString()),
            ),
            ListTile(
              leading: const Icon(Icons.date_range, color: Colors.deepPurple),
              title: const Text('Created At'),
              subtitle: Text(formatTimestamp(userData['created_at'])), // Use formatted timestamp
            ),

            const SizedBox(height: 20),

            // Settings
            const Text(
              'Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              leading: const Icon(Icons.lock, color: Colors.deepPurple),
              title: const Text('Password & Security'),
              onTap: () {
                // Navigate to Password Settings
              },
            ),
            // ListTile(
            //   leading: const Icon(Icons.notifications, color: Colors.deepPurple),
            //   title: const Text('Notification Preferences'),
            //   onTap: () {
            //     // Navigate to Notification Settings
            //   },
            // ),
            ListTile(
              leading: const Icon(Icons.help, color: Colors.deepPurple),
              title: const Text('FAQ'),
              onTap: () {
                // Navigate to FAQ Page
              },
            ),
          ],
        ),
      ),
    );
  }
}
