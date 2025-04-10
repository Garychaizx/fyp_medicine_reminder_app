import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medicine_reminder/widgets/medication_adherence_card.dart';

class MedicationAdherencePage extends StatelessWidget {
  final List<Map<String, dynamic>> medications;

  const MedicationAdherencePage({Key? key, required this.medications})
      : super(key: key);

  Future<List<Map<String, dynamic>>> fetchAdherenceData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return [];
    }

    try {
      // Fetch medications for the current user
      final medicationsSnapshot = await FirebaseFirestore.instance
          .collection('medications')
          .where('user_uid', isEqualTo: currentUser.uid)
          .get();

      final medications = medicationsSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Add the document ID
        return data;
      }).toList();

      // Fetch adherence logs and calculate adherence rate for each medication
      final List<Map<String, dynamic>> adherenceData = [];
      for (final medication in medications) {
        final adherenceLogsSnapshot = await FirebaseFirestore.instance
            .collection('adherence_logs')
            .where('user_uid', isEqualTo: currentUser.uid)
            .where('medication_id', isEqualTo: medication['id'])
            .where('status', isEqualTo: 'taken') // Only count "taken" logs
            .get();

        final takenCount = adherenceLogsSnapshot.docs.length;
        final currentInventory = medication['current_inventory'] ?? 0;

        adherenceData.add({
          'id': medication['id'],
          'name': medication['name'],
          'imageBase64': medication['imageBase64'],
          'takenCount': takenCount,
          'currentInventory': currentInventory,
        });
      }

      return adherenceData;
    } catch (e) {
      print('Error fetching adherence data: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4F1),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchAdherenceData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a unified loading spinner
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Color.fromARGB(255, 56, 26, 3)), // Change color here
              ),
            );
          }

          if (snapshot.hasError) {
            // Show an error message if something goes wrong
            return Center(
              child: Text(
                'Error loading medications: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Show a message if there are no medications
            return const Center(
              child: Text(
                'No medications found.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // Render the list of adherence cards once data is loaded
          final medicationsData = snapshot.data!;
          return ListView.builder(
            itemCount: medicationsData.length,
            itemBuilder: (context, index) {
              final medication = medicationsData[index];
              return MedicationAdherenceCard(
                medicationId: medication['id'],
                medicationName: medication['name'],
                imageBase64: medication['imageBase64'],
                takenCount: medication['takenCount'],
                currentInventory: medication['currentInventory'],
              );
            },
          );
        },
      ),
    );
  }
}
