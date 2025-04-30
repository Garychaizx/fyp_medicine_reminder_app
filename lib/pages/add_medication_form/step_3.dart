import 'package:flutter/material.dart';
import 'package:medicine_reminder/constants/styles.dart';
import 'package:medicine_reminder/widgets/hour_picker_modal.dart';

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
  int _hourInterval = 1;

  final List<String> _options = [
    'Multiple times daily',
    'Every X Hours',
    // 'Every X Days',
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

      if (option == 'Every X Hours') {
        widget.formData.frequencyDetails = _hourInterval; // Default interval
        widget.formData.hourInterval = _hourInterval; // Default interval
      } else {
        widget.formData.frequencyDetails = null;
      }

      _errorText = null; // Clear error when user selects an option
    });
  }

  // void _updateHourInterval(int value) {
  //   setState(() {
  //     _hourInterval = value;
  //     widget.formData.frequencyDetails = value;
  //   });
  // }

  void _showHourPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return HourPickerModal(
          initialValue: _hourInterval,
          onValueSelected: (selectedValue) {
            setState(() {
              _hourInterval = selectedValue; // Update state with selected value
            });
          },
        );
      },
    );
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
                    'assets/step3.png',
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
                                ? Color.fromARGB(255, 56, 26, 3)
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
                                    ? Colors.black
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
                              activeColor: Color.fromARGB(255, 56, 26, 3),
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
                                 value: _timesOptions.contains(_timesPerDay) ? _timesPerDay : null,
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
                    if (isSelected && option == 'Every X Hours') ...[
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Interval (hours):",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromARGB(255, 11, 24, 66),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: _showHourPicker,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(249, 168, 108, 62),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text("Every $_hourInterval hours"),
                                ),
                              ],
                            ),
                          )),
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