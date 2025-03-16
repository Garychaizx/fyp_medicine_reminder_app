import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/medication_service.dart';
import '../utils/dialog_helper.dart';

class MedicationDetailsCard extends StatelessWidget {
  final Map<String, dynamic> medication;
  final String medicationId;
  final VoidCallback onEdit;

  const MedicationDetailsCard({
    required this.medication,
    required this.medicationId,
    required this.onEdit,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Only call calculateHourlyReminderTimes for "Every X Hours" frequency
    List<String> reminderTimes = [];
    String frequencyText = medication['frequency'] ?? 'No Frequency';

    if (frequencyText == 'Every X Hours' &&
        medication['interval_hour'] != null) {
      // Replace 'X' with the interval hour value
      frequencyText = 'Every ${medication['interval_hour']} Hours';
      final MedicationService _medicationService = MedicationService();
      // Calculate reminder times using the interval_hour
      reminderTimes = _medicationService.calculateHourlyReminderTimes(
        medication['interval_starting_time'],
        medication['interval_ending_time'],
        medication['interval_hour'],
      );
    } else {
      // Handle other frequencies if needed (or leave as empty list)
      reminderTimes = List<String>.from(medication['reminder_times'] ?? []);
    }

    return InkWell(
      onTap: onEdit,
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row(
              //   children: [
              //     Container(
              //       width: 60,
              //       height: 60,
              //       decoration: BoxDecoration(
              //         borderRadius: BorderRadius.circular(12), // Rounded border
              //         border: Border.all(
              //           color: const Color.fromARGB(
              //               255, 227, 227, 227), // Border color
              //           width: 2, // Keep border width unchanged
              //         ),
              //         color: medication['imageBase64'] != null &&
              //                 medication['imageBase64']!.isNotEmpty
              //             ? Colors.transparent
              //             : const Color.fromARGB(255, 101, 109, 123)
              //                 .withOpacity(0.2),
              //       ),
              //       child: ClipRRect(
              //         borderRadius: BorderRadius.circular(
              //             10), // Slightly smaller than border radius
              //         child: GestureDetector(
              //           onTap: () {
              //             if (medication['imageBase64'] != null &&
              //                 medication['imageBase64']!.isNotEmpty) {
              //               showImageDialog(
              //                   context, medication['imageBase64']!);
              //             }
              //           },
              //           child: medication['imageBase64'] != null &&
              //                   medication['imageBase64']!.isNotEmpty
              //               ? Image.memory(
              //                   base64Decode(medication['imageBase64']!),
              //                   width: 60, // Match container size
              //                   height: 60,
              //                   fit: BoxFit.cover,
              //                 )
              //               : Image.asset(
              //                   'assets/pill.png', // Default image
              //                   width: 60,
              //                   height: 60,
              //                   fit: BoxFit.cover,
              //                 ),
              //         ),
              //       ),
              //     ),
              //     const SizedBox(width: 16),
              //     Expanded(
              //       child: Column(
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           Text(
              //             medication['name'] ?? 'No Name',
              //             style: const TextStyle(
              //               fontSize: 20,
              //               fontWeight: FontWeight.bold,
              //             ),
              //           ),
              //           const SizedBox(height: 4),
              //           Text(
              //             frequencyText, // Display the updated frequency text
              //             style: TextStyle(color: Colors.grey[600]),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ],
              // ),
              Row(
                children: [
                  // Image with border using Stack
                  Stack(
                    children: [
                      // Border Container (bottom layer)
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(12), // Rounded border
                          border: Border.all(
                            color: const Color.fromARGB(
                                255, 227, 227, 227), // Border color
                            width: 2, // Keep border width unchanged
                          ),
                          color: medication['imageBase64'] != null &&
                                  medication['imageBase64']!.isNotEmpty
                              ? Colors.transparent
                              : const Color.fromARGB(255, 101, 109, 123)
                                  .withOpacity(0.2),
                        ),
                      ),

                      // Image inside the border
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                              10), // Slightly smaller than border radius
                          child: GestureDetector(
                            onTap: () {
                              if (medication['imageBase64'] != null &&
                                  medication['imageBase64']!.isNotEmpty) {
                                showImageDialog(
                                    context, medication['imageBase64']!);
                              }
                            },
                            child: medication['imageBase64'] != null &&
                                    medication['imageBase64']!.isNotEmpty
                                ? Image.memory(
                                    base64Decode(medication['imageBase64']!),
                                    fit: BoxFit
                                        .cover, // Ensures the image fills properly inside
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

                  const SizedBox(width: 16), // Space between image and text

                  // Column for name and frequency
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medication['name'] ?? 'No Name',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          frequencyText, // Display the updated frequency text
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              const Text(
                'Reminder Time(s):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: reminderTimes
                    .map((time) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Color(0xFFF2D6C3),
                            borderRadius:
                                BorderRadius.circular(7), // Same rounded shape
                          ),
                          child: Text(
                            time,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ))
                    .toList(),
              ),

              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Inventory',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${medication['current_inventory']} ${medication['unit']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
