import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> initializeNotification() async {
    // Request notification permissions
    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  Future<void> scheduleMedicationReminder(
    String medicationId,
    String medicationName,
    String reminderTime,
    int doseQuantity,
    String unit,
  ) async {
    try {
      debugPrint('Received reminder time: $reminderTime');

      // Parse time in "3:57 AM" format
      final RegExp timeRegex =
          RegExp(r'(\d+):(\d+)\s*(AM|PM)', caseSensitive: false);
      final Match? match = timeRegex.firstMatch(reminderTime);

      if (match == null) {
        debugPrint('Invalid time format');
        return;
      }

      int hour = int.parse(match.group(1)!);
      final int minute = int.parse(match.group(2)!);
      final String period = match.group(3)!.toUpperCase();

      // Convert to 24-hour format
      if (period == 'PM' && hour != 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0;
      }

      // Generate a unique ID based on medication ID, hour, and minute
      int uniqueId = medicationId.hashCode + hour * 60 + minute;

      // Schedule the notification with a unique ID
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: uniqueId,
          channelKey: 'medication_channel',
          title: 'Medicine Reminder',
          body: 'Time to take $doseQuantity $unit of $medicationName',
          category: NotificationCategory.Reminder,
          wakeUpScreen: true,
          payload: {'medicationId': medicationId},
          // // customSound: 'assets/alarm_sound.mp3', // Replace with your custom sound file path
          // duration: const Duration(seconds: 5), // Set the duration of the sound
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'MARK_TAKEN',
            label: 'Mark as Taken',
          ),
        ],
        schedule: NotificationCalendar(
          hour: hour,
          minute: minute,
          second: 0,
          repeats: true, // Daily repeat
          allowWhileIdle: true,
        ),
      );

      debugPrint(
          'Notification scheduled successfully for daily repeat at ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  Future<void> cancelAllMedicationReminders() async {
    // Logic to cancel all scheduled notifications
    await AwesomeNotifications().cancelAll();
    print('All medication reminders canceled.');
  }

  Future<void> _handleMedicationTaken(String medicationId) async {
    if (medicationId.isEmpty) return;

    try {
      final medicationRef = FirebaseFirestore.instance
          .collection('medications')
          .doc(medicationId);

      final medicationDoc = await medicationRef.get();
      if (medicationDoc.exists) {
        final data = medicationDoc.data();
        if (data != null) {
          final int currentInventory = data['current_inventory'] ?? 0;
          final int dosage = data['dosage'] ?? 1;

          await medicationRef.update({
            'current_inventory': currentInventory - dosage,
            'last_taken': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      debugPrint('Error updating medication: $e');
    }
  }

  Future<void> cancelMedicationReminder(String medicationId) async {
    await AwesomeNotifications().cancel(
        medicationId.hashCode); // Use a unique identifier for the notification
    print('Canceled notification for medication ID: $medicationId');
  }

Future<void> monitorMedicationInventory() async {
  FirebaseFirestore.instance
      .collection('medications')
      .snapshots()
      .listen((snapshot) {
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final medicationId = doc.id;
      final medicationName = data['name'] ?? 'Medication';
      final currentInventory = data['current_inventory'] ?? 0;
      final refillThreshold = data['refill_threshold'] ?? 0;
      final bool refillReminderEnabled = data['refill_reminder_enabled'] ?? false;
      final refillReminderTime = data['refill_reminder_time']; // This could be a string (e.g. "3:30 PM")

      if (refillReminderEnabled) {
        if (currentInventory <= refillThreshold) {
          // If refill reminder time exists, parse it
          if (refillReminderTime == null || refillReminderTime.isEmpty) {
            debugPrint('Refill reminder time is null or empty for $medicationName.');
            continue;
          }

          // Parse the refill reminder time (assuming it's in "hh:mm AM/PM" format)
          final TimeOfDay? refillTime = parseTimeOfDay(refillReminderTime);

          if (refillTime == null) {
            debugPrint('Invalid refill reminder time format for $medicationName.');
            continue;
          }

          debugPrint(
              'Inventory low for $medicationName. Current: $currentInventory, Threshold: $refillThreshold');
          
          // Schedule the refill reminder notification
          scheduleRefillReminder(
            medicationId,
            medicationName,
            refillThreshold,
            refillTime, // Pass the parsed TimeOfDay to scheduleRefillReminder
          );
        } else {
          debugPrint('$medicationName inventory is sufficient. No refill reminder needed.');
        }
      }
    }
  });
}



Future<void> scheduleRefillReminder(
  String medicationId,
  String medicationName,
  int refillThreshold,
  TimeOfDay? refillReminderTime,
) async {
  if (refillReminderTime == null) return;

  try {
    int hour = refillReminderTime.hour;
    int minute = refillReminderTime.minute;
    int uniqueId = medicationId.hashCode + 10000;

    debugPrint('Scheduling refill reminder for $medicationName at $hour:$minute.');

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: uniqueId,
        channelKey: 'refill_channel',
        title: 'Refill Reminder',
        body: 'Your inventory for $medicationName is below $refillThreshold. Time to refill!',
        category: NotificationCategory.Reminder,
        wakeUpScreen: true,
        payload: {'medicationId': medicationId},
      ),
      schedule: NotificationCalendar(
        hour: hour,
        minute: minute,
        second: 0,
        repeats: false,
        allowWhileIdle: true,
      ),
    );

    debugPrint('Refill reminder scheduled successfully for $medicationName.');
  } catch (e) {
    debugPrint('Error scheduling refill reminder: $e');
  }
}


TimeOfDay? parseTimeOfDay(String time) {
  final RegExp timeRegex = RegExp(r'(\d+):(\d+)\s*(AM|PM)', caseSensitive: false);
  final Match? match = timeRegex.firstMatch(time);

  if (match == null) {
    return null; // Invalid format
  }

  int hour = int.parse(match.group(1)!);
  final int minute = int.parse(match.group(2)!);
  final String period = match.group(3)!.toUpperCase();

  // Convert to 24-hour format
  if (period == 'PM' && hour != 12) {
    hour += 12;
  } else if (period == 'AM' && hour == 12) {
    hour = 0;
  }

  return TimeOfDay(hour: hour, minute: minute);
}

}
