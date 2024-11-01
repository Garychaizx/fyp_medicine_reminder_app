import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// constant for decorations
const double _padding = 20.0;
const double _borderRadius = 12.0;
const _primaryColor = Color.fromARGB(255, 27, 50, 126);

class AddMedicationForm extends StatefulWidget {
  @override
  _AddMedicationFormState createState() => _AddMedicationFormState();
}

class _AddMedicationFormState extends State<AddMedicationForm> {
  final PageController _pageController = PageController();

  //constant variables
  int _currentPage = 0;

  final _inventoryController = TextEditingController();
  final _medicationNameController = TextEditingController();
  final _doseQuantityController = TextEditingController();
  String? _unit;
  String? _frequency;
  TimeOfDay? _reminderTime;
  int? _doseQuantity;

  // Track if user has tried to proceed to the next step (to show validation)
  bool _hasAttemptedStep1 = false;
  bool _hasAttemptedStep2 = false;
  bool _hasAttemptedStep3 = false;

  // Functions
  // Function to validate fields on the first step
  bool _isStep1Valid() {
    return _medicationNameController.text.isNotEmpty && _unit != null;
  }

  // Function to validate fields on the second step
  bool _isStep2Valid() {
    return _frequency != null && _inventoryController.text.isNotEmpty;
  }

  // Function to validate fields on the third step
  bool _isStep3Valid() {
    return _reminderTime != null && _doseQuantity != null;
  }

  void _nextPage() {
    if (_currentPage == 0) {
      setState(() {
        _hasAttemptedStep1 = true; // Mark that the user attempted step 1
      });
      if (_isStep1Valid()) {
        _pageController.nextPage(
            duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
      }
    } else if (_currentPage == 1) {
      setState(() {
        _hasAttemptedStep2 = true; // Mark that the user attempted step 2
      });
      if (_isStep2Valid()) {
        _pageController.nextPage(
            duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
      }
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
          duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  // Add these helper methods here
  InputDecoration _getInputDecoration(String label, String? errorText) {
    return InputDecoration(
      labelText: label,
      errorText: errorText,
      labelStyle: TextStyle(color: Colors.grey[700]),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        borderSide: BorderSide(color: _primaryColor, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  // Common dropdown decoration
  InputDecoration _getDropdownDecoration(String label, String? errorText) {
    return InputDecoration(
      labelText: label,
      errorText: errorText,
      labelStyle: TextStyle(color: Colors.grey[700]),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        borderSide: BorderSide(color: _primaryColor, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // title: const Text('Add Medication'),
          // backgroundColor: Colors.blue[100],
          ),
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(), // Disable swipe navigation
        onPageChanged: (int page) {
          setState(() {
            _currentPage = page;
          });
        },
        children: [
          // Step 1: Name and Unit
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(_padding),
                child: TextField(
                  controller: _medicationNameController,
                  decoration: _getInputDecoration(
                    'Medication Name',
                    _hasAttemptedStep1 && _medicationNameController.text.isEmpty
                        ? 'Medication name is required'
                        : null,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: DropdownButtonFormField<String>(
                  value: _unit,
                  items: ['ml', 'pill(s)', 'gram(s)', 'spray(s)']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _unit = value;
                    });
                  },
                  decoration: _getDropdownDecoration(
                    'Unit',
                    _hasAttemptedStep1 && _unit == null
                        ? 'Please select a unit'
                        : null,
                  ),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _nextPage,
                child: const Text('Next'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(400, 40),
                  backgroundColor: const Color.fromARGB(255, 27, 50, 126),
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 18, // Font size
                    fontWeight: FontWeight.bold,
                    inherit: false, // Font weight
                  ), // Set width to full-width and height to 40
                ),
              )
            ],
          ),
          // Step 2: Frequency
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(_padding),
                child: DropdownButtonFormField<String>(
                  value: _frequency,
                  items: ['Daily', 'Weekly', 'Monthly'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _frequency = value;
                    });
                  },
                  decoration: _getInputDecoration(
                    'Frequency',
                    _hasAttemptedStep2 && _frequency == null
                        ? 'Please select a frequency'
                        : null,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(_padding),
                child: TextField(
                  controller: _inventoryController,
                  decoration: _getInputDecoration(
                    'Current Inventory (Amounts)',
                    _hasAttemptedStep2 && _inventoryController.text.isEmpty
                        ? 'Current Inventory is required'
                        : null,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _nextPage,
                child: const Text('Next'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(400, 40),
                  backgroundColor: const Color.fromARGB(255, 27, 50, 126),
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 18, // Font size
                    fontWeight: FontWeight.bold, // Font weight
                  ), // Set width to full-width and height to 40
                ),
              ),
              ElevatedButton(
                onPressed: _previousPage,
                child: const Text('Back'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(400, 40),
                  backgroundColor:
                      Colors.blueGrey.shade200, // Subtle grayish blue
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 18, // Font size
                    fontWeight: FontWeight.bold, // Font weight
                  ), // Set width to full-width and height to 40
                ),
              ),
            ],
          ),
          // Step 3: Time and Dose Quantity
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(_padding),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: (_hasAttemptedStep3 && _reminderTime == null)
                              ? Colors
                                  .red // Show red border if validation fails
                              : Colors.grey[300]!,
                        ),
                        borderRadius: BorderRadius.circular(_borderRadius),
                        color: Colors.grey[50],
                      ),
                      child: InkWell(
                        onTap: () => _selectTime(context),
                        borderRadius: BorderRadius.circular(_borderRadius),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _reminderTime != null
                                    ? 'Reminder Time: ${_reminderTime?.format(context)}'
                                    : 'Select Reminder Time',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _reminderTime != null
                                      ? Colors.black
                                      : Colors.grey[700],
                                ),
                              ),
                              Icon(
                                Icons.access_time,
                                color: _primaryColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_hasAttemptedStep3 && _reminderTime == null)
                      const Padding(
                        padding: EdgeInsets.only(top: 8, left: 12),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Please select a reminder time',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    if (_reminderTime != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Selected time: ${_reminderTime?.format(context)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(_padding),
                child: TextField(
                  controller: _doseQuantityController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _doseQuantity =
                          value.isEmpty ? null : int.tryParse(value);
                    });
                  },
                  decoration: _getInputDecoration(
                    'Dose Quantity',
                    (_hasAttemptedStep3 && _doseQuantityController.text.isEmpty)
                        ? 'Please enter dose quantity'
                        : null,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _hasAttemptedStep3 =
                        true; // Mark that user attempted to submit
                  });

                  if (_isStep3Valid()) {
                    if (_medicationNameController.text.isNotEmpty &&
                        _unit != null &&
                        _frequency != null &&
                        _reminderTime != null &&
                        _doseQuantity != null) {
                      Map<String, dynamic> medicationData = {
                        'name': _medicationNameController.text,
                        'unit': _unit,
                        'frequency': _frequency,
                        'reminder_time': _reminderTime?.format(context),
                        'dose_quantity': _doseQuantity,
                        'created_at': FieldValue.serverTimestamp(),
                        'current_inventory': _inventoryController.text
                      };

                      try {
                        await FirebaseFirestore.instance
                            .collection('medications')
                            .add(medicationData);

                        _medicationNameController.clear();
                        _unit = null;
                        _inventoryController.clear();
                        _frequency = null;
                        _reminderTime = null;
                        _doseQuantity = null;

                        Navigator.pop(context);
                      } catch (e) {
                        print('Error adding medication: $e');
                      }
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please fill all required fields')),
                    );
                  }
                },
                child: const Text('Submit'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(400, 40),
                  backgroundColor: Colors.teal[700],
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _previousPage,
                child: const Text('Back'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(400, 40),
                  backgroundColor: Colors.blue[200],
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
