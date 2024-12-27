import 'package:cloud_firestore/cloud_firestore.dart';

class Medication {
  final String name;
  final String unit;
  final String frequency;
  final List<String> reminderTimes;
  final int doseQuantity;
  final String currentInventory;
  final String userUid;

  Medication({
    required this.name,
    required this.unit,
    required this.frequency,
    required this.reminderTimes,
    required this.doseQuantity,
    required this.currentInventory,
    required this.userUid,
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
      'created_at': FieldValue.serverTimestamp(),
    };
  }
}