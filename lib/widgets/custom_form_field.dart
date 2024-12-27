import 'package:flutter/material.dart';
import 'package:medicine_reminder/constants/styles.dart';

class CustomFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? errorText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const CustomFormField({
    Key? key,
    required this.controller,
    required this.label,
    this.errorText,
    this.keyboardType,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppStyles.padding),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: AppStyles.getInputDecoration(label, errorText),
      ),
    );
  }
}