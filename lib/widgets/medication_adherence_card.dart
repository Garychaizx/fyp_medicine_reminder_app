import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart'; // Add this package for circular progress
import 'package:medicine_reminder/utils/dialog_helper.dart';

class MedicationAdherenceCard extends StatelessWidget {
  final String medicationId;
  final String medicationName;
  final String? imageBase64;
  final int takenCount;
  final int currentInventory;

  const MedicationAdherenceCard({
    Key? key,
    required this.medicationId,
    required this.medicationName,
    this.imageBase64,
    required this.takenCount,
    required this.currentInventory,
  }) : super(key: key);

  double calculateAdherenceRate(int takenCount, int totalDosageRequired) {
    if (totalDosageRequired == 0) return 0.0; // Avoid division by zero
    return (takenCount / totalDosageRequired).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final adherenceRate = calculateAdherenceRate(takenCount, currentInventory);

    return Card(
      margin: const EdgeInsets.all(8.0),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Medication Image
            GestureDetector(
              onTap: () {
                if (imageBase64 != null && imageBase64!.isNotEmpty) {
                  showImageDialog(context, imageBase64!);
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: imageBase64 != null && imageBase64!.isNotEmpty
                    ? Image.memory(
                        base64Decode(imageBase64!),
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        'assets/pill.png', // Default image
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const SizedBox(width: 16),
            // Medication Details and Progress Bar
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicationName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Progress Bar
                  LinearProgressIndicator(
                    value: adherenceRate,
                    backgroundColor: Colors.grey[300],
                    color: adherenceRate >= 0.8 ? Colors.green : Colors.red,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$takenCount / $currentInventory doses taken',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Circular Percentage Indicator
            CircularPercentIndicator(
              radius: 40.0,
              lineWidth: 8.0,
              percent: adherenceRate,
              center: Text(
                '${(adherenceRate * 100).toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              progressColor: adherenceRate >= 0.8 ? Colors.green : Colors.red,
              backgroundColor: Colors.grey[300]!,
              circularStrokeCap: CircularStrokeCap.round,
            ),
          ],
        ),
      ),
    );
  }
}