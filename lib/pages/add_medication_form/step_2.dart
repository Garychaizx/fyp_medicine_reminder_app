import 'package:flutter/material.dart';
import 'package:medicine_reminder/add_medication_form.dart';
import 'package:medicine_reminder/constants/styles.dart';
import 'package:medicine_reminder/widgets/frequency_options.dart'; // Adjust the import based on your project structure

class Step2 extends StatefulWidget {
  final FormData formData;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final bool hasAttempted;

  const Step2({
    super.key,
    required this.formData,
    required this.onNext,
    required this.onBack,
    required this.hasAttempted,
  });

  @override
  _Step2State createState() => _Step2State();
}

class _Step2State extends State<Step2> {
  bool hasAttempted = false; // Track if user tried to proceed without selecting

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/medication.png',
                    height: 150, fit: BoxFit.contain),
                const Text(
                  "How often do you take this medication?",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Column(
            children: [
              {'title': 'Once a Day', 'count': 1},
              {'title': 'Twice a Day', 'count': 2},
              {'title': 'Three Times a Day', 'count': 3},
              {'title': 'I need more options...', 'count': null},
            ]
                .map((option) => Container(
                      width: MediaQuery.of(context).size.width * 0.95,
                      child: FrequencyOption(
                        title: option['title'] as String,
                        isSelected:
                            widget.formData.frequency == option['title'],
                        onTap: () {
                          setState(() {
                            widget.formData.frequency =
                                option['title'] as String;
                            hasAttempted =
                                false; // Remove error once user selects
                            if (option['count'] != null) {
                              widget.formData.reminderTimes = List.generate(
                                  option['count'] as int, (_) => null);
                            }
                          });
                        },
                      ),
                    ))
                .toList(),
          ),
          if (hasAttempted && widget.formData.frequency == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Please select a frequency',
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: 380,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (widget.formData.frequency == null) {
                      setState(() {
                        hasAttempted = true; // Trigger error message
                      });
                    } else {
                      widget.onNext();
                    }
                  },
                  style: AppStyles.primaryButtonStyle,
                  child: const Text('Next'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      // Reset the data of this step
                      widget.formData.frequency = null;
                      widget.formData.reminderTimes = [];
                      hasAttempted = false;
                    });
                    widget.onBack(); // Go back to the previous step
                  },
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
}
