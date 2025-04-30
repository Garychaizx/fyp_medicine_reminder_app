import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medicine_reminder/widgets/medication_adherence_card.dart';


class MedicationAdherencePage extends StatelessWidget {
  final List<Map<String, dynamic>> medications;

  const MedicationAdherencePage({Key? key, required this.medications})
      : super(key: key);

  Future<List<Map<String, dynamic>>> fetchAllAdherenceData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return [];

      // Fetch all medications for the current user
      final medicationsSnapshot = await FirebaseFirestore.instance
          .collection('medications')
          .where('user_uid', isEqualTo: currentUser.uid)
          .get();

      List<Map<String, dynamic>> adherenceDataList = [];

      for (var medicationDoc in medicationsSnapshot.docs) {
        final medicationData = medicationDoc.data();
        final medicationId = medicationDoc.id;
        final medicationName = medicationData['name'] ?? 'Unknown';
        final imageBase64 = medicationData['imageBase64'];
        final totalDosageRequired =
            medicationData['total_dosage_required'] ?? 0;

        // Fetch adherence logs for the medication
        final adherenceLogsSnapshot = await FirebaseFirestore.instance
            .collection('adherence_logs')
            .where('user_uid', isEqualTo: currentUser.uid)
            .where('medication_id', isEqualTo: medicationId)
            .where('status', isEqualTo: 'taken') // Only count "taken" logs
            .get();

        final takenCount = adherenceLogsSnapshot.docs.length;

        adherenceDataList.add({
          'medicationId': medicationId,
          'medicationName': medicationName,
          'imageBase64': imageBase64,
          'takenCount': takenCount,
          'totalDosageRequired': totalDosageRequired,
        });
      }

      return adherenceDataList;
    } catch (e) {
      print('Error fetching all adherence data: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4F1),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchAllAdherenceData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a unified loading spinner with custom color
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color.fromARGB(
                      255, 56, 26, 3), // Custom color for the spinner
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No medications found.'));
          }
          final adherenceDataList = snapshot.data!;

          return ListView.builder(
            itemCount: adherenceDataList.length,
            itemBuilder: (context, index) {
              final adherenceData = adherenceDataList[index];
              return MedicationAdherenceCard(
                medicationId: adherenceData['medicationId'],
                medicationName: adherenceData['medicationName'],
                imageBase64: adherenceData['imageBase64'],
                takenCount: adherenceData['takenCount'],
                currentInventory: adherenceData[
                    'totalDosageRequired'], // Pass total dosage required
              );
            },
          );
        },
      ),
    );
  }
}
