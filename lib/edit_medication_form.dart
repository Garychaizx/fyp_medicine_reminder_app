import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:medicine_reminder/constants/styles.dart';
import 'package:medicine_reminder/services/image_service.dart';
import 'package:medicine_reminder/services/medication_service.dart';
import 'package:medicine_reminder/widgets/custom_dropdown.dart';
import 'package:medicine_reminder/widgets/custom_form_field.dart';
import 'package:medicine_reminder/widgets/medication_image_picker.dart';
import 'package:medicine_reminder/widgets/reminder_time_picker.dart';
import 'package:path_provider/path_provider.dart';

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
  late TextEditingController startTimeController;
  late TextEditingController endTimeController;
  late TextEditingController intervalHoursController;
  bool isEveryXHours = false;
  TextEditingController numberOfRemindersController = TextEditingController();
  String? _selectedNumberOfReminders;
  final List<String> _numberOfRemindersOptions = ['4', '5', '6', '7'];
  // final ImagePicker _picker = ImagePicker();
  File? medicationImage;
  String? imageBase64;
  final _imageService = ImageService();

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

    // Initialize refill reminder fields OUTSIDE the loop
    refillReminderEnabled =
        widget.medicationData['refill_reminder_enabled'] ?? false;
    refillThresholdController = TextEditingController(
        text: widget.medicationData['refill_threshold']?.toString() ?? '');
    String? storedTime = widget.medicationData['refill_reminder_time'];
    refillReminderTime = storedTime != null
        ? _medicationService.parseTimeString(storedTime)
        : null;

    // Set up reminder time controllers based on existing reminder times
    List<String> existingTimes =
        List<String>.from(widget.medicationData['reminder_times'] ?? []);
    if (existingTimes.isEmpty) {
      existingTimes
          .add(''); // Ensure there's at least one default empty controller
    }
    for (String time in existingTimes) {
      reminderTimeControllers.add(TextEditingController(text: time));
    }
    if (widget.medicationData['imageBase64'] != null) {
      imageBase64 = widget.medicationData['imageBase64'];
      _loadImage(); // Call the function properly
    }
    // Initialize interval-related controllers
    startTimeController = TextEditingController(
      text: widget.medicationData['interval_starting_time'] ?? '',
    );
    endTimeController = TextEditingController(
      text: widget.medicationData['interval_ending_time'] ?? '',
    );
    intervalHoursController = TextEditingController(
      text: widget.medicationData['interval_hour']?.toString() ?? '',
    );
  }

// Function to decode base64 and convert it into a file
  Future<void> _loadImage() async {
    if (imageBase64 != null) {
      medicationImage = await _imageService.loadImageFromBase64(imageBase64!);
      setState(() {});
    }
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
        'frequency': _frequency,
        'current_inventory': int.tryParse(currentInventoryController.text) ?? 0,
        'dose_quantity': int.tryParse(doseQuantityController.text) ?? 0,
        'refill_threshold': int.tryParse(refillThresholdController.text) ?? 0,
        'refill_reminder_enabled': refillReminderEnabled,
        'imageBase64': imageBase64,
        'refill_reminder_time': refillReminderTime != null
            ? _medicationService.formatTimeOfDay(refillReminderTime!, context)
            : null,
      };

      await _medicationService.saveMedication(
        medicationId: widget.medicationId,
        medicationData: updatedData,
        isEveryXHours: _frequency == "Every X Hours",
        medicationName: nameController.text,
        reminderTimes: reminderTimeControllers.map((c) => c.text).toList(),
        doseQuantity: int.parse(doseQuantityController.text),
        unit: widget.medicationData['unit'],
        startTime: startTimeController.text,
        endTime: endTimeController.text,
        intervalHours: int.tryParse(intervalHoursController.text),
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

  void _updateReminderControllers() {
    switch (_frequency) {
      case 'Once a Day':
        reminderTimeControllers = [TextEditingController()];
        break;
      case 'Twice a Day':
        reminderTimeControllers = [
          TextEditingController(),
          TextEditingController()
        ];
        break;
      case 'Three Times a Day':
        reminderTimeControllers = [
          TextEditingController(),
          TextEditingController(),
          TextEditingController()
        ];
        break;
      case 'Multiple times daily':
        int numberOfReminders =
            int.tryParse(_selectedNumberOfReminders ?? '4') ??
                4; // Default to 4 if not selected
        reminderTimeControllers = List.generate(
            numberOfReminders, (index) => TextEditingController());
        break;
      case 'Every X Hours':
        // Don't show reminder time pickers for this case as it has a different layout
        reminderTimeControllers = [];
        break;
      default:
        reminderTimeControllers = [];
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4F1),
      appBar: AppBar(
        title: const Text(
          "Edit Medications",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: const Color(0xFFF8F4F1),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        // padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Column(
              children: [
                MedicationImagePicker(
                    medicationImage: medicationImage,
                    onImagePicked: (File image, String base64) {
                      setState(() {
                        medicationImage = image;
                        imageBase64 = base64;
                      });
                    },
                    onImageRemoved: () {
                      setState(() {
                        medicationImage = null;
                        imageBase64 = null;
                      });
                    }),
              ],
            ),
            const SizedBox(height: 16),
            // Medication Name
            CustomFormField(
              controller: nameController,
              label: 'Medication Name',
              errorText: _hasAttemptedSubmit && nameController.text.isEmpty
                  ? 'Required'
                  : null,
            ),
            // Frequency
            // const SizedBox(height: 16),
            CustomDropdown(
              value: _frequency,
              items: const [
                'Once a Day',
                'Twice a Day',
                'Three Times a Day',
                'Multiple times daily',
                'Every X Hours'
              ],
              onChanged: (value) {
                setState(() {
                  _frequency = value;
                  _updateReminderControllers();
                  // _updateReminderTimeFields();
                });
              },
              label: 'Frequency',
              errorText: _hasAttemptedSubmit && _frequency == null
                  ? 'Please select a frequency'
                  : null,
            ),
            // Number of Reminders Dropdown (only for 'Multiple times daily')
            if (_frequency == "Multiple times daily") ...[
              CustomDropdown(
                value: _selectedNumberOfReminders,
                items: _numberOfRemindersOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedNumberOfReminders = value;
                    _updateReminderControllers();
                  });
                },
                label: 'Number of Reminders',
                errorText:
                    _hasAttemptedSubmit && _selectedNumberOfReminders == null
                        ? 'Required'
                        : null,
              ),
            ],
            // Reminder Times
            if (_frequency != "Every X Hours") ...[
              ...reminderTimeControllers.asMap().entries.map((entry) {
                int index = entry.key;
                TextEditingController controller = entry.value;
                TimeOfDay? currentTime =
                    _medicationService.parseTimeString(controller.text);

                return ReminderTimePicker(
                  index: index,
                  time: currentTime,
                  hasAttempted: _hasAttemptedSubmit,
                  onSelect: (selectedTime) {
                    setState(() {
                      controller.text = selectedTime?.format(context) ?? '';
                    });
                  },
                );
              }).toList(),
            ],

            if (_frequency == "Every X Hours") ...[
              ReminderTimePicker(
                index: 0,
                time: _medicationService
                    .parseTimeString(startTimeController.text),
                hasAttempted: _hasAttemptedSubmit,
                onSelect: (selectedTime) {
                  setState(() {
                    startTimeController.text =
                        selectedTime?.format(context) ?? '';
                  });
                },
              ),
              ReminderTimePicker(
                index: 1,
                time:
                    _medicationService.parseTimeString(endTimeController.text),
                hasAttempted: _hasAttemptedSubmit,
                onSelect: (selectedTime) {
                  setState(() {
                    endTimeController.text =
                        selectedTime?.format(context) ?? '';
                  });
                },
              ),
              CustomFormField(
                controller: intervalHoursController,
                label: 'Interval (Hours)',
                keyboardType: TextInputType.number,
                errorText:
                    _hasAttemptedSubmit && intervalHoursController.text.isEmpty
                        ? 'Required'
                        : null,
              ),
            ],
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
              activeColor: const Color(0xFF34C759),
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
                  SizedBox(height: 16),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
