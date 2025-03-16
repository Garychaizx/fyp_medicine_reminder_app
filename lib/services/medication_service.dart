import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
    final docRef = await _firestore.collection('medications').add(medication.toMap());

    // For "Every X Hours" frequency, calculate reminder times
    if (medication.frequency == 'Every X Hours' && 
        medication.startingTime != null && 
        medication.endingTime != null && 
        medication.hourInterval != null) {
      
      // Calculate reminder times based on interval
      List<String> calculatedTimes = calculateHourlyReminderTimes(
        medication.startingTime!,
        medication.endingTime!,
        medication.hourInterval!
      );
      
      // Schedule each calculated reminder
      for (String time in calculatedTimes) {
        await _notificationService.scheduleMedicationReminder(
          docRef.id,
          medication.name,
          time,
          medication.doseQuantity,
          medication.unit
        );
      }
    } 
    // For specific reminder times
    else if (medication.reminderTimes.isNotEmpty) {
      for (String time in medication.reminderTimes) {
        if (time.isNotEmpty) {
          await _notificationService.scheduleMedicationReminder(
            docRef.id,
            medication.name,
            time,
            medication.doseQuantity,
            medication.unit
          );
        }
      }
    }
  } catch (e) {
    throw Exception('Failed to add medication: $e');
  }
}
Future<void> scheduleIntervalReminders({
  required String medicationId,
  required String medicationName,
  required String startTime,
  required String endTime,
  required int intervalHours,
  required int doseQuantity,
  required String unit,
}) async {
  try {
    // Calculate reminder times based on the interval
    List<String> calculatedTimes = calculateHourlyReminderTimes(
      startTime,
      endTime,
      intervalHours,
    );
    
    // Schedule each calculated reminder
    for (String time in calculatedTimes) {
      await _notificationService.scheduleMedicationReminder(
        medicationId,
        medicationName,
        time,
        doseQuantity,
        unit,
      );
    }
  } catch (e) {
    throw Exception('Failed to schedule interval reminders: $e');
  }
}

List<String> calculateHourlyReminderTimes(
  String startTimeStr,
  String endTimeStr,
  int hourInterval
) {
  List<String> reminderTimes = [];
  
  // Parse start and end times
  DateTime? startTime = _parseTime(startTimeStr);
  DateTime? endTime = _parseTime(endTimeStr);
  
  if (startTime == null || endTime == null || hourInterval <= 0) {
    debugPrint('Invalid time parameters: start=$startTimeStr, end=$endTimeStr, interval=$hourInterval');
    return reminderTimes;
  }
  
  // If end time is earlier than start time, assume it's for the next day
  if (endTime.isBefore(startTime)) {
    endTime = endTime.add(Duration(days: 1));
  }
  
  // Calculate times
  DateTime currentTime = startTime;
  while (!currentTime.isAfter(endTime)) {
    reminderTimes.add(_formatTime(currentTime));
    currentTime = currentTime.add(Duration(hours: hourInterval));
  }

  return reminderTimes;
}
DateTime? _parseTime(String timeStr) {
  try {
    final RegExp timeRegex = RegExp(r'(\d+):(\d+)\s*(AM|PM)', caseSensitive: false);
    final Match? match = timeRegex.firstMatch(timeStr);
    
    if (match != null) {
      int hour = int.parse(match.group(1)!);
      int minute = int.parse(match.group(2)!);
      String period = match.group(3)!.toUpperCase();
      
      // Convert to 24-hour format
      if (period == 'PM' && hour != 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0;
      }
      
      // Use a fixed date (today) for comparison purposes only
      return DateTime(2000, 1, 1, hour, minute);
    }
  } catch (e) {
    debugPrint('Error parsing time: $e');
  }
  return null;
}

// Helper to format DateTime to string
String _formatTime(DateTime dateTime) {
  int hour = dateTime.hour;
  final String period = hour >= 12 ? 'PM' : 'AM';
  
  // Convert to 12-hour format
  if (hour > 12) {
    hour -= 12;
  } else if (hour == 0) {
    hour = 12;
  }
  
  final int minute = dateTime.minute;
  return '$hour:${minute.toString().padLeft(2, '0')} $period';
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
  
  final selectedDateOnly = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);

  final medicationsForSelectedDay = medications.where((medication) {
    final createdAtRaw = medication['created_at'];

    if (createdAtRaw == null || createdAtRaw is! Timestamp) {
      return false; // Skip medications with invalid or missing timestamps
    }

    final createdAt = createdAtRaw.toDate();
    final createdDateOnly = DateTime(createdAt.year, createdAt.month, createdAt.day);

    return createdDateOnly.isBefore(selectedDateOnly) || createdDateOnly.isAtSameMomentAs(selectedDateOnly);
  }).toList();

  final groupedMedications = <String, List<Map<String, dynamic>>>{};
  for (final medication in medicationsForSelectedDay) {
    List<String> reminderTimes = List<String>.from(medication['reminder_times'] ?? []);

    // Check if medication has "Every X Hours" frequency and calculate times dynamically
    if (medication['frequency'] == 'Every X Hours' &&
        medication.containsKey('interval_starting_time') &&
        medication.containsKey('interval_ending_time') &&
        medication.containsKey('interval_hour')) {
      
      // Call the function to calculate reminder times
      reminderTimes = calculateHourlyReminderTimes(
        medication['interval_starting_time'],
        medication['interval_ending_time'],
        medication['interval_hour'],
      );
    }

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
      String medicationName, int doseQuantity, DateTime selectedDay, String specificReminderTime) async {
    try {
       print('Logging adherence for user: $userUid, medication: $medicationId, dose: $doseQuantity at $specificReminderTime');


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
        'specific_reminder_time': specificReminderTime,
      });

      print('Adherence log added successfully');
    } catch (e) {
      print('Error logging adherence: $e');
      throw Exception('Failed to log adherence: $e');
    }
  }

Future<String?> fetchLatestTakenAt(
    String userId, 
    String medicationId, 
    DateTime currentReminderDate, 
    String specificReminderTime // Fetch only for this reminder time
  ) async {
  try {
    final startOfReminderDate = DateTime(
      currentReminderDate.year,
      currentReminderDate.month,
      currentReminderDate.day,
    );
    final endOfReminderDate = startOfReminderDate.add(const Duration(days: 1));

    final querySnapshot = await _firestore
        .collection('adherence_logs')
        .where('user_uid', isEqualTo: userId)
        .where('medication_id', isEqualTo: medicationId)
        .where('specific_reminder_time', isEqualTo: specificReminderTime) // Match specific time
        .where('date_remind', isGreaterThanOrEqualTo: startOfReminderDate)
        .where('date_remind', isLessThan: endOfReminderDate)
        .orderBy('date_taken', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      final dateTaken = doc['date_taken'] as Timestamp;

      return DateFormat('hh:mm a, dd MMMM ').format(dateTaken.toDate());
    }
  } catch (e) {
    print('Error fetching latest taken at: $e');
  }
  return null;
}


  Future<void> cancelReminders(String medicationId) async {
  await AwesomeNotifications().cancelNotificationsByChannelKey(medicationId);
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

  Future<void> saveMedication({
    required String medicationId,
    required Map<String, dynamic> medicationData,
    required bool isEveryXHours,
    required String medicationName,
    required List<String> reminderTimes,
    required int doseQuantity,
    required String unit,
    required String? startTime,
    required String? endTime,
    required int? intervalHours,
  }) async {
    try {
      await cancelReminders(medicationId);

      if (isEveryXHours) {
        await scheduleIntervalReminders(
          medicationId: medicationId,
          medicationName: medicationName,
          startTime: startTime ?? '',
          endTime: endTime ?? '',
          intervalHours: intervalHours ?? 0,
          doseQuantity: doseQuantity,
          unit: unit,
        );
      } else {
        scheduleReminders(
          medicationId: medicationId,
          medicationName: medicationName,
          reminderTimes: reminderTimes,
          doseQuantity: doseQuantity,
          unit: unit,
        );
      }

      await updateMedication(medicationId, medicationData);
    } catch (e) {
      debugPrint('Error saving medication: $e');
      throw Exception("Failed to save medication");
    }
  }

  // Helper methods for time handling
TimeOfDay? parseTimeString(String timeString) {
  try {
    timeString = timeString.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    final parts = timeString.split(' ');
    if (parts.length == 2) {
      final timeParts = parts[0].split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1].padLeft(2, '0'));
      bool isPM = parts[1].toUpperCase() == 'PM';

      final adjustedHour = isPM && hour != 12 ? hour + 12 : hour;
      final finalHour = adjustedHour == 24 ? 0 : adjustedHour;

      return TimeOfDay(hour: finalHour, minute: minute);
    }
  } catch (e) {
    debugPrint('Error parsing time: $e');
  }
  return null;
}

String formatTimeOfDay(TimeOfDay time, BuildContext context) {
  return TimeOfDay(hour: time.hour, minute: time.minute).format(context);
}


}
