import 'package:flutter/material.dart';
import 'package:medicine_reminder/constants/styles.dart';
import '../services/medication_service.dart';
import '../add_medication_form.dart';

class AddMedicationButton extends StatelessWidget {
  const AddMedicationButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddMedicationForm(medicationService: MedicationService()),
              ),
            );
          },
          style: AppStyles.primaryButtonStyle,
          child: const Text('Add Medication'),
        ),
      ),
    );
  }
}
