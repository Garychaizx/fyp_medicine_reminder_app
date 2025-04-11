import 'package:flutter/material.dart';
import 'package:medicine_reminder/constants/styles.dart';

class ReminderTimePicker extends StatelessWidget {
  final int index;
  final TimeOfDay? time;
  final bool hasAttempted;
  final Function(TimeOfDay?) onSelect;
  final String? customLabel; // Add this parameter

  const ReminderTimePicker({
    Key? key,
    required this.index,
    required this.time,
    required this.hasAttempted,
    required this.onSelect,
    this.customLabel, // Add this parameter
  }) : super(key: key);

@override
Widget build(BuildContext context) {
  // Determine what text to display based on whether customLabel is provided
  String displayText;
  String placeholderText;
  
  if (customLabel != null) {
    displayText = time != null ? '$customLabel: ${time?.format(context)}' : 'Select $customLabel';
    placeholderText = 'Select $customLabel';
  } else {
    displayText = time != null ? 'Reminder Time ${index + 1}: ${time?.format(context)}' : 'Select Reminder Time ${index + 1}';
    placeholderText = 'Select Reminder Time ${index + 1}';
  }

  return Padding(
    padding: const EdgeInsets.all(AppStyles.padding),
    child: SizedBox(
      width: double.infinity,
      child: InkWell(
        onTap: () => _selectTime(context),
        borderRadius: BorderRadius.circular(AppStyles.borderRadius),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: (hasAttempted && time == null)
                  ? Colors.red
                  : Colors.grey[300]!,
            ),
            borderRadius: BorderRadius.circular(AppStyles.borderRadius),
            color: Colors.grey[50],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  displayText,
                  style: TextStyle(
                    fontSize: 16,
                    color: time != null ? Colors.black : Colors.grey[700],
                  ),
                ),
                const Icon(Icons.access_time, color: AppStyles.primaryColor),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

 Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: time ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color.fromARGB(255, 241, 227, 217), // Secondary button background color
              onPrimary: Colors.black, // Secondary button text color
              onSurface: Colors.black, // Text color on the surface
               secondary: Color.fromARGB(255, 44, 20, 3), // AM/PM button background color
            onSecondary: Colors.white, // AM/PM button text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color.fromARGB(255, 56, 26, 3), // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != time) {
      onSelect(picked);
    }
  }
}

