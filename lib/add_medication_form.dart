import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:medicine_reminder/constants/styles.dart';
import 'package:medicine_reminder/models/medication.dart';
import 'package:medicine_reminder/pages/add_medication_form/step_1.dart';
import 'package:medicine_reminder/pages/add_medication_form/step_2.dart';
import 'package:medicine_reminder/pages/add_medication_form/step_3.dart';
import 'package:medicine_reminder/pages/add_medication_form/step_4.dart';
import 'package:medicine_reminder/services/medication_service.dart'; // Adjust the import based on your project structure
// import 'package:medicine_reminder/widgets/custom_form_field.dart'; // Adjust the import based on your project structure
// import 'package:medicine_reminder/widgets/custom_dropdown.dart'; // Adjust the import based on your project structure
// import 'package:medicine_reminder/widgets/reminder_time_picker.dart'; // Adjust the import based on your project structure
// import 'package:medicine_reminder/widgets/frequency_options.dart'; // Adjust the import based on your project structure
// import 'package:medicine_reminder/styles/app_styles.dart'; // Adjust the import based on your project structure

class FormData {
  final TextEditingController medicationNameController =
      TextEditingController();
  final TextEditingController inventoryController = TextEditingController();
  final TextEditingController doseQuantityController = TextEditingController();
  final TextEditingController refillThresholdController =
      TextEditingController();
  String? unit;
  String? frequency;
  List<TimeOfDay?> reminderTimes = [null];
  int? doseQuantity;
  bool refillReminderEnabled = false;
  int? refillThreshold;
  TimeOfDay? refillReminderTime;
  int? frequencyDetails; // Fix: Add this property
  int? hourInterval; // Fix: Add this property
  TimeOfDay? startingTime;
  TimeOfDay? endingTime;
  File? medicationImage;
  String? imageBase64;

  bool get isStep1Valid =>
      medicationNameController.text.isNotEmpty &&
      unit != null &&
      inventoryController.text.isNotEmpty;

  bool get isStep2Valid => frequency != null;

  bool get isStep3Valid {
    final refillReminderValid = !refillReminderEnabled ||
        (refillReminderEnabled &&
            refillThreshold != null &&
            refillReminderTime != null);
    return doseQuantity != null &&
        reminderTimes.every((time) => time != null) &&
        refillReminderValid;
  }

  // void updateReminderTimes() {
  //   if (frequency == "Twice a Day") {
  //     reminderTimes = [null, null];
  //   } else if (frequency == "Three Times a Day") {
  //     reminderTimes = [null, null, null];
  //   } else {
  //     reminderTimes = [null];
  //   }
  // }

  void updateReminderTimes() {
    if (frequencyDetails != null && frequencyDetails! > 0) {
      reminderTimes = List.filled(frequencyDetails!, null);
    } else {
      reminderTimes = [null]; // Default to one reminder if not set
    }
  }

  void clear() {
    medicationNameController.clear();
    inventoryController.clear();
    doseQuantityController.clear();
    unit = null;
    frequency = null;
    reminderTimes = [null];
    doseQuantity = null;
    refillReminderEnabled = false;
    refillThreshold = null;
    refillReminderTime = null;
  }

  Medication toMedication(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('User  not logged in');

    // Parse the inventory text to int and handle invalid input gracefully
    final inventoryValue = int.tryParse(inventoryController.text) ?? 0;
    return Medication(
      name: medicationNameController.text,
      unit: unit!,
      frequency: frequency!,
      reminderTimes:reminderTimes.map((time) => time?.format(context) ?? '').toList(),
      doseQuantity: doseQuantity!,
      currentInventory: inventoryValue,
      userUid: currentUser.uid,
      refillReminderEnabled: refillReminderEnabled,
      refillThreshold: refillThreshold,
      refillReminderTime: refillReminderTime?.format(context),
      startingTime: startingTime?.format(context), // Convert TimeOfDay to String
      endingTime: endingTime?.format(context), // Convert TimeOfDay to String
      hourInterval: hourInterval,
      imageBase64: imageBase64,
    );
  }
}

class AddMedicationForm extends StatefulWidget {
  final MedicationService medicationService;

  const AddMedicationForm({
    Key? key,
    required this.medicationService,
  }) : super(key: key);

  @override
  _AddMedicationFormState createState() => _AddMedicationFormState();
}

class _AddMedicationFormState extends State<AddMedicationForm> {
  final FormData _formData = FormData();
  final List<int> _navigationHistory = [];

  int _currentPage = 0;
  bool _hasAttemptedStep1 = false;
  bool _hasAttemptedStep2 = false;
  bool _hasAttemptedStep3 = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         backgroundColor: const Color(0xFFF8F4F1),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return Align(
            alignment:
                Alignment.topCenter, // Ensures the new widget aligns properly
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0), // Slide in from right
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },

        child: _buildStep(
            _currentPage), // Ensures only one child is displayed at a time
      ),
    );
  }

  Widget _buildStep(int step) {
    switch (step) {
      case 0:
        return Step1(
          key: ValueKey(0),
          formData: _formData,
          hasAttempted: _hasAttemptedStep1,
          onNext: _nextPage,
        );
      case 1:
        return Step2(
          key: ValueKey(1),
          formData: _formData,
          hasAttempted: _hasAttemptedStep2,
          onNext: _nextPage,
          onBack: _previousPage,
        );
      case 2:
        return Step3(
          key: ValueKey(2),
          formData: _formData,
          onNext: _nextPage,
          onBack: _previousPage,
        );
      case 3:
        return Step4(
          key: ValueKey(3),
          formData: _formData,
          handleSubmit: _handleSubmit,
          onBack: _previousPage,
        );
      default:
        return Container(); // Fallback
    }
  }

  void _nextPage() {
    setState(() {
      _navigationHistory
          .add(_currentPage); // Save the current page before moving forward

      if (_currentPage == 0) {
        _hasAttemptedStep1 = true;
        if (_formData.isStep1Valid) {
          _currentPage++;
        }
      } else if (_currentPage == 1) {
        _hasAttemptedStep2 = true;
        if (_formData.isStep2Valid) {
          _currentPage +=
              (_formData.frequency == "I need more options...") ? 1 : 2;
        }
      } else if (_currentPage == 2) {
        _currentPage++;
      } else if (_currentPage == 3) {
        _hasAttemptedStep3 = true;
        if (_formData.isStep3Valid) {
          _handleSubmit();
        }
      }
    });
  }

  void _previousPage() {
    setState(() {
      if (_navigationHistory.isNotEmpty) {
        _currentPage =
            _navigationHistory.removeLast(); // Go back to the last visited page
      }
    });
  }

  void _handleSubmit() {
    setState(() {
      _hasAttemptedStep3 = true;
    });
    if (_formData.isStep3Valid) {
      final medication = _formData.toMedication(context);
      widget.medicationService.addMedication(medication);
      _formData.clear();
      Navigator.pop(context);
    }
  }
}
