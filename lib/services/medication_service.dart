import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:medicine_reminder/models/medication.dart';
import 'package:medicine_reminder/services/notification_service.dart';

class MedicationService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final NotificationService _notificationService;

  MedicationService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    NotificationService? notificationService,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _notificationService = notificationService ?? NotificationService();

  User? get currentUser => _auth.currentUser;
  Future<void> addMedication(Medication medication) async {
    try {
      // Add to Firestore
      final docRef =
          await _firestore.collection('medications').add(medication.toMap());

      // Schedule notifications
      for (String time in medication.reminderTimes) {
        if (time.isNotEmpty) {
          await _notificationService.scheduleMedicationReminder(docRef.id,
              medication.name, time, medication.doseQuantity, medication.unit);
        }
      }
    } catch (e) {
      throw Exception('Failed to add medication: $e');
    }
  }

  Future<void> updateMedication(
    String medicationId,
    Map<String, dynamic> updatedData,
  ) async {
    await _firestore
        .collection('medications')
        .doc(medicationId)
        .update(updatedData);
  }

  Future<void> deleteMedication(String medicationId) async {
    await _firestore.collection('medications').doc(medicationId).delete();
  }

  void scheduleReminders({
    required String medicationId,
    required String medicationName,
    required List<String> reminderTimes,
    required int doseQuantity,
    required String unit,
  }) {
    for (String time in reminderTimes) {
      NotificationService().scheduleMedicationReminder(
        medicationId,
        medicationName,
        time,
        doseQuantity,
        unit,
      );
    }
  }

Stream<List<Map<String, dynamic>>> fetchMedicationsForUser() {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('medications')
      .where('user_uid', isEqualTo: currentUser.uid)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            var data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList());
}

Map<String, List<Map<String, dynamic>>> groupMedicationsByTime(
    List<Map<String, dynamic>> medications, DateTime selectedDay) {
  final medicationsForSelectedDay = medications.where((medication) {
    final createdAtRaw = medication['created_at'];

    if (createdAtRaw == null || createdAtRaw is! Timestamp) {
      return false; // Skip medications with invalid or missing timestamps
    }

    final createdAt = createdAtRaw.toDate();
    return createdAt.isBefore(selectedDay) || createdAt.isAtSameMomentAs(selectedDay);
  }).toList();

  final groupedMedications = <String, List<Map<String, dynamic>>>{};
  for (final medication in medicationsForSelectedDay) {
    final reminderTimes = List<String>.from(medication['reminder_times'] ?? []);
    for (final time in reminderTimes) {
      groupedMedications[time] ??= [];
      groupedMedications[time]!.add(medication);
    }
  }

  return groupedMedications;
}


  Future<void> updateInventory(String medicationId, int doseQuantity) async {
    try {
      // Get the medication document reference
      final medicationRef =
          _firestore.collection('medications').doc(medicationId);

      // Fetch the current inventory
      final docSnapshot = await medicationRef.get();
      if (docSnapshot.exists) {
        final currentInventory = docSnapshot['current_inventory'] as int;

        // Calculate updated inventory
        final updatedInventory =
            (currentInventory - doseQuantity).clamp(0, double.infinity);

        // Update the current inventory field
        await medicationRef.update({
          'current_inventory': updatedInventory,
        });
      } else {
        throw Exception('Medication document does not exist.');
      }
    } catch (e) {
      throw Exception('Failed to update inventory: $e');
    }
  }

  Future<void> logAdherence(String userUid, String medicationId,
      String medicationName, int doseQuantity, DateTime selectedDay) async {
    try {
      print(
          'Logging adherence for user: $userUid, medication: $medicationId, dose: $doseQuantity');

      final adherenceLogRef = _firestore
          // .collection('users')
          // .doc(userUid)
          .collection('adherence_logs');

      await adherenceLogRef.add({
        'medication_id': medicationId,
        'medication_name': medicationName,
        'dose_quantity': doseQuantity,
        'date_remind': selectedDay,
        'date_taken': FieldValue.serverTimestamp(),
        'user_uid': userUid,
      });

      print('Adherence log added successfully');
    } catch (e) {
      print('Error logging adherence: $e');
      throw Exception('Failed to log adherence: $e');
    }
  }

  Future<String?> fetchLatestTakenAt(
      String userId, String medicationId, DateTime currentReminderDate) async {
    try {
      final startOfReminderDate = DateTime(
        currentReminderDate.year,
        currentReminderDate.month,
        currentReminderDate.day,
      );
      final endOfReminderDate =
          startOfReminderDate.add(const Duration(days: 1));

      final querySnapshot = await _firestore
          .collection('adherence_logs')
          .where('user_uid', isEqualTo: userId)
          .where('medication_id', isEqualTo: medicationId)
          .where('date_remind', isGreaterThanOrEqualTo: startOfReminderDate)
          .where('date_remind', isLessThan: endOfReminderDate)
          .orderBy('date_taken', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final dateTaken = doc['date_taken'] as Timestamp;
        final dateRemind = doc['date_remind'] as Timestamp;

        // Ensure that the log is for the relevant reminder date
        // if (dateRemind.toDate().isAtSameMomentAs(currentReminderDate)) {
        return DateFormat('hh:mm a, dd MMMM ').format(dateTaken.toDate());
        // }
      }
    } catch (e) {
      print('Error fetching latest taken at: $e');
    }
    return null;
  }

// Future<bool> fetchAdherenceLog(String medicationId, DateTime selectedDay) async {
//   try {
//     // Define the start and end of the selected day
//     final startOfDay = Timestamp.fromDate(
//       DateTime(selectedDay.year, selectedDay.month, selectedDay.day),
//     );
//     final endOfDay = Timestamp.fromDate(
//       DateTime(selectedDay.year, selectedDay.month, selectedDay.day, 23, 59, 59),
//     );

//     // Step 1: Fetch documents filtered by medication_id
//     final adherenceDocs = await FirebaseFirestore.instance
//         .collection('adherence_logs')
//         .where('medication_id', isEqualTo: medicationId)
//         .get();

//     // Step 2: Filter results by timestamp in the app
//     final filteredDocs = adherenceDocs.docs.where((doc) {
//       final timestamp = doc['timestamp'] as Timestamp;
//       return timestamp.compareTo(startOfDay) >= 0 &&
//           timestamp.compareTo(endOfDay) <= 0;
//     });

//     // Return whether there is any adherence log for the day
//     return filteredDocs.isNotEmpty;
//   } catch (e) {
//     print('Error fetching adherence logs: $e');
//     return false;
//   }
// }
}
