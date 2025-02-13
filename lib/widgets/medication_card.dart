import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicine_reminder/services/medication_service.dart';
import 'package:intl/intl.dart'; // For formatting timestamps

class MedicationCard extends StatefulWidget {
  final String name;
  final String unit;
  final int doseQuantity;
  final List<String> reminderTimes;
  final String medicationId; // Add medicationId parameter
  final DateTime selectedDay;

  const MedicationCard({
    Key? key,
    required this.name,
    required this.unit,
    required this.doseQuantity,
    required this.reminderTimes,
    required this.selectedDay,
    required this.medicationId, // Pass medicationId
  }) : super(key: key);

  @override
  _MedicationCardState createState() => _MedicationCardState();
}

class _MedicationCardState extends State<MedicationCard> {
  String? _takenAt;

  @override
  void initState() {
    super.initState();
    _fetchTakenAt();
  }

  Future<void> _fetchTakenAt() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final medicationService = MedicationService();
      final takenAt = await medicationService.fetchLatestTakenAt(
        currentUser.uid,
        widget.medicationId,
        widget.selectedDay, // Pass the selected date
      );

      if (mounted) {
        setState(() {
          _takenAt = takenAt; // Update state with the fetched value
        });
      }
      print(widget.selectedDay); // Confirm the value is fetched
    }
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 26),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Medication Icon with a tick if taken
              Stack(
                clipBehavior:
                    Clip.none, // To allow the tick to overflow if needed
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 101, 109, 123)
                          .withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.medication,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                  if (_takenAt != null) // Show tick if taken
                    Positioned(
                      right: -4, // Adjust position to your liking
                      top: -4, // Adjust position to your liking
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 16, // Small size for the tick
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              const VerticalDivider(
                width: 1,
                thickness: 1,
                color: Colors.grey,
                indent: 10,
                endIndent: 10,
              ),
              const SizedBox(width: 12),
              // Medication Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Take ${widget.doseQuantity} ${widget.unit}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (_takenAt != null)
                      Text(
                        'Taken at $_takenAt',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.green,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                  ],
                ),
              ),
              // Taken Button
              TextButton(
                onPressed: () async {
                  final medicationService = MedicationService();
                  try {
                    // Check if the user is signed in
                    if (currentUser == null) {
                      throw Exception('User is not signed in.');
                    }

                    // Perform inventory update and adherence logging
                    await medicationService.updateInventory(
                        widget.medicationId, widget.doseQuantity);
                    await medicationService.logAdherence(
                        currentUser.uid,
                        widget.medicationId,
                        widget.name,
                        widget.doseQuantity,
                        widget.selectedDay);

                    // Fetch and update the "Taken At" timestamp
                    await _fetchTakenAt();

                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            '${widget.name} marked as taken. Inventory updated.'),
                      ),
                    );
                  } catch (e) {
                    // Show error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
                child: const Text(
                  'Taken',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


  // Future<void> _updateInventory(BuildContext context, String medicationId, int doseQuantity) async {
  //   try {
  //     // Get the medication document reference
  //     final medicationRef = FirebaseFirestore.instance
  //         .collection('medications')
  //         .doc(medicationId);

  //     // Fetch the current inventory
  //     final docSnapshot = await medicationRef.get();
  //     if (docSnapshot.exists) {
  //       final currentInventory = docSnapshot['current_inventory'] as int;

  //       // Check if the current inventory is a valid number
  //       final currentInventoryValue = currentInventory;
  //       final updatedInventory = currentInventoryValue - doseQuantity;

  //       // Update the current inventory field
  //       await medicationRef.update({
  //         'current_inventory': updatedInventory.toString(),
  //       });

  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('$name marked as taken. Inventory updated.')),
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error updating inventory: $e')),
  //     );
  //   }
  // }
  //after update need create adherence log database to write down the time take the medication name adn the quantity