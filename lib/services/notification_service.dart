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
    String medicationId, String medicationName, String reminderTime) async {
  try {
    debugPrint('Received reminder time: $reminderTime');

    // Parse time in "3:57 AM" format
    final RegExp timeRegex = RegExp(r'(\d+):(\d+)\s*(AM|PM)', caseSensitive: false);
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

    // Show rescheduled time in 24-hour format
    // debugPrint('Rescheduled notification time: ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}');

    // Create notification schedule with daily repeat
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: medicationId.hashCode,
        channelKey: 'medication_channel',
        title: 'Medicine Reminder',
        body: 'Time to take $medicationName',
        category: NotificationCategory.Reminder,
        wakeUpScreen: true,
        payload: {'medicationId': medicationId},
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

    debugPrint('Notification scheduled successfully for daily repeat');
  } catch (e) {
    debugPrint('Error scheduling notification: $e');
  }
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

  Future<void> cancelNotification(int id) async {
    try {
      await AwesomeNotifications().cancel(id);
    } catch (e) {
      debugPrint('Error canceling notification: $e');
    }
  }
}