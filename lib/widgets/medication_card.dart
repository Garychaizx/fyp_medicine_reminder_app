import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/scheduler.dart';
import 'package:medicine_reminder/services/medication_service.dart';
import 'package:intl/intl.dart';
import 'package:medicine_reminder/services/notification_service.dart';
import 'package:medicine_reminder/utils/dialog_helper.dart'; // For formatting timestamps

class MedicationCard extends StatefulWidget {
    // Add this static property to hold references to all card states
  static final List<_MedicationCardState> _instances = [];

  // Add this static method to refresh all instances
  static void refreshAll() {
    for (var instance in _instances) {
      if (instance.mounted) {
        instance._fetchMedicationStatus();
      }
    }
  }
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

class _MedicationCardState extends State<MedicationCard> with SingleTickerProviderStateMixin {
  final Map<String, Map<String, dynamic>?> statusMap = {};
  bool isFlashing = false; // To track if the card should flash
  Timer? _timer;
  late AnimationController _flashingController;
  late Animation<double> _flashingAnimation;

  @override
  void initState() {
    super.initState();
    MedicationCard._instances.add(this);
    
    // Initialize animation controller
    _flashingController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    
    // Create pulsing animation
    _flashingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _flashingController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Add listener to repeat the animation
    _flashingController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _flashingController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _flashingController.forward();
      }
    });
    
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _fetchMedicationStatus();
    });
    _startFlashingCheck();
  }

  @override
  void dispose() {
    _flashingController.dispose();
    MedicationCard._instances.remove(this);
    _timer?.cancel();
    super.dispose();
  }

  void _startFlashingCheck() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = TimeOfDay.now();
      final currentDate = DateTime.now();
      
      // Check if selected day is current day
      if (widget.selectedDay.year == currentDate.year &&
          widget.selectedDay.month == currentDate.month &&
          widget.selectedDay.day == currentDate.day) {
        
        for (String reminderTime in widget.reminderTimes) {
          final parsedTime = _parseTimeOfDay(reminderTime);
          if (parsedTime != null &&
              now.hour == parsedTime.hour &&
              now.minute == parsedTime.minute) {
            // If the current time matches a reminder time, start flashing
            if (!isFlashing) {
              setState(() {
                isFlashing = true;
                _flashingController.forward();
              });
            }
            return;
          }
        }
      }
      
      // Stop flashing if no reminder time matches
      if (isFlashing) {
        setState(() {
          isFlashing = false;
          _flashingController.stop();
          _flashingController.reset();
        });
      }
    });
  }
  TimeOfDay? _parseTimeOfDay(String time) {
    final RegExp timeRegex = RegExp(r'(\d+):(\d+)\s*(AM|PM)', caseSensitive: false);
    final Match? match = timeRegex.firstMatch(time);

    if (match == null) return null;

    int hour = int.parse(match.group(1)!);
    final int minute = int.parse(match.group(2)!);
    final String period = match.group(3)!.toUpperCase();

    if (period == 'PM' && hour != 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;

    return TimeOfDay(hour: hour, minute: minute);
  }
  Future<void> _fetchMedicationStatus() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final medicationService = MedicationService();

      for (String time in widget.reminderTimes) {
        final status = await medicationService.fetchLatestTakenAt(
          currentUser.uid,
          widget.medicationId,
          widget.selectedDay,
          time,
        );

        if (mounted) {
          setState(() {
            statusMap[time] = status;
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

  // Calculate the notification IDs
  final hour = int.parse(reminderTime.split(':')[0]);
  final minute = int.parse(reminderTime.split(':')[1].split(' ')[0]);
  final mainNotificationId = widget.medicationId.hashCode + hour * 60 + minute;
  final followUpId = mainNotificationId + 1;

  // Cancel the follow-up reminder immediately
  await NotificationService().cancelFollowUpReminder(followUpId);

  final medicationService = MedicationService();
  
  // Check if there's a missed log
  final status = statusMap[reminderTime];
  final isMissed = status?['status'] == 'missed';

  if (isMissed) {
    // Update the missed log to taken
    await medicationService.updateAdherenceLog(
      userUid: currentUser.uid,
      medicationId: widget.medicationId,
      specificReminderTime: reminderTime,
      selectedDay: widget.selectedDay,
      newStatus: 'taken'
    );
  } else {
    // Create new adherence log
    await medicationService.logAdherence(
      userUid: currentUser.uid,
      medicationId: widget.medicationId,
      medicationName: widget.name,
      doseQuantity: widget.doseQuantity,
      selectedDay: widget.selectedDay,
      specificReminderTime: reminderTime,
      status: 'taken',
      followUpId: followUpId,
    );
  }

  await medicationService.updateInventory(widget.medicationId, widget.doseQuantity);
  
  // Fetch updated status
  await _fetchMedicationStatus();
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(isMissed 
        ? '${widget.name} updated from missed to taken at $reminderTime'
        : '${widget.name} marked as taken at $reminderTime'
      ),
    ),
  );
}

@override
Widget build(BuildContext context) {
  return Column(
    children: widget.reminderTimes.map((reminderTime) {
      final status = statusMap[reminderTime];
      final isMissed = status?['status'] == 'missed';
      final takenTime = status?['time'];

      // Build the content of the card once, outside the AnimatedBuilder
      final cardContent = Row(
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
                        color: const Color.fromARGB(255, 227, 227, 227),
                        width: 2,
                      ),
                      color: (widget.imageBase64 != null && widget.imageBase64!.isNotEmpty)
                          ? Colors.transparent
                          : const Color.fromARGB(255, 101, 109, 123).withOpacity(0.2),
                    ),
                  ),

                  // Image inside the border
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: GestureDetector(
                        onTap: () {
                          if (widget.imageBase64 != null && widget.imageBase64!.isNotEmpty) {
                            showImageDialog(context, widget.imageBase64!);
                          }
                        },
                        child: widget.imageBase64 != null && widget.imageBase64!.isNotEmpty
                            ? Image.memory(
                                base64Decode(widget.imageBase64!),
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                'assets/pill.png',
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              // Modified tick/cross position
              if (status != null)
                Positioned(
                  right: -5,
                  top: -5,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color.fromARGB(255, 227, 227, 227),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Icon(
                      isMissed ? Icons.close : Icons.check_circle,
                      color: isMissed
                          ? Colors.white
                          : const Color.fromARGB(255, 72, 211, 77),
                      size: 18,
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
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                if (status != null)
                  Text(
                    isMissed ? 'Missed' : 'Taken at $takenTime',
                    style: TextStyle(
                      fontSize: 14,
                      color: isMissed
                          ? const Color.fromARGB(255, 197, 196, 196)
                          : const Color.fromARGB(255, 13, 166, 19),
                    ),
                  ),
              ],
            ),
          ),
        ],
      );

      return GestureDetector(
        onTap: () => _showActionSheet(context, reminderTime),
        child: AnimatedBuilder(
          animation: _flashingAnimation,
          builder: (context, child) {
            // Calculate animated color values
            final animatedColor = isFlashing 
                ? Color.lerp(Colors.white, Colors.yellow[100], _flashingAnimation.value)
                : Colors.white;
            
            final animatedBorderColor = isFlashing
                ? Color.lerp(const Color.fromARGB(255, 227, 227, 227), Colors.orange, _flashingAnimation.value)
                : const Color.fromARGB(255, 227, 227, 227);
            
            final animatedBorderWidth = isFlashing
                ? 1.0 + _flashingAnimation.value * 1.0 // Animate between 1 and 2
                : 1.0;
            
            return Container(
              decoration: BoxDecoration(
                color: animatedColor,
                border: Border.all(
                  color: animatedBorderColor!,
                  width: animatedBorderWidth,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 26),
              child: Padding(
                padding: const EdgeInsets.all(16),
                // Use the pre-built content
                child: child,
              ),
            );
          },
          // Pass the pre-built content as the child parameter
          child: cardContent,
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