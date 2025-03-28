import 'dart:convert';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/scheduler.dart';
import 'package:medicine_reminder/services/medication_service.dart';
import 'package:intl/intl.dart';
import 'package:medicine_reminder/utils/dialog_helper.dart'; // For formatting timestamps

class MedicationCard extends StatefulWidget {
  final String name;
  final String unit;
  final int doseQuantity;
  final List<String> reminderTimes;
  final String medicationId;
  final DateTime selectedDay;
  final String? imageBase64;

  const MedicationCard({
    Key? key,
    required this.name,
    required this.unit,
    required this.doseQuantity,
    required this.reminderTimes,
    required this.selectedDay,
    required this.medicationId,
    this.imageBase64,
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

  void _showActionSheet(BuildContext context, String reminderTime) {
    showDialog(
      context: context,
      barrierDismissible: true, // Enables dismissing by tapping outside
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () =>
              Navigator.pop(context), // Close the dialog when tapping outside
          behavior: HitTestBehavior
              .opaque, // Ensures taps outside the dialog are detected
          child: Stack(
            children: [
              // Blurred background effect
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(color: Colors.black.withOpacity(0.3)),
                ),
              ),
              Center(
                child: GestureDetector(
                  onTap:
                      () {}, // Prevents taps on the dialog itself from closing it
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                      CurvedAnimation(
                          parent: ModalRoute.of(context)!.animation!,
                          curve: Curves.easeOut),
                    ),
                    child: Dialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      elevation: 10,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 40, horizontal: 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            widget.imageBase64 != null &&
                                    widget.imageBase64!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.memory(
                                      base64Decode(widget.imageBase64!),
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Image.asset(
                                    'assets/pill.png', // Default image
                                    fit: BoxFit.cover,
                                    width: 80,
                                    height: 80,
                                  ),
                            const SizedBox(height: 25),
                            Text(widget.name,
                                style: const TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            Text('Take ${widget.doseQuantity} ${widget.unit}',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey[700])),
                            const SizedBox(height: 20),

                            // Buttons for "Taken" and "Miss"
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Icon(Icons.close, color: Colors.grey[400]), // Cross icon
                                    // Icon(Icons.check, color: Colors.grey[400]), // Tick icon
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        await _markAsTaken(reminderTime);
                                        Navigator.pop(context);
                                      },
                                      icon: const Icon(Icons.check,
                                          color: Color.fromARGB(255, 56, 26, 3)), // Tick icon for the button
                                      label: const Text("Taken",
                                          style: TextStyle(
                                            color: Color.fromARGB(255, 56, 26, 3),
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          )),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(255, 255, 241, 231), // Remove background color
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          side: BorderSide(
                                              color: Colors
                                                  .grey[400]!), // Add a border
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // ElevatedButton.icon(
                                //   onPressed: () => Navigator.pop(context),
                                //   icon: const Icon(Icons.close,
                                //       color: Colors
                                //           .black), // Cross icon for the button
                                //   label: const Text("Miss",
                                //       style: TextStyle(color: Colors.black)),
                                //   style: ElevatedButton.styleFrom(
                                //     backgroundColor: Colors
                                //         .transparent, // Remove background color
                                //     padding: const EdgeInsets.symmetric(
                                //         horizontal: 20, vertical: 12),
                                //     shape: RoundedRectangleBorder(
                                //       borderRadius: BorderRadius.circular(12),
                                //       side: BorderSide(
                                //           color: Colors
                                //               .grey[400]!), // Add a border
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _markAsTaken(String reminderTime) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final medicationService = MedicationService();
    await medicationService.updateInventory(
        widget.medicationId, widget.doseQuantity);
    await medicationService.logAdherence(
      currentUser.uid,
      widget.medicationId,
      widget.name,
      widget.doseQuantity,
      widget.selectedDay,
      reminderTime,
    );

    await _fetchTakenAtForReminders();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('${widget.name} marked as taken at $reminderTime')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.reminderTimes.map((reminderTime) {
        final takenAt = takenAtMap[reminderTime];

        return GestureDetector(
          onTap: () => _showActionSheet(context, reminderTime),
          child: Card(
            color: Colors.white,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 26),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none, // Allow tick to go outside
                    children: [
                      Stack(
                        children: [
                          // Border Container
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(
                                color: const Color.fromARGB(
                                    255, 227, 227, 227), // Border color
                                width: 2, // Border width
                              ),
                              color: (widget.imageBase64 != null &&
                                      widget.imageBase64!.isNotEmpty)
                                  ? Colors.transparent
                                  : const Color.fromARGB(255, 101, 109, 123)
                                      .withOpacity(0.2),
                            ),
                          ),

                          // Image inside the border
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  5), // Ensure image fits inside border
                              child: GestureDetector(
                                onTap: () {
                                  if (widget.imageBase64 != null &&
                                      widget.imageBase64!.isNotEmpty) {
                                    showImageDialog(
                                        context, widget.imageBase64!);
                                  }
                                },
                                child: widget.imageBase64 != null &&
                                        widget.imageBase64!.isNotEmpty
                                    ? Image.memory(
                                        base64Decode(widget.imageBase64!),
                                        fit: BoxFit
                                            .cover, // Ensures image fits nicely inside
                                      )
                                    : Image.asset(
                                        'assets/pill.png', // Default image
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // ✅ Adjusted tick position
                      if (takenAt != null)
                        Positioned(
                          right: -5,
                          top: -5,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color.fromARGB(255, 227, 227,
                                  227), // Background for better contrast
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: const Icon(
                              Icons.check_circle,
                              color: Color.fromARGB(255, 45, 174, 49),
                              size: 18, // Bigger for better visibility
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Take ${widget.doseQuantity} ${widget.unit}',
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ),
                        if (takenAt != null)
                          Text(
                            'Taken at $takenAt',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color.fromARGB(255, 14, 90, 17),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
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