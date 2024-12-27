// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:medicine_reminder/services/notification_service.dart';

// // constant for decorations
// const double _padding = 20.0;
// const double _borderRadius = 12.0;
// const _primaryColor = Color.fromARGB(255, 27, 50, 126);

// class AddMedicationForm extends StatefulWidget {
//   @override
//   _AddMedicationFormState createState() => _AddMedicationFormState();
// }

// class _AddMedicationFormState extends State<AddMedicationForm> {
//   final PageController _pageController = PageController();

//   //constant variables
//   int _currentPage = 0;

//   final _inventoryController = TextEditingController();
//   final _medicationNameController = TextEditingController();
//   final _doseQuantityController = TextEditingController();
//   String? _unit;
//   String? _frequency;
//   // TimeOfDay? _reminderTime;
//   int? _doseQuantity;
//   List<TimeOfDay?> _reminderTimes = [null];

//   // Track if user has tried to proceed to the next step (to show validation)
//   bool _hasAttemptedStep1 = false;
//   bool _hasAttemptedStep2 = false;
//   bool _hasAttemptedStep3 = false;

//   // Functions
//   // Function to validate fields on the first step
//   bool _isStep1Valid() {
//     return _medicationNameController.text.isNotEmpty && _unit != null;
//   }

//   // Function to validate fields on the second step
//   bool _isStep2Valid() {
//     return _frequency != null && _inventoryController.text.isNotEmpty;
//   }

//   // Function to validate fields on the third step
//   bool _isStep3Valid() {
//     return _doseQuantity != null;
//   }

//   void _nextPage() {
//     if (_currentPage == 0) {
//       setState(() {
//         _hasAttemptedStep1 = true; // Mark that the user attempted step 1
//       });
//       if (_isStep1Valid()) {
//         _pageController.nextPage(
//             duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
//       }
//     } else if (_currentPage == 1) {
//       setState(() {
//         _hasAttemptedStep2 = true; // Mark that the user attempted step 2
//       });
//       if (_isStep2Valid()) {
//         _pageController.nextPage(
//             duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
//       }
//     }
//   }

//   void _previousPage() {
//     if (_currentPage > 0) {
//       _pageController.previousPage(
//           duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
//     }
//   }

//   void _updateReminderTimes() {
//     setState(() {
//       if (_frequency == "Twice a Day") {
//         _reminderTimes = [null, null];
//       } else if (_frequency == "Three Times a Day") {
//         _reminderTimes = [null, null, null];
//       } else {
//         _reminderTimes = [null];
//       }
//     });
//   }

// // Modified _selectTime function to pick specific times
//   Future<void> _selectTime(BuildContext context, int index) async {
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );
//     if (picked != null && picked != _reminderTimes[index]) {
//       setState(() {
//         _reminderTimes[index] = picked;
//       });
//     }
//   }

//   // Add these helper methods here
//   InputDecoration _getInputDecoration(String label, String? errorText) {
//     return InputDecoration(
//       labelText: label,
//       errorText: errorText,
//       labelStyle: TextStyle(color: Colors.grey[700]),
//       filled: true,
//       fillColor: Colors.grey[50],
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(_borderRadius),
//         borderSide: BorderSide(color: Colors.grey[300]!),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(_borderRadius),
//         borderSide: BorderSide(color: Colors.grey[300]!),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(_borderRadius),
//         borderSide: BorderSide(color: _primaryColor, width: 2),
//       ),
//       contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//     );
//   }

//   // Common dropdown decoration
//   InputDecoration _getDropdownDecoration(String label, String? errorText) {
//     return InputDecoration(
//       labelText: label,
//       errorText: errorText,
//       labelStyle: TextStyle(color: Colors.grey[700]),
//       filled: true,
//       fillColor: Colors.grey[50],
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(_borderRadius),
//         borderSide: BorderSide(color: Colors.grey[300]!),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(_borderRadius),
//         borderSide: BorderSide(color: Colors.grey[300]!),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(_borderRadius),
//         borderSide: BorderSide(color: _primaryColor, width: 2),
//       ),
//       contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//           // title: const Text('Add Medication'),
//           // backgroundColor: Colors.blue[100],
//           ),
//       body: PageView(
//         controller: _pageController,
//         physics: NeverScrollableScrollPhysics(), // Disable swipe navigation
//         onPageChanged: (int page) {
//           setState(() {
//             _currentPage = page;
//           });
//         },
//         children: [
//           // Step 1: Name and Unit
//           Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(_padding),
//                 child: TextField(
//                   controller: _medicationNameController,
//                   decoration: _getInputDecoration(
//                     'Medication Name',
//                     _hasAttemptedStep1 && _medicationNameController.text.isEmpty
//                         ? 'Medication name is required'
//                         : null,
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: DropdownButtonFormField<String>(
//                   value: _unit,
//                   items: ['ml', 'pill(s)', 'gram(s)', 'spray(s)']
//                       .map((String value) {
//                     return DropdownMenuItem<String>(
//                       value: value,
//                       child: Text(value),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       _unit = value;
//                     });
//                   },
//                   decoration: _getDropdownDecoration(
//                     'Unit',
//                     _hasAttemptedStep1 && _unit == null
//                         ? 'Please select a unit'
//                         : null,
//                   ),
//                 ),
//               ),
//               SizedBox(height: 24),
//               ElevatedButton(
//                 onPressed: _nextPage,
//                 child: const Text('Next'),
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: const Size(400, 40),
//                   backgroundColor: const Color.fromARGB(255, 27, 50, 126),
//                   foregroundColor: Colors.white,
//                   textStyle: const TextStyle(
//                     fontSize: 18, // Font size
//                     fontWeight: FontWeight.bold,
//                     inherit: false, // Font weight
//                   ), // Set width to full-width and height to 40
//                 ),
//               )
//             ],
//           ),
//           // Step 2: Frequency
//           Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(_padding),
//                 child: DropdownButtonFormField<String>(
//                   value: _frequency,
//                   items: ['Daily', 'Twice a Day', 'Three Times a Day']
//                       .map((String value) {
//                     return DropdownMenuItem<String>(
//                       value: value,
//                       child: Text(value),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       _frequency = value;
//                       _updateReminderTimes();
//                     });
//                   },
//                   decoration: _getInputDecoration(
//                     'Frequency',
//                     _hasAttemptedStep2 && _frequency == null
//                         ? 'Please select a frequency'
//                         : null,
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(_padding),
//                 child: TextField(
//                   controller: _inventoryController,
//                   decoration: _getInputDecoration(
//                     'Current Inventory (Amounts)',
//                     _hasAttemptedStep2 && _inventoryController.text.isEmpty
//                         ? 'Current Inventory is required'
//                         : null,
//                   ),
//                 ),
//               ),
//               ElevatedButton(
//                 onPressed: _nextPage,
//                 child: const Text('Next'),
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: const Size(400, 40),
//                   backgroundColor: const Color.fromARGB(255, 27, 50, 126),
//                   foregroundColor: Colors.white,
//                   textStyle: const TextStyle(
//                     fontSize: 18, // Font size
//                     fontWeight: FontWeight.bold, // Font weight
//                   ), // Set width to full-width and height to 40
//                 ),
//               ),
//               ElevatedButton(
//                 onPressed: _previousPage,
//                 child: const Text('Back'),
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: const Size(400, 40),
//                   backgroundColor:
//                       Colors.blueGrey.shade200, // Subtle grayish blue
//                   foregroundColor: Colors.white,
//                   textStyle: const TextStyle(
//                     fontSize: 18, // Font size
//                     fontWeight: FontWeight.bold, // Font weight
//                   ), // Set width to full-width and height to 40
//                 ),
//               ),
//             ],
//           ),
//           Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(_padding),
//                 child: Column(
//                   children: [
//                     // Display time pickers for each reminder time based on frequency
//                     for (int i = 0; i < _reminderTimes.length; i++)
//                       Padding(
//                         padding: const EdgeInsets.only(bottom: 8.0),
//                         child: Container(
//                           width: double.infinity,
//                           decoration: BoxDecoration(
//                             border: Border.all(
//                               color: (_hasAttemptedStep3 &&
//                                       _reminderTimes[i] == null)
//                                   ? Colors.red
//                                   : Colors.grey[300]!,
//                             ),
//                             borderRadius: BorderRadius.circular(_borderRadius),
//                             color: Colors.grey[50],
//                           ),
//                           child: InkWell(
//                             onTap: () => _selectTime(context, i),
//                             borderRadius: BorderRadius.circular(_borderRadius),
//                             child: Padding(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 16,
//                                 vertical: 16,
//                               ),
//                               child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     _reminderTimes[i] != null
//                                         ? 'Reminder Time ${i + 1}: ${_reminderTimes[i]?.format(context)}'
//                                         : 'Select Reminder Time ${i + 1}',
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       color: _reminderTimes[i] != null
//                                           ? Colors.black
//                                           : Colors.grey[700],
//                                     ),
//                                   ),
//                                   Icon(
//                                     Icons.access_time,
//                                     color: _primaryColor,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     if (_hasAttemptedStep3 &&
//                         _reminderTimes.any((time) => time == null))
//                       const Padding(
//                         padding: EdgeInsets.only(top: 8, left: 12),
//                         child: Align(
//                           alignment: Alignment.centerLeft,
//                           child: Text(
//                             'Please select all reminder times',
//                             style: TextStyle(
//                               color: Colors.red,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(_padding),
//                 child: TextField(
//                   controller: _doseQuantityController,
//                   keyboardType: TextInputType.number,
//                   onChanged: (value) {
//                     setState(() {
//                       _doseQuantity =
//                           value.isEmpty ? null : int.tryParse(value);
//                     });
//                   },
//                   decoration: _getInputDecoration(
//                     'Dose Quantity',
//                     (_hasAttemptedStep3 && _doseQuantityController.text.isEmpty)
//                         ? 'Please enter dose quantity'
//                         : null,
//                   ),
//                 ),
//               ),
//               ElevatedButton(
//                 onPressed: () async {
//                   setState(() {
//                     _hasAttemptedStep3 = true;
//                   });

//                   if (_isStep3Valid()) {
//                     if (_medicationNameController.text.isNotEmpty &&
//                         _unit != null &&
//                         _frequency != null &&
//                         // _reminderTimes.every((time) => time != null) &&
//                         _doseQuantity != null) {
//                       User? currentUser = FirebaseAuth.instance.currentUser;
//                       if (currentUser == null) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(content: Text('Error: User not logged in')),
//                         );
//                         return;
//                       }
//                       // Convert reminder times to strings
//                       List<String> reminderTimes = _reminderTimes
//                           .map((time) => time?.format(context) ?? '')
//                           .toList();

//                       Map<String, dynamic> medicationData = {
//                         'name': _medicationNameController.text,
//                         'unit': _unit,
//                         'frequency': _frequency,
//                         'reminder_times':
//                             reminderTimes, // Save multiple times to Firebase
//                         'dose_quantity': _doseQuantity,
//                         'created_at': FieldValue.serverTimestamp(),
//                         'current_inventory': _inventoryController.text,
//                         'user_uid': currentUser.uid
//                       };

//                       try {
//                         // Add medication to Firestore and retrieve the document ID
//                         DocumentReference docRef = await FirebaseFirestore
//                             .instance
//                             .collection('medications')
//                             .add(medicationData);

//                         // Schedule notifications for each reminder time
//                         for (String time in reminderTimes) {
//                           NotificationService().scheduleMedicationReminder(
//                             docRef.id,
//                             medicationData['name'],
//                             time,
//                           );
//                         }

//                         // Clear form fields after successful submission
//                         _medicationNameController.clear();
//                         _unit = null;
//                         _inventoryController.clear();
//                         _frequency = null;
//                         _reminderTimes = [null];
//                         _doseQuantity = null;

//                         Navigator.pop(context);
//                       } catch (e) {
//                         print('Error adding medication: $e');
//                       }
//                     }
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                           content: Text('Please fill all required fields')),
//                     );
//                   }
//                 },
//                 child: const Text('Submit'),
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: const Size(400, 40),
//                   backgroundColor: Colors.teal[700],
//                   foregroundColor: Colors.white,
//                   textStyle: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               ElevatedButton(
//                 onPressed: _previousPage,
//                 child: const Text('Back'),
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: const Size(400, 40),
//                   backgroundColor: Colors.blue[200],
//                   foregroundColor: Colors.white,
//                   textStyle: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
