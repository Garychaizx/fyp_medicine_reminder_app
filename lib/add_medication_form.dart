import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medicine_reminder/constants/styles.dart';
import 'package:medicine_reminder/models/medication.dart';
import 'package:medicine_reminder/pages/add_medication_form/step_1.dart';
import 'package:medicine_reminder/pages/add_medication_form/step_2.dart';
import 'package:medicine_reminder/pages/add_medication_form/step_3.dart';
import 'package:medicine_reminder/pages/add_medication_form/step_4.dart';
import 'package:medicine_reminder/services/medication_service.dart'; // Adjust the import based on your project structure
import 'package:medicine_reminder/widgets/custom_form_field.dart'; // Adjust the import based on your project structure
import 'package:medicine_reminder/widgets/custom_dropdown.dart'; // Adjust the import based on your project structure
import 'package:medicine_reminder/widgets/reminder_time_picker.dart'; // Adjust the import based on your project structure
import 'package:medicine_reminder/widgets/frequency_options.dart'; // Adjust the import based on your project structure
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

  bool get isStep1Valid =>
      medicationNameController.text.isNotEmpty && unit != null && inventoryController.text.isNotEmpty;

  bool get isStep2Valid =>
      frequency != null;

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
    reminderTimes = [null];  // Default to one reminder if not set
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
      reminderTimes:
          reminderTimes.map((time) => time?.format(context) ?? '').toList(),
      doseQuantity: doseQuantity!,
      currentInventory: inventoryValue,
      userUid: currentUser.uid,
      refillReminderEnabled: refillReminderEnabled,
      refillThreshold: refillThreshold,
      refillReminderTime: refillReminderTime?.format(context),
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
      appBar: AppBar(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
  return Align(
    alignment: Alignment.topCenter,  // Ensures the new widget aligns properly
    child: SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0), // Slide in from right
        end: Offset.zero, 
      ).animate(animation),
      child: child,
    ),
  );
},

        child: _buildStep(_currentPage), // Ensures only one child is displayed at a time
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
    _navigationHistory.add(_currentPage); // Save the current page before moving forward

    if (_currentPage == 0) {
      _hasAttemptedStep1 = true;
      if (_formData.isStep1Valid) {
        _currentPage++;
      }
    } else if (_currentPage == 1) {
      _hasAttemptedStep2 = true;
      if (_formData.isStep2Valid) {
        _currentPage += (_formData.frequency == "I need more options...") ? 1 : 2;
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
      _currentPage = _navigationHistory.removeLast(); // Go back to the last visited page
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







  // Widget _buildStep1() {
  //   return SingleChildScrollView(
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         // Add an image above the form content
  //         Padding(
  //           padding: const EdgeInsets.only(bottom: 16.0),
  //           child: Image.asset(
  //             'assets/medication.png', // Replace with your image path
  //             height: 150, // Adjust the height as needed
  //             fit: BoxFit.contain,
  //           ),
  //         ),
  //         CustomFormField(
  //           controller: _formData.medicationNameController,
  //           label: 'Medication Name',
  //           errorText: _hasAttemptedStep1 &&
  //                   _formData.medicationNameController.text.isEmpty
  //               ? 'Medication name is required'
  //               : null,
  //         ),
  //         CustomDropdown(
  //           value: _formData.unit,
  //           items: const ['ml', 'pill(s)', 'gram(s)', 'spray(s)'],
  //           onChanged: (value) => setState(() => _formData.unit = value),
  //           label: 'Unit',
  //           errorText: _hasAttemptedStep1 && _formData.unit == null
  //               ? 'Please select a unit'
  //               : null,
  //         ),
  //         CustomFormField(
  //           controller: _formData.inventoryController,
  //           label: 'Current Inventory (Amounts)',
  //           keyboardType: TextInputType.number,
  //           errorText:
  //               _hasAttemptedStep1 && _formData.inventoryController.text.isEmpty
  //                   ? 'Current Inventory is required'
  //                   : null,
  //         ),
  //         SizedBox(
  //           width: 380,
  //           child: ElevatedButton(
  //             onPressed: _nextPage,
  //             style: AppStyles.primaryButtonStyle,
  //             child: const Text('Next'),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildStep2() {
  //   return SingleChildScrollView(
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Padding(
  //           padding: const EdgeInsets.only(bottom: 16.0),
  //           child: Image.asset(
  //             'assets/medication.png', // Replace with your image path
  //             height: 150, // Adjust the height as needed
  //             fit: BoxFit.contain,
  //           ),
  //         ),
  //         // CustomDropdown(
  //         //   value: _formData.frequency,
  //         //   items: const ['Once a Day', 'Twice a Day', 'Three Times a Day'],
  //         //   onChanged: (value) {
  //         //     setState(() {
  //         //       _formData.frequency = value;
  //         //       _formData.updateReminderTimes();
  //         //     });
  //         //   },
  //         //   label: 'Frequency',
  //         //   errorText: _hasAttemptedStep2 && _formData.frequency == null
  //         //       ? 'Please select a frequency'
  //         //       : null,
  //         // ),
  //         // Frequency selection using _FrequencyOption
  //         Column(
  //           children: [
  //             'Once a Day',
  //             'Twice a Day',
  //             'Three Times a Day',
  //             'I need more options...'
  //           ]
  //               .map((option) => Container(
  //                     width: MediaQuery.of(context).size.width *
  //                         0.95, // 60% of screen width
  //                     child: FrequencyOption(
  //                       title: option,
  //                       isSelected: _formData.frequency == option,
  //                       onTap: () {
  //                         setState(() {
  //                           _formData.frequency = option;
  //                           _formData.updateReminderTimes();
  //                         });
  //                       },
  //                     ),
  //                   ))
  //               .toList(),
  //         ),

  //         if (_hasAttemptedStep2 && _formData.frequency == null)
  //           const Padding(
  //             padding: EdgeInsets.symmetric(vertical: 8),
  //             child: Text(
  //               'Please select a frequency',
  //               style: TextStyle(color: Colors.red, fontSize: 14),
  //             ),
  //           ),
  //         // CustomFormField(
  //         //   controller: _formData.inventoryController,
  //         //   label: 'Current Inventory (Amounts)',
  //         //   keyboardType: TextInputType.number,
  //         //   errorText:
  //         //       _hasAttemptedStep2 && _formData.inventoryController.text.isEmpty
  //         //           ? 'Current Inventory is required'
  //         //           : null,
  //         // ),
  //         // Add padding between selections and buttons
  //         const SizedBox(height: 12), // Adjust height as needed
  //         SizedBox(
  //           width: 380, // Fixed width for the button group
  //           child: Column(
  //             children: [
  //               ElevatedButton(
  //                 onPressed: _nextPage,
  //                 style: AppStyles.primaryButtonStyle,
  //                 child: const Text('Next'),
  //               ),
  //               const SizedBox(height: 16), // Add spacing between buttons
  //               ElevatedButton(
  //                 onPressed: _previousPage,
  //                 style: AppStyles.secondaryButtonStyle,
  //                 child: const Text('Back'),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildStep3() {
  //   return Column(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       const Padding(
  //         padding: EdgeInsets.all(16.0),
  //         child: Text(
  //           "Select a Custom Frequency",
  //           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  //         ),
  //       ),
  //       Column(
  //         children: [
  //           'Every 4 Hours',
  //           'Every 6 Hours',
  //           'Every 8 Hours',
  //           'Every 12 Hours'
  //         ]
  //             .map((option) => Container(
  //                   width: MediaQuery.of(context).size.width * 0.95,
  //                   child: FrequencyOption(
  //                     title: option,
  //                     isSelected: _formData.frequency == option,
  //                     onTap: () {
  //                       setState(() {
  //                         _formData.frequency = option;
  //                       });
  //                     },
  //                   ),
  //                 ))
  //             .toList(),
  //       ),
  //       const SizedBox(height: 20),

  //       // Proceed button to go to Step 3
  //       ElevatedButton(
  //         onPressed: () {
  //           if (_formData.frequency != "I need more options...") {
  //             _nextPage(); // Proceed to Step 3
  //           }
  //         },
  //         style: AppStyles.primaryButtonStyle,
  //         child: const Text('Next'),
  //       ),
  //       const SizedBox(height: 16),
  //       ElevatedButton(
  //         onPressed: _previousPage,
  //         style: AppStyles.secondaryButtonStyle,
  //         child: const Text('Back'),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildStep4() {
  //   return SingleChildScrollView(
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Padding(
  //           padding: const EdgeInsets.only(bottom: 16.0),
  //           child: Image.asset(
  //             'assets/medication.png', // Replace with your image path
  //             height: 150, // Adjust the height as needed
  //             fit: BoxFit.contain,
  //           ),
  //         ),
  //         for (int i = 0; i < _formData.reminderTimes.length; i++)
  //           ReminderTimePicker(
  //             index: i,
  //             time: _formData.reminderTimes[i],
  //             hasAttempted: _hasAttemptedStep3,
  //             onSelect: (time) {
  //               setState(() => _formData.reminderTimes[i] = time);
  //             },
  //           ),
  //         CustomFormField(
  //           controller: _formData.doseQuantityController,
  //           label: 'Dose Quantity',
  //           keyboardType: TextInputType.number,
  //           errorText: _hasAttemptedStep3 &&
  //                   _formData.doseQuantityController.text.isEmpty
  //               ? 'Please enter dose quantity'
  //               : null,
  //           onChanged: (value) {
  //             setState(() {
  //               _formData.doseQuantity =
  //                   value.isEmpty ? null : int.tryParse(value);
  //             });
  //           },
  //         ),
  //         SwitchListTile(
  //           title: const Text('Refill Reminder'),
  //           value: _formData.refillReminderEnabled,
  //           onChanged: (value) {
  //             setState(() {
  //               _formData.refillReminderEnabled = value;
  //               if (!value) {
  //                 _formData.refillThreshold = null;
  //                 _formData.refillReminderTime = null;
  //               }
  //             });
  //           },
  //         ),
  //         if (_formData.refillReminderEnabled) ...[
  //           CustomFormField(
  //             controller: _formData.refillThresholdController,
  //             label: 'Refill Reminder Threshold (Inventory)',
  //             keyboardType: TextInputType.number,
  //             errorText: _hasAttemptedStep3 && _formData.refillThreshold == null
  //                 ? 'Please enter a refill threshold'
  //                 : null,
  //             onChanged: (value) {
  //               setState(() {
  //                 _formData.refillThreshold = _formData.refillThreshold =
  //                     value.isEmpty ? null : int.tryParse(value);
  //                 value.isEmpty ? null : int.tryParse(value);
  //               });
  //             },
  //           ),
  //           ReminderTimePicker(
  //             index: 0, // Not using index here, just for refill reminder time
  //             time: _formData.refillReminderTime,
  //             hasAttempted: _hasAttemptedStep3,
  //             // label: 'Refill Reminder Time',
  //             onSelect: (time) {
  //               setState(() => _formData.refillReminderTime = time);
  //             },
  //           ),
  //         ],
  //         SizedBox(
  //           width: 380,
  //           child: Column(
  //             children: [
  //               ElevatedButton(
  //                 onPressed: _handleSubmit,
  //                 style: AppStyles.submitButtonStyle,
  //                 child: const Text('Submit'),
  //               ),
  //               const SizedBox(height: 16),
  //               ElevatedButton(
  //                 onPressed: _previousPage,
  //                 style: AppStyles.secondaryButtonStyle,
  //                 child: const Text('Back'),
  //               ),
  //             ],
  //           ),
  //         )
  //       ],
  //     ),
  //   );
  // }