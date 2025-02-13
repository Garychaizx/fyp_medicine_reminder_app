import 'package:cloud_firestore/cloud_firestore.dart';

class Medication {
  final String name;
  final String unit;
  final String frequency;
  final List<String> reminderTimes;
  final int doseQuantity;
  final int currentInventory;
  final String userUid;
  final bool refillReminderEnabled;
  final int? refillThreshold;
  final String? refillReminderTime;

  Medication({
    required this.name,
    required this.unit,
    required this.frequency,
    required this.reminderTimes,
    required this.doseQuantity,
    required this.currentInventory,
    required this.userUid,
    required this.refillReminderEnabled,
    this.refillThreshold,
    this.refillReminderTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'unit': unit,
      'frequency': frequency,
      'reminder_times': reminderTimes,
      'dose_quantity': doseQuantity,
      'current_inventory': currentInventory,
      'user_uid': userUid,
      'refill_reminder_enabled': refillReminderEnabled,
      'refill_threshold': refillThreshold,
      'refill_reminder_time': refillReminderTime,
      'created_at': FieldValue.serverTimestamp(),
    };
  }
}
