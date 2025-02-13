import 'package:flutter/material.dart';
import 'package:medicine_reminder/constants/styles.dart';

class Step3 extends StatefulWidget {
  final dynamic formData;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Step3({
    Key? key,
    required this.formData,
    required this.onNext,
    required this.onBack,
  }) : super(key: key);

  @override
  _Step3State createState() => _Step3State();
}

class _Step3State extends State<Step3> {
  String? _selectedFrequency;
  int? _timesPerDay;
  String? _errorText; // Error message for validation

  final List<String> _options = [
    'Multiple times daily',
    'Every X Hours',
    'Every X Days',
  ];

  final List<int> _timesOptions = [4, 5, 6, 7];

  @override
  void initState() {
    super.initState();
    _selectedFrequency = null;
    _timesPerDay = widget.formData.frequencyDetails;
  }

  void _updateSelection(String? option) {
    setState(() {
      _selectedFrequency = option;
      widget.formData.frequency = option;

      if (option != 'Multiple times daily') {
        _timesPerDay = null;
        widget.formData.frequencyDetails = null;
      }

      _errorText = null; // Clear error when user selects an option
    });
  }

  void _updateTimesPerDay(int value) {
    setState(() {
      _timesPerDay = value;
      widget.formData.frequencyDetails = value;
      widget.formData.updateReminderTimes();
    });
  }

  void _clearStep3Data() {
    setState(() {
      _selectedFrequency = null;
      _timesPerDay = null;
      _errorText = null; // Clear error when resetting
      widget.formData.frequency = null;
      widget.formData.frequencyDetails = null;
      widget.formData.reminderTimes = <TimeOfDay>[]; // Clear reminder times
    });
  }

  void _handleBack() {
    _clearStep3Data();
    widget.onBack();
  }

  void _validateAndProceed() {
    if (_selectedFrequency == null) {
      setState(() {
        _errorText = "Please select a frequency."; // Show error if no frequency is selected
      });
    } else if (_selectedFrequency == 'Multiple times daily' && _timesPerDay == null) {
      setState(() {
        _errorText = "Please select how many times per day."; // Show error if times per day is not selected
      });
    } else {
      setState(() {
        _errorText = null; // Clear any previous error messages
      });
      widget.onNext(); // Proceed to the next step
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/medication.png',
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Which of these options works for your medication schedule?",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Column(
              children: _options.map((option) {
                bool isSelected = _selectedFrequency == option;
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _updateSelection(null);
                          } else {
                            _updateSelection(option);
                          }
                        });
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.95,
                        margin: const EdgeInsets.symmetric(vertical: 6.0),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 16.0),
                        decoration: BoxDecoration(
                          color:
                              isSelected ? Colors.grey.shade300 : Colors.white,
                          border: Border.all(
                            color: isSelected
                                ? Color.fromARGB(255, 11, 24, 66)
                                : Colors.grey,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              option,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Color.fromARGB(255, 11, 24, 66)
                                    : Colors.black,
                              ),
                            ),
                            Switch(
                              value: isSelected,
                              onChanged: (bool selected) {
                                setState(() {
                                  if (isSelected) {
                                    _updateSelection(null);
                                  } else {
                                    _updateSelection(option);
                                  }
                                });
                              },
                              activeColor: Color.fromARGB(255, 11, 24, 66),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isSelected && option == 'Multiple times daily') ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "How many times per day?",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: DropdownButton<int>(
                                value: _timesPerDay,
                                hint: const Text("Select"),
                                isExpanded: true,
                                underline: const SizedBox(),
                                items: _timesOptions.map((int value) {
                                  return DropdownMenuItem<int>(
                                    value: value,
                                    child: Text("$value times per day"),
                                  );
                                }).toList(),
                                onChanged: (int? newValue) {
                                  if (newValue != null) {
                                    _updateTimesPerDay(newValue);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                );
              }).toList(),
            ),
            if (_errorText != null) // Show error message if validation fails
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _errorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _validateAndProceed,
              style: AppStyles.primaryButtonStyle,
              child: const Text('Next'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _handleBack,
              style: AppStyles.secondaryButtonStyle,
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}