import 'package:flutter/material.dart';

class AddMedicationForm extends StatefulWidget {
  @override
  _AddMedicationFormState createState() => _AddMedicationFormState();
}

class _AddMedicationFormState extends State<AddMedicationForm> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final _medicationNameController = TextEditingController();
  final _unitController = TextEditingController();
  String? _frequency;
  TimeOfDay? _reminderTime;
  int? _doseQuantity;

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
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
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _medicationNameController,
                  decoration: InputDecoration(labelText: 'Medication Name'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _unitController,
                  decoration: InputDecoration(labelText: 'Unit (e.g., mg, ml)'),
                ),
              ),
              ElevatedButton(
                onPressed: _nextPage,
                child: const Text('Next'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(
                      400, 40),
                  backgroundColor: const Color.fromARGB(255, 27, 50, 126),
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 18, // Font size
                    fontWeight: FontWeight.bold, // Font weight
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
                padding: const EdgeInsets.all(16.0),
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
                  decoration: InputDecoration(labelText: 'Frequency'),
                ),
              ),
              ElevatedButton(
                onPressed: _nextPage,
                child: const Text('Next'),
              ),
              ElevatedButton(
                onPressed: _previousPage,
                child: const Text('Back'),
              ),
            ],
          ),
          // Step 3: Time and Dose Quantity
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _selectTime(context),
                child: const Text('Select Reminder Time'),
              ),
              if (_reminderTime != null)
                Text(
                    'Selected time: ${_reminderTime?.format(context)}'), // Display selected time
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _doseQuantity = int.tryParse(value);
                  },
                  decoration: InputDecoration(labelText: 'Dose Quantity'),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Submit the form
                  // Do something with the input values
                  print('Medication Name: ${_medicationNameController.text}');
                  print('Unit: ${_unitController.text}');
                  print('Frequency: $_frequency');
                  print('Reminder Time: ${_reminderTime?.format(context)}');
                  print('Dose Quantity: $_doseQuantity');
                  Navigator.pop(context); // Close the form after submission
                },
                child: const Text('Submit'),
              ),
              ElevatedButton(
                onPressed: _previousPage,
                child: const Text('Back'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
