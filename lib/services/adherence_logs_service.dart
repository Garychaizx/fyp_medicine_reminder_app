import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdherenceLogsService {
  // Method to fetch adherence log
  Future<List<Map<String, dynamic>>> fetchAdherenceLogs(String medicationId) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return [];

      final querySnapshot = await FirebaseFirestore.instance
          .collection('adherence_logs')
          .where('user_uid', isEqualTo: currentUser.uid)
          .where('medication_id', isEqualTo: medicationId)
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching adherence logs: $e');
      return [];
    }
  }

  double calculateAdherenceRate(List<Map<String, dynamic>> logs) {
    int takenCount = 0;
    int totalCount = logs.length;

    for (var log in logs) {
      if (log['status'] == 'taken') {
        takenCount++;
      }
    }

    return totalCount > 0 ? (takenCount / totalCount) * 100 : 0.0;
  }
}
