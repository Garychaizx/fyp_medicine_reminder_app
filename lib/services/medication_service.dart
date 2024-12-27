import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicine_reminder/models/medication.dart';
import 'package:medicine_reminder/services/notification_service.dart';

class MedicationService {
  final FirebaseFirestore _firestore;
  final NotificationService _notificationService;

  MedicationService({
    FirebaseFirestore? firestore,
    NotificationService? notificationService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _notificationService = notificationService ?? NotificationService();

  Future<void> addMedication(Medication medication) async {
    try {
      // Add to Firestore
      final docRef = await _firestore
          .collection('medications')
          .add(medication.toMap());

      // Schedule notifications
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
    } catch (e) {
      throw Exception('Failed to add medication: $e');
    }
  }

  Future<void> updateMedication(
    String medicationId,
    Map<String, dynamic> updatedData,
  ) async {
    await _firestore.collection('medications').doc(medicationId).update(updatedData);
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
}