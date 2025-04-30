import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medicine_reminder/pages/change_password_page.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ProfilePage({Key? key, required this.userData}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // final TextEditingController caregiverEmailController = TextEditingController();
  // bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill caregiver email if it exists
    // caregiverEmailController.text = widget.userData['caregiver_email'] ?? '';
  }

  // Future<void> saveCaregiverEmail() async {
  //   setState(() {
  //     _isSaving = true;
  //   });

  //   try {
  //     final currentUser = FirebaseAuth.instance.currentUser;
  //     if (currentUser == null) return;

  //     await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(currentUser.uid)
  //         .update({
  //       'caregiver_email': caregiverEmailController.text.trim(),
  //     });

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Caregiver email saved successfully!')),
  //     );
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to save caregiver email: $e')),
  //     );
  //   } finally {
  //     setState(() {
  //       _isSaving = false;
  //     });
  //   }
  // }

  String formatTimestamp(dynamic timestamp) {
    if (timestamp != null) {
      final DateTime dateTime = timestamp.toDate();
      return DateFormat('yMMMd').format(dateTime);
    }
    return 'N/A';
  }

  @override
  Widget build(BuildContext context) {
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
                        widget.userData['name'][0].toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.userData['name'],
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(widget.userData['email'],
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
              leading: const Icon(Icons.calendar_today, color: Color(0xFF4E2A2A)),
              title: const Text('Age'),
              subtitle: Text(widget.userData['age'].toString()),
            ),
            ListTile(
              leading: const Icon(Icons.date_range, color: Color(0xFF4E2A2A)),
              title: const Text('Created At'),
              subtitle: Text(formatTimestamp(widget.userData['created_at'])),
            ),

            const SizedBox(height: 20),

            // Caregiver Email
            const Text(
              'Caregiver Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // TextField(
            //   controller: caregiverEmailController,
            //   decoration: const InputDecoration(
            //     labelText: 'Caregiver Email',
            //     hintText: 'Enter caregiver email',
            //     border: OutlineInputBorder(),
            //   ),
            //   keyboardType: TextInputType.emailAddress,
            // ),
            // const SizedBox(height: 10),
            // _isSaving
            //     ? const CircularProgressIndicator()
            //     : ElevatedButton(
            //         onPressed: saveCaregiverEmail,
            //         child: const Text('Save Caregiver Email'),
            //       ),

            const SizedBox(height: 20),

            // Settings
            const Text(
              'Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              leading: const Icon(Icons.lock, color: Color(0xFF4E2A2A)),
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