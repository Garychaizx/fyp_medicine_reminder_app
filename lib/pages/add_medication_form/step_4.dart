import 'package:flutter/material.dart';
import 'package:medicine_reminder/constants/styles.dart';
import 'package:medicine_reminder/widgets/custom_form_field.dart';
import 'package:medicine_reminder/widgets/reminder_time_picker.dart';

class Step4 extends StatefulWidget {
  final dynamic formData;
  final VoidCallback handleSubmit;
  final VoidCallback onBack;

  const Step4({
    Key? key,
    required this.formData,
    required this.handleSubmit,
    required this.onBack,
  }) : super(key: key);

  @override
  _Step4State createState() => _Step4State();
}

class _Step4State extends State<Step4> {
  bool hasAttempted = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Image.asset(
              'assets/medication.png',
              height: 150,
              fit: BoxFit.contain,
            ),
          ),
          Column(
  children: List.generate(
    widget.formData.reminderTimes.length, // Dynamically generate inputs
    (index) => ReminderTimePicker(
      index: index,
      time: widget.formData.reminderTimes[index],
      hasAttempted: hasAttempted,
      onSelect: (time) {
        setState(() {
          widget.formData.reminderTimes[index] = time; // Update selected time
        });
      },
    ),
  ),
),

          CustomFormField(
            controller: widget.formData.doseQuantityController,
            label: 'Dose Quantity',
            keyboardType: TextInputType.number,
            errorText: hasAttempted &&
                    widget.formData.doseQuantityController.text.isEmpty
                ? 'Please enter dose quantity'
                : null,
            onChanged: (value) {
              setState(() {
                widget.formData.doseQuantity =
                    value.isEmpty ? null : int.tryParse(value);
              });
            },
          ),
          SwitchListTile(
            title: const Text('Refill Reminder'),
            value: widget.formData.refillReminderEnabled,
            onChanged: (value) {
              setState(() {
                widget.formData.refillReminderEnabled = value;
                if (!value) {
                  widget.formData.refillThreshold = null;
                  widget.formData.refillReminderTime = null;
                }
              });
            },
          ),
          if (widget.formData.refillReminderEnabled) ...[
            CustomFormField(
              controller: widget.formData.refillThresholdController,
              label: 'Refill Reminder Threshold (Inventory)',
              keyboardType: TextInputType.number,
              errorText: hasAttempted && widget.formData.refillThreshold == null
                  ? 'Please enter a refill threshold'
                  : null,
              onChanged: (value) {
                setState(() {
                  widget.formData.refillThreshold =
                      value.isEmpty ? null : int.tryParse(value);
                });
              },
            ),
            ReminderTimePicker(
              index: 0,
              time: widget.formData.refillReminderTime,
              hasAttempted: hasAttempted,
              onSelect: (time) {
                setState(() => widget.formData.refillReminderTime = time);
              },
            ),
          ],
          SizedBox(
            width: 380,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      hasAttempted = true;
                    });
                    widget.handleSubmit();
                  },
                  style: AppStyles.submitButtonStyle,
                  child: const Text('Submit'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: widget.onBack,
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
}
