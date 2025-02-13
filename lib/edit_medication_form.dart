// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medicine_reminder/constants/styles.dart';
import 'package:medicine_reminder/services/medication_service.dart';
import 'package:medicine_reminder/widgets/custom_dropdown.dart';
import 'package:medicine_reminder/widgets/custom_form_field.dart';
// import 'package:medicine_reminder/services/notification_service.dart';
import 'package:medicine_reminder/widgets/custom_text_field.dart';
import 'package:medicine_reminder/widgets/reminder_time_picker.dart';

// Constants for decorations
const double _padding = 20.0;
const double _borderRadius = 12.0;
const _primaryColor = Color.fromARGB(255, 27, 50, 126);

class EditMedicationForm extends StatefulWidget {
  final String medicationId;
  final Map<String, dynamic> medicationData;

  const EditMedicationForm({
    Key? key,
    required this.medicationId,
    required this.medicationData,
  }) : super(key: key);

  @override
  _EditMedicationFormState createState() => _EditMedicationFormState();
}

class _EditMedicationFormState extends State<EditMedicationForm> {
  late TextEditingController nameController;
  late List<TextEditingController> reminderTimeControllers = [];
  late TextEditingController currentInventoryController;
  late TextEditingController doseQuantityController;
  String? _frequency;
  bool _hasAttemptedSubmit = false;
  late TextEditingController refillThresholdController;
  TimeOfDay? refillReminderTime;
  bool refillReminderEnabled = false;
  final _medicationService = MedicationService();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data
    nameController = TextEditingController(text: widget.medicationData['name']);
    _frequency = widget.medicationData['frequency'];
    currentInventoryController = TextEditingController(
        text: widget.medicationData['current_inventory']?.toString() ?? '');
    doseQuantityController = TextEditingController(
        text: widget.medicationData['dose_quantity']?.toString() ?? '');

    // Set up reminder time controllers based on existing reminder times
    List<String> existingTimes =
        List<String>.from(widget.medicationData['reminder_times'] ?? ['']);
    for (String time in existingTimes) {
      reminderTimeControllers.add(TextEditingController(text: time));
      // Initialize refill reminder fields
      refillReminderEnabled =
          widget.medicationData['refill_reminder_enabled'] ?? false;
      refillThresholdController = TextEditingController(
          text: widget.medicationData['refill_threshold']?.toString() ?? '');
      String? storedTime = widget.medicationData['refill_reminder_time'];
      refillReminderTime = storedTime != null ? _parseTime(storedTime) : null;
    }
  }

  void _updateReminderTimeFields() {
    int reminderCount = _frequency == 'Twice a Day'
        ? 2
        : _frequency == 'Three Times a Day'
            ? 3
            : 1;

    setState(() {
      while (reminderTimeControllers.length < reminderCount) {
        reminderTimeControllers.add(TextEditingController());
      }
      while (reminderTimeControllers.length > reminderCount) {
        reminderTimeControllers.removeLast();
      }
    });
  }

  Future<void> _saveMedication() async {
    if (nameController.text.isEmpty ||
        _frequency == null ||
        currentInventoryController.text.isEmpty ||
        doseQuantityController.text.isEmpty) {
      setState(() {
        _hasAttemptedSubmit = true;
      });
      return;
    }

    try {
      final updatedData = {
        'name': nameController.text,
        'reminder_times': reminderTimeControllers.map((c) => c.text).toList(),
        'frequency': _frequency,
        'current_inventory': int.tryParse(currentInventoryController.text) ?? 0,
        'dose_quantity': int.tryParse(doseQuantityController.text) ?? 0,
        'refill_threshold': int.tryParse(refillThresholdController.text) ?? 0,
        'refill_reminder_enabled': refillReminderEnabled,
        'refill_reminder_time': refillReminderTime != null
            ? _formatTime(refillReminderTime!)
            : null, // Ensure it's saved in "6:38 PM" format
      };

      await _medicationService.updateMedication(
          widget.medicationId, updatedData);
      _medicationService.scheduleReminders(
        medicationId: widget.medicationId,
        medicationName: nameController.text,
        reminderTimes: reminderTimeControllers.map((c) => c.text).toList(),
        doseQuantity: int.parse(doseQuantityController.text),
        unit: widget.medicationData['unit'],
      );
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Error saving medication: $e');
    }
  }

  Future<void> _deleteMedication() async {
    try {
      await _medicationService.deleteMedication(widget.medicationId);
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Error deleting medication: $e');
    }
  }

  String _formatTime(TimeOfDay time) {
  final now = DateTime.now();
  final dateTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
  return DateFormat.jm().format(dateTime); // Converts to "6:38 PM" format
}


TimeOfDay? _parseTime(String timeString) {
  try {
    // Normalize spaces (replace any non-breaking or narrow spaces with a standard space)
    timeString = timeString.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    print('Normalized Time String: $timeString'); // Debugging
    
    // Parse the time string into a TimeOfDay object
    final parts = timeString.split(' ');
    if (parts.length == 2) {
      final timeParts = parts[0].split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1].padLeft(2, '0'));
      bool isPM = parts[1].toUpperCase() == 'PM';

      // Convert to 24-hour format if necessary
      final adjustedHour = isPM && hour != 12 ? hour + 12 : hour;
      final finalHour = adjustedHour == 24 ? 0 : adjustedHour;

      return TimeOfDay(hour: finalHour, minute: minute);
    }
  } catch (e) {
    print('Error parsing time: $e');
  }
  return null;
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Medication')),
      body: SingleChildScrollView(
        // padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Medication Name
            CustomFormField(
              controller: nameController,
              label: 'Medication Name',
              errorText: _hasAttemptedSubmit && nameController.text.isEmpty
                  ? 'Required'
                  : null,
            ),

            // Reminder Times
            ...reminderTimeControllers.asMap().entries.map((entry) {
              int index = entry.key;
              TextEditingController controller = entry.value;
              // Pass the controller's text as the time value
              TimeOfDay? currentTime = _parseTime(controller.text);

              return SizedBox(
                width:
                    double.infinity, // Ensures the widget takes up full width
                child: ReminderTimePicker(
                  index: index,
                  time: currentTime, // Pass the current time to the widget
                  hasAttempted:
                      _hasAttemptedSubmit, // If you want to show error state
                  onSelect: (selectedTime) {
                    setState(() {
                      controller.text = selectedTime?.format(context) ??
                          ''; // Update controller text
                    });
                  },
                ),
              );
            }).toList(),

            // Frequency
            // const SizedBox(height: 16),
            // CustomDropdown(
            //   value: _frequency,
            //   items: const ['Once a Day', 'Twice a Day', 'Three Times a Day'],
            //   onChanged: (value) {
            //     setState(() {
            //       _frequency = value;
            //       _updateReminderTimeFields();
            //     });
            //   },
            //   label: 'Frequency',
            //   errorText: _hasAttemptedSubmit && _frequency == null
            //       ? 'Please select a frequency'
            //       : null,
            // ),

            // Current Inventory
            CustomFormField(
              controller: currentInventoryController,
              label: 'Current Inventory',
              errorText:
                  _hasAttemptedSubmit && currentInventoryController.text.isEmpty
                      ? 'Required'
                      : null,
              keyboardType: TextInputType.number,
            ),

            // Dose Quantity
            // const SizedBox(height: 16),
            CustomFormField(
              controller: doseQuantityController,
              label: 'Dose Quantity',
              errorText:
                  _hasAttemptedSubmit && doseQuantityController.text.isEmpty
                      ? 'Required'
                      : null,
              keyboardType: TextInputType.number,
            ),
            // Refill Reminder Toggle
            SwitchListTile(
              title: const Text('Refill Reminder'),
              value: refillReminderEnabled,
              onChanged: (value) {
                setState(() {
                  refillReminderEnabled = value;
                  if (!value) {
                    refillThresholdController.clear();
                    refillReminderTime = null;
                  }
                });
              },
            ),

            // Refill Reminder Fields
            if (refillReminderEnabled) ...[
              CustomFormField(
                controller: refillThresholdController,
                label: 'Refill Reminder Threshold (Inventory)',
                keyboardType: TextInputType.number,
                errorText: _hasAttemptedSubmit &&
                        refillThresholdController.text.isEmpty
                    ? 'Please enter a refill threshold'
                    : null,
              ),
              ReminderTimePicker(
                index: 0,
                time: refillReminderTime,
                hasAttempted: _hasAttemptedSubmit,
                onSelect: (time) {
                  setState(() => refillReminderTime = time);
                },
              ),
            ],

            SizedBox(
              width: 380,
              child: Column(
                children: [
                  // Save Button
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _hasAttemptedSubmit = true;
                      });

                      // Validate fields
                      if (nameController.text.isNotEmpty &&
                          _frequency != null &&
                          currentInventoryController.text.isNotEmpty &&
                          doseQuantityController.text.isNotEmpty) {
                        _saveMedication();
                      }
                    },
                    child: Text('Save Changes'),
                    style: AppStyles.primaryButtonStyle,
                  ),
                  //Delete Button
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _deleteMedication,
                    child: Text('Delete'),
                    style: AppStyles.deleteButtonStyle,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
