import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:medicine_reminder/pages/login_page.dart';
import 'package:medicine_reminder/pages/medication_adherence_page.dart';
import 'package:medicine_reminder/pages/medications_page.dart';
import 'package:medicine_reminder/pages/nearby_pharmacy_page.dart';
import 'package:medicine_reminder/pages/profile_page.dart';
import 'package:medicine_reminder/pages/task_visualization_page.dart';
import 'package:medicine_reminder/services/auth_service.dart';

Future<Map<String, dynamic>> fetchUserData() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return {}; // Return empty map instead of throwing exception
  
  try {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (!userDoc.exists) return {};
    return userDoc.data()!;
  } catch (e) {
    print("Error fetching user data: $e");
    return {};
  }
}

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavBarState();
}

class _NavBarState extends State<Navbar> {
  int _currentIndex = 0;

  final AuthService _authService = AuthService();

void handleLogout(BuildContext context) async {
  await _authService.logOut();
  // Navigate to login page and replace the entire navigation stack
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => LoginPage()),
    (route) => false, // This removes all previous routes
  );
}

final List<Widget> _pages = [
  TaskVisualizationPage(),
  // Wrap in a conditional check
  Builder(builder: (context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Center(child: Text('Please log in to view adherence data.'));
    }
    
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('medications')
          .where('user_uid', isEqualTo: currentUser.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No medications found.'));
        } else {
          final medications = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id; // Add the document ID
            return data;
          }).toList();

          return MedicationAdherencePage(medications: medications);
        }
      },
    );
  }),
  MedicationsPage(),
  NearbyPharmacyPage(),
  // Also wrap this FutureBuilder
  Builder(builder: (context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Center(child: Text('Please log in to view profile.'));
    }
    
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchUserData(),
  builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return ProfilePage(userData: snapshot.data ?? {});
        }
      },
    );
  }),
];

  final List<String> _titles = [
    'Home',
    'Adherence',
    'Medications',
    'Pharmacies nearby',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(
            fontSize: 20, // Adjust font size as needed
            fontWeight: FontWeight.bold, // Make it bold
            color: Colors.black, // Change color to white
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => handleLogout(context),
            color: Colors.black,
          ),
        ],
        backgroundColor: const Color(0xFFF8F4F1),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
        child: GNav(
          backgroundColor: Colors.white,
          color: Colors.black45,
          activeColor: Colors.red[600],
          tabBackgroundColor: const Color.fromARGB(66, 150, 147, 147),
          gap: 8,
          padding: const EdgeInsets.all(16),
          tabs: const [
            GButton(
              icon: Icons.house_outlined,
              text: 'Home',
            ),
            GButton(
              icon: Icons.bar_chart_outlined, // Icon for adherence
              text: 'Adherence',
            ),
            GButton(
              icon: Icons.medication_liquid_sharp,
              text: 'Medications',
            ),
            GButton(
              icon: Icons.medical_services_outlined,
              text: 'Pharmacies',
            ),
            GButton(
              icon: Icons.person_2_outlined,
              text: 'Profile',
            ),
          ],
          onTabChange: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
