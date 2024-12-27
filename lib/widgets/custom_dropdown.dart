import 'package:flutter/material.dart';
import 'package:medicine_reminder/constants/styles.dart';

class CustomDropdown extends StatelessWidget {
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String label;
  final String? errorText;

  const CustomDropdown({
    Key? key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.label,
    this.errorText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppStyles.padding),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: AppStyles.getInputDecoration(label, errorText),
      ),
    );
  }
}