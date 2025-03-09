// import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:medicine_reminder/constants/styles.dart';
import 'package:medicine_reminder/services/medication_service.dart';
import 'package:medicine_reminder/widgets/custom_dropdown.dart';
// import 'package:medicine_reminder/widgets/custom_dropdown.dart';
import 'package:medicine_reminder/widgets/custom_form_field.dart';
// import 'package:medicine_reminder/services/notification_service.dart';
// import 'package:medicine_reminder/widgets/custom_text_field.dart';
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
  final ImagePicker _picker = ImagePicker();
  File? medicationImage;
  String? imageBase64;

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
    refillReminderTime = storedTime != null ? _parseTime(storedTime) : null;

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
      await _loadImageFromBase64(imageBase64!);
    }
  }

  Future<void> _loadImageFromBase64(String base64String) async {
    Uint8List imageBytes = base64Decode(base64String);

    // Create a unique filename every time
    Directory tempDir = await getTemporaryDirectory();
    String uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}.png';
    File imageFile = File('${tempDir.path}/$uniqueFileName');

    // Write the image to a new file
    await imageFile.writeAsBytes(imageBytes);

    setState(() {
      medicationImage = imageFile; // Update the UI with the new image
    });
  }

  bool _isPickingImage = false; // Track if image picker is in use

  Future<void> _pickImage() async {
    if (_isPickingImage) return; // Prevent multiple taps
    _isPickingImage = true; // Mark picker as active

    try {
      final XFile? pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          medicationImage = File(pickedFile.path);
          imageBase64 = base64Encode(medicationImage!.readAsBytesSync());
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    } finally {
      _isPickingImage = false; // Reset flag after picking
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
            ? _formatTime(refillReminderTime!)
            : null,
      };

      await _medicationService.cancelReminders(widget.medicationId);

      if (_frequency == "Every X Hours") {
        updatedData['interval_starting_time'] = startTimeController.text;
        updatedData['interval_ending_time'] = endTimeController.text;
        updatedData['interval_hour'] =
            int.tryParse(intervalHoursController.text) ?? 0;

        await _medicationService.scheduleIntervalReminders(
          medicationId: widget.medicationId,
          medicationName: nameController.text,
          startTime: startTimeController.text,
          endTime: endTimeController.text,
          intervalHours: int.tryParse(intervalHoursController.text) ?? 0,
          doseQuantity: int.parse(doseQuantityController.text),
          unit: widget.medicationData['unit'],
        );
      } else {
        updatedData['reminder_times'] =
            reminderTimeControllers.map((c) => c.text).toList();

        _medicationService.scheduleReminders(
          medicationId: widget.medicationId,
          medicationName: nameController.text,
          reminderTimes: reminderTimeControllers.map((c) => c.text).toList(),
          doseQuantity: int.parse(doseQuantityController.text),
          unit: widget.medicationData['unit'],
        );
      }

      await _medicationService.updateMedication(
          widget.medicationId, updatedData);
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
    final dateTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
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
      appBar: AppBar(title: Text('Edit Medication')),
      body: SingleChildScrollView(
        // padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Column(
              children: [
                // const Text(
                //   'Medication Photo (Optional)',
                //   style: TextStyle(fontSize: 16),
                // ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickImage, // Function to pick an image
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade200,
                    ),
                    child: medicationImage != null
                        ? Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  medicationImage!,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      medicationImage = null;
                                      imageBase64 = null;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                    child: const Icon(Icons.cancel,
                                        color: Colors.red, size: 20),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.photo_camera,
                                  size: 40, color: Colors.grey),
                              const SizedBox(height: 8),
                              Text(
                                "Tap to upload",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                  ),
                ),
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
                TimeOfDay? currentTime = _parseTime(controller.text);

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
                time: _parseTime(startTimeController.text),
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
                time: _parseTime(endTimeController.text),
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
