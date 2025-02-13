import 'package:flutter/material.dart';
import 'package:medicine_reminder/add_medication_form.dart';
import 'package:medicine_reminder/constants/styles.dart';
import 'package:medicine_reminder/widgets/custom_form_field.dart'; // Adjust the import based on your project structure
import 'package:medicine_reminder/widgets/custom_dropdown.dart'; // Adjust the import based on your project structure

class Step1 extends StatelessWidget {
  final FormData formData;
  final VoidCallback onNext;
  final bool hasAttempted;

  const Step1({super.key, required this.formData, required this.onNext, required this.hasAttempted});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Image.asset('assets/medication.png', height: 150, fit: BoxFit.contain),
          ),
          CustomFormField(
            controller: formData.medicationNameController,
            label: 'Medication Name',
            errorText: hasAttempted && formData.medicationNameController.text.isEmpty
                ? 'Medication name is required'
                : null,
          ),
          CustomDropdown(
            value: formData.unit,
            items: const ['ml', 'pill(s)', 'gram(s)', 'spray(s)'],
            onChanged: (value) => formData.unit = value,
            label: 'Unit',
            errorText: hasAttempted && formData.unit == null ? 'Please select a unit' : null,
          ),
          CustomFormField(
            controller: formData.inventoryController,
            label: 'Current Inventory (Amounts)',
            keyboardType: TextInputType.number,
            errorText: hasAttempted && formData.inventoryController.text.isEmpty
                ? 'Current Inventory is required'
                : null,
          ),
          SizedBox(
            width: 380,
            child: ElevatedButton(
              onPressed: onNext,
              style: AppStyles.primaryButtonStyle,
              child: const Text('Next'),
            ),
          ),
        ],
      ),
    );
  }
}