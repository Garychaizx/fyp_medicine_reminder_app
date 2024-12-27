// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:medicine_reminder/services/notification_service.dart';

// // Constants for decorations
// const double _padding = 20.0;
// const double _borderRadius = 12.0;
// const _primaryColor = Color.fromARGB(255, 27, 50, 126);

// class EditMedicationForm extends StatefulWidget {
//   final String medicationId;
//   final Map<String, dynamic> medicationData;

//   const EditMedicationForm({
//     Key? key,
//     required this.medicationId,
//     required this.medicationData,
//   }) : super(key: key);

//   @override
//   _EditMedicationFormState createState() => _EditMedicationFormState();
// }

// class _EditMedicationFormState extends State<EditMedicationForm> {
//   late TextEditingController nameController;
//   late List<TextEditingController> reminderTimeControllers = [];
//   late TextEditingController currentInventoryController;
//   late TextEditingController doseQuantityController;
//   String? _frequency;
//   bool _hasAttemptedSubmit = false;

//   @override
//   void initState() {
//     super.initState();
//     // Initialize controllers with existing data
//     nameController = TextEditingController(text: widget.medicationData['name']);
//     _frequency = widget.medicationData['frequency'];
//     currentInventoryController = TextEditingController(
//         text: widget.medicationData['current_inventory']?.toString() ?? '');
//     doseQuantityController = TextEditingController(
//         text: widget.medicationData['dose_quantity']?.toString() ?? '');

//     // Set up reminder time controllers based on existing reminder times
//     List<String> existingTimes = List<String>.from(widget.medicationData['reminder_times'] ?? ['']);
//     for (String time in existingTimes) {
//       reminderTimeControllers.add(TextEditingController(text: time));
//     }
//   }

// void _setupReminderTimes() {
//   // Get the updated reminder times from the controllers
//   List<String> reminderTimes = reminderTimeControllers.map((controller) => controller.text).toList();
//   int doseQuantity = int.tryParse(doseQuantityController.text) ?? 1;
//   // Schedule notifications for each reminder time
//   for (String time in reminderTimes) {
//     // Assuming scheduleMedicationReminder is a function in NotificationService
//     NotificationService().scheduleMedicationReminder(
//       widget.medicationId, // Pass the medication ID
//       nameController.text,  // Pass the medication name
//       time,// Pass the reminder time
//       doseQuantity,
//       widget.medicationData['unit']
//     );
//     print('Scheduled reminder for $time');
//   }
// }

//   void _updateReminderTimes() {
//     int reminderCount;
//     switch (_frequency) {
//       case 'Twice a Day':
//         reminderCount = 2;
//         break;
//       case 'Three Times a Day':
//         reminderCount = 3;
//         break;
//       default:
//         reminderCount = 1;
//     }

//     // Adjust the number of controllers to match the selected frequency
//     setState(() {
//       if (reminderTimeControllers.length < reminderCount) {
//         reminderTimeControllers.addAll(
//           List.generate(reminderCount - reminderTimeControllers.length, 
//           (_) => TextEditingController()));
//       } else if (reminderTimeControllers.length > reminderCount) {
//         reminderTimeControllers = reminderTimeControllers.sublist(0, reminderCount);
//       }
//     });
//   }

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

//   Future<void> _updateMedication() async {
//     try {
//       await FirebaseFirestore.instance.collection('medications').doc(widget.medicationId).update({
//         'name': nameController.text,
//         'reminder_times': reminderTimeControllers.map((controller) => controller.text).toList(),
//         'frequency': _frequency,
//         'current_inventory': int.tryParse(currentInventoryController.text) ?? 0,
//         'dose_quantity': int.tryParse(doseQuantityController.text) ?? 0,
//       });
//       _setupReminderTimes();
//       if (mounted) {
//         Navigator.pop(context);
//       } // Go back to the previous screen after saving
//     } catch (e) {
//       debugPrint('Error updating medication: $e');
//     }
//   }

//   Future<void> _deleteMedication() async {
//     try {
//       await FirebaseFirestore.instance
//           .collection('medications')
//           .doc(widget.medicationId)
//           .delete();
//       if (mounted) {
//         Navigator.pop(context);
//       }
//     } catch (e) {
//       debugPrint('Error deleting medication: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Edit Medication'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: nameController,
//               decoration: _getInputDecoration(
//                 'Medication Name',
//                 _hasAttemptedSubmit && nameController.text.isEmpty
//                     ? 'Medication name is required'
//                     : null,
//               ),
//             ),
//             SizedBox(height: 16),
//             ...reminderTimeControllers.asMap().entries.map((entry) {
//               int index = entry.key;
//               TextEditingController controller = entry.value;
//               return Padding(
//                 padding: const EdgeInsets.only(bottom: 16.0),
//                 child: TextField(
//                   controller: controller,
//                   decoration: _getInputDecoration('Reminder Time ${index + 1}', null),
//                   onTap: () async {
//                     final TimeOfDay? picked = await showTimePicker(
//                       context: context,
//                       initialTime: TimeOfDay.now(),
//                     );
//                     if (picked != null) {
//                       setState(() {
//                         controller.text = picked.format(context);
//                       });
//                     }
//                   },
//                   readOnly: true,
//                 ),
//               );
//             }).toList(),
//             DropdownButtonFormField<String>(
//               value: _frequency,
//               items: ['Daily', 'Twice a Day', 'Three Times a Day'].map((String value) {
//                 return DropdownMenuItem<String>(
//                   value: value,
//                   child: Text(value),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   _frequency = value;
//                   _updateReminderTimes();
//                 });
//               },
//               decoration: _getInputDecoration(
//                 'Frequency',
//                 _hasAttemptedSubmit && _frequency == null
//                     ? 'Frequency is required'
//                     : null,
//               ),
//             ),
//             SizedBox(height: 16),
//             TextField(
//               controller: currentInventoryController,
//               decoration: _getInputDecoration(
//                 'Current Inventory',
//                 _hasAttemptedSubmit && currentInventoryController.text.isEmpty
//                     ? 'Current inventory is required'
//                     : null,
//               ),
//               keyboardType: TextInputType.number,
//             ),
//             SizedBox(height: 16),
//             TextField(
//               controller: doseQuantityController,
//               decoration: _getInputDecoration(
//                 'Dose Quantity',
//                 _hasAttemptedSubmit && doseQuantityController.text.isEmpty
//                     ? 'Dose quantity is required'
//                     : null,
//               ),
//               keyboardType: TextInputType.number,
//             ),
//             SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   _hasAttemptedSubmit = true;
//                 });

//                 // Validate fields
//                 if (nameController.text.isNotEmpty &&
//                     _frequency != null &&
//                     currentInventoryController.text.isNotEmpty &&
//                     doseQuantityController.text.isNotEmpty) {
//                   _updateMedication();
//                 }
//               },
//               child: Text('Save Changes'),
//               style: ElevatedButton.styleFrom(
//                 minimumSize: const Size(400, 40),
//                 backgroundColor: _primaryColor,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 15.0),
//                 textStyle: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: _deleteMedication,
//               child: Text('Delete'),
//               style: ElevatedButton.styleFrom(
//                 minimumSize: const Size(400, 40),
//                 backgroundColor: Colors.red[300],
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 15.0),
//                 textStyle: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
