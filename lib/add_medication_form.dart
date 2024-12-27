import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medicine_reminder/constants/styles.dart';
import 'package:medicine_reminder/models/medication.dart';
import 'package:medicine_reminder/services/medication_service.dart'; // Adjust the import based on your project structure
import 'package:medicine_reminder/widgets/custom_form_field.dart'; // Adjust the import based on your project structure
import 'package:medicine_reminder/widgets/custom_dropdown.dart'; // Adjust the import based on your project structure
import 'package:medicine_reminder/widgets/reminder_time_picker.dart'; // Adjust the import based on your project structure
// import 'package:medicine_reminder/styles/app_styles.dart'; // Adjust the import based on your project structure

class FormData {
  final TextEditingController medicationNameController =
      TextEditingController();
  final TextEditingController inventoryController = TextEditingController();
  final TextEditingController doseQuantityController = TextEditingController();
  String? unit;
  String? frequency;
  List<TimeOfDay?> reminderTimes = [null];
  int? doseQuantity;

  bool get isStep1Valid =>
      medicationNameController.text.isNotEmpty && unit != null;

  bool get isStep2Valid =>
      frequency != null && inventoryController.text.isNotEmpty;

  bool get isStep3Valid =>
      doseQuantity != null && reminderTimes.every((time) => time != null);

  void updateReminderTimes() {
    if (frequency == "Twice a Day") {
      reminderTimes = [null, null];
    } else if (frequency == "Three Times a Day") {
      reminderTimes = [null, null, null];
    } else {
      reminderTimes = [null];
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
  }

  Medication toMedication(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('User  not logged in');

    return Medication(
      name: medicationNameController.text,
      unit: unit!,
      frequency: frequency!,
      reminderTimes:
          reminderTimes.map((time) => time?.format(context) ?? '').toList(),
      doseQuantity: doseQuantity!,
      currentInventory: inventoryController.text,
      userUid: currentUser.uid,
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
  final PageController _pageController = PageController();
  final FormData _formData = FormData();

  int _currentPage = 0;
  bool _hasAttemptedStep1 = false;
  bool _hasAttemptedStep2 = false;
  bool _hasAttemptedStep3 = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (page) => setState(() => _currentPage = page),
        children: [
          _buildStep1(),
          _buildStep2(),
          _buildStep3(),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Add an image above the form content
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Image.asset(
              'assets/medication.png', // Replace with your image path
              height: 150, // Adjust the height as needed
              fit: BoxFit.contain,
            ),
          ),
          CustomFormField(
            controller: _formData.medicationNameController,
            label: 'Medication Name',
            errorText: _hasAttemptedStep1 &&
                    _formData.medicationNameController.text.isEmpty
                ? 'Medication name is required'
                : null,
          ),
          CustomDropdown(
            value: _formData.unit,
            items: const ['ml', 'pill(s)', 'gram(s)', 'spray(s)'],
            onChanged: (value) => setState(() => _formData.unit = value),
            label: 'Unit',
            errorText: _hasAttemptedStep1 && _formData.unit == null
                ? 'Please select a unit'
                : null,
          ),
          SizedBox(
            width: 380,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: AppStyles.primaryButtonStyle,
              child: const Text('Next'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Image.asset(
              'assets/medication.png', // Replace with your image path
              height: 150, // Adjust the height as needed
              fit: BoxFit.contain,
            ),
          ),
          CustomDropdown(
            value: _formData.frequency,
            items: const ['Daily', 'Twice a Day', 'Three Times a Day'],
            onChanged: (value) {
              setState(() {
                _formData.frequency = value;
                _formData.updateReminderTimes();
              });
            },
            label: 'Frequency',
            errorText: _hasAttemptedStep2 && _formData.frequency == null
                ? 'Please select a frequency'
                : null,
          ),
          CustomFormField(
            controller: _formData.inventoryController,
            label: 'Current Inventory (Amounts)',
            errorText:
                _hasAttemptedStep2 && _formData.inventoryController.text.isEmpty
                    ? 'Current Inventory is required'
                    : null,
          ),
          SizedBox(
            width: 380, // Fixed width for the button group
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: _nextPage,
                  style: AppStyles.primaryButtonStyle,
                  child: const Text('Next'),
                ),
                const SizedBox(height: 16), // Add spacing between buttons
                ElevatedButton(
                  onPressed: _previousPage,
                  style: AppStyles.secondaryButtonStyle,
                  child: const Text('Back'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Image.asset(
              'assets/medication.png', // Replace with your image path
              height: 150, // Adjust the height as needed
              fit: BoxFit.contain,
            ),
          ),
          for (int i = 0; i < _formData.reminderTimes.length; i++)
            ReminderTimePicker(
              index: i,
              time: _formData.reminderTimes[i],
              hasAttempted: _hasAttemptedStep3,
              onSelect: (time) {
                setState(() => _formData.reminderTimes[i] = time);
              },
            ),
          CustomFormField(
            controller: _formData.doseQuantityController,
            label: 'Dose Quantity',
            keyboardType: TextInputType.number,
            errorText: _hasAttemptedStep3 &&
                    _formData.doseQuantityController.text.isEmpty
                ? 'Please enter dose quantity'
                : null,
            onChanged: (value) {
              setState(() {
                _formData.doseQuantity =
                    value.isEmpty ? null : int.tryParse(value);
              });
            },
          ),
          SizedBox(
            width: 380,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: _handleSubmit,
                  style: AppStyles.submitButtonStyle,
                  child: const Text('Submit'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _previousPage,
                  style: AppStyles.secondaryButtonStyle,
                  child: const Text('Back'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _nextPage() {
    if (_currentPage == 0) {
      setState(() => _hasAttemptedStep1 = true);
      if (_formData.isStep1Valid) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    } else if (_currentPage == 1) {
      setState(() => _hasAttemptedStep2 = true);
      if (_formData.isStep2Valid) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    } else if (_currentPage == 2) {
      setState(() => _hasAttemptedStep3 = true);
      if (_formData.isStep3Valid) {
        _handleSubmit();
      }
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  void _handleSubmit() {
    setState(() {
      _hasAttemptedStep3 = true; // Set this to true when attempting to submit
    });
    if (_formData.isStep3Valid) {
      // Handle the submission logic here
      final medication = _formData.toMedication(context);
      widget.medicationService.addMedication(medication);
      _formData.clear();
      Navigator.pop(context);
    }
  }
}
