import 'package:flutter/material.dart';
import 'package:medicine_reminder/constants/styles.dart';

class ReminderTimePicker extends StatelessWidget {
  final int index;
  final TimeOfDay? time;
  final bool hasAttempted;
  final ValueChanged<TimeOfDay?> onSelect;

  const ReminderTimePicker({
    Key? key,
    required this.index,
    required this.time,
    required this.hasAttempted,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                    time != null
                        ? 'Reminder Time ${index + 1}: ${time?.format(context)}'
                        : 'Select Reminder Time ${index + 1}',
                    style: TextStyle(
                      fontSize: 16,
                      color: time != null ? Colors.black : Colors.grey[700],
                    ),
                  ),
                  Icon(Icons.access_time, color: AppStyles.primaryColor),
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
    );
    if (picked != null && picked != time) {
      onSelect(picked);
    }
  }
}

