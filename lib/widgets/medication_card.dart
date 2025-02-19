import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/scheduler.dart';
import 'package:medicine_reminder/services/medication_service.dart';
import 'package:intl/intl.dart'; // For formatting timestamps

class MedicationCard extends StatefulWidget {
  final String name;
  final String unit;
  final int doseQuantity;
  final List<String> reminderTimes;
  final String medicationId;
  final DateTime selectedDay;

  const MedicationCard({
    Key? key,
    required this.name,
    required this.unit,
    required this.doseQuantity,
    required this.reminderTimes,
    required this.selectedDay,
    required this.medicationId,
  }) : super(key: key);

  @override
  _MedicationCardState createState() => _MedicationCardState();
}

class _MedicationCardState extends State<MedicationCard> {
  final Map<String, String?> takenAtMap = {}; // Store taken times per reminder

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _fetchTakenAtForReminders();
    });
  }

  Future<void> _fetchTakenAtForReminders() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final medicationService = MedicationService();

      for (String time in widget.reminderTimes) {
        final takenAt = await medicationService.fetchLatestTakenAt(
          currentUser.uid,
          widget.medicationId,
          widget.selectedDay,
          time, // Check for this specific reminder time
        );

        if (mounted) {
          setState(() {
            takenAtMap[time] = takenAt; // Store taken time for each reminder
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    return Column(
      children: widget.reminderTimes.map((reminderTime) {
        final takenAt = takenAtMap[reminderTime];

  return Card(
  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 26),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  elevation: 4,
  child: Padding(
    padding: const EdgeInsets.all(16), // Increased padding for better spacing
    child: Row(
      children: [
        // Medication Icon with a tick if taken
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(12), // Adjusted padding for the icon
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 101, 109, 123).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.medication, size: 36, color: Color.fromARGB(255, 3, 3, 77)), // Changed icon color for better visibility
            ),
            if (takenAt != null)
              const Positioned(
                right: -1,
                top: -1,
                child: Icon(Icons.check_circle, color: Color.fromARGB(255, 9, 91, 11), size: 20), // Increased size for better visibility
              ),
          ],
        ),
        const SizedBox(width: 16),

                // Medication Details
                Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.name,
                style: const TextStyle(
                  fontSize: 20, // Increased font size for the medication name
                  fontWeight: FontWeight.bold, // Changed to bold for emphasis
                  color: Colors.black, // Changed color for better contrast
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Take ${widget.doseQuantity} ${widget.unit}',
                style: TextStyle(
                  fontSize: 16, // Adjusted font size for dosage
                  color: Colors.grey[700], // Changed color for better readability
                ),
              ),
              if (takenAt != null)
                Text(
                  'Taken at $takenAt',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color.fromARGB(255, 14, 90, 17),
                    fontWeight: FontWeight.normal,
                  ),
                ),
                    ],
                  ),
                ),

                // Taken Button
                TextButton(
                  onPressed: takenAt != null
                      ? null // Disable if already taken
                      : () async {
                          if (currentUser == null) return;

                          final medicationService = MedicationService();
                          await medicationService.updateInventory(widget.medicationId, widget.doseQuantity);
                          await medicationService.logAdherence(
                            currentUser.uid,
                             widget.medicationId,
                            widget.name,
                            widget.doseQuantity,widget.selectedDay,
                            reminderTime, // Pass specific reminder
                            
                          );

                          await _fetchTakenAtForReminders(); // Refresh after logging

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${widget.name} marked as taken at $reminderTime')),
                          );
                        },
                  child: Text(takenAt != null ? 'Taken' : 'Mark as Taken'),
                ),
              ],
            ),
          ),
        );
      }).toList(),
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