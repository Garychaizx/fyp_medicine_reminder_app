import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class AdherenceAnalysisService {
  // Configure the threshold for suggesting a time change
  static const int MISSED_THRESHOLD = 3; // Suggest changes after 3 misses
  
  /// Analyzes medication adherence patterns and returns suggestions
  Future<List<Map<String, dynamic>>> analyzeMedicationAdherence(String userId) async {
    List<Map<String, dynamic>> suggestions = [];
    print("Starting medication adherence analysis for user: $userId");
    
    try {
      // Get all medications for the user
      final medicationsSnapshot = await FirebaseFirestore.instance
          .collection('medications')
          .where('user_uid', isEqualTo: userId)
          .get();
      
      print("Found ${medicationsSnapshot.docs.length} medications to analyze");
      
      // Analyze each medication
      for (var medicationDoc in medicationsSnapshot.docs) {
        final medicationId = medicationDoc.id;
        final medicationData = medicationDoc.data();
        final medicationName = medicationData['name'] as String;
        
        print("Analyzing medication: $medicationName (ID: $medicationId)");
        
        // Get reminder times for this medication
        List<String> reminderTimes = [];
        if (medicationData['frequency'] == 'Every X Hours') {
          // For interval-based medications
          if (medicationData['interval_starting_time'] != null && 
              medicationData['interval_ending_time'] != null) {
            reminderTimes.add(medicationData['interval_starting_time']);
            reminderTimes.add(medicationData['interval_ending_time']);
          }
        } else {
          // For regular medications
          if (medicationData['reminder_times'] != null) {
            reminderTimes = List<String>.from(medicationData['reminder_times']);
          }
        }
        
        print("Reminder times to analyze: $reminderTimes");
        
        // Check adherence patterns for each reminder time
        for (String reminderTime in reminderTimes) {
          print("Analyzing reminder time: $reminderTime");
          
          final adherencePattern = await _analyzeReminderTimeAdherence(
            userId, 
            medicationId, 
            reminderTime
          );
          
          print("Analysis result: ${adherencePattern['missedCount']} misses for $medicationName at $reminderTime");
          
          if (adherencePattern['missedCount'] >= MISSED_THRESHOLD) {
            print("Adding suggestion for $medicationName at $reminderTime");
            
            // Add suggestion to the list
            suggestions.add({
              'medicationId': medicationId,
              'medicationName': medicationName,
              'currentTime': reminderTime,
              'missedCount': adherencePattern['missedCount'],
              'suggestedTime': adherencePattern['suggestedTime'],
              'reason': adherencePattern['reason'],
            });
          }
        }
      }
      
      print("Analysis complete. Found ${suggestions.length} suggestions");
      return suggestions;
    } catch (e) {
      print('Error analyzing medication adherence: $e');
      return [];
    }
  }
  
Future<Map<String, dynamic>> _analyzeReminderTimeAdherence(
  String userId,
  String medicationId,
  String reminderTime,
) async {
  try {
    // Get adherence logs for the past 30 days
    final logsSnapshot = await FirebaseFirestore.instance
        .collection('adherence_logs')
        .where('user_uid', isEqualTo: userId)
        .where('medication_id', isEqualTo: medicationId)
        .where('specific_reminder_time', isEqualTo: reminderTime)
        .where('status', isEqualTo: 'missed')
        .get();

    int missedCount = logsSnapshot.docs.length;
    List<DateTime> missedTimes = [];

    for (var logDoc in logsSnapshot.docs) {
      final logData = logDoc.data();
      if (logData['timestamp'] != null) {
        final timestamp = (logData['timestamp'] as Timestamp).toDate();
        missedTimes.add(timestamp);
      }
    }

    // Only suggest changes or send emails if there are enough misses
    if (missedCount >= MISSED_THRESHOLD) {
      // Fetch caregiver email
      final caregiverEmail = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get()
          .then((doc) => doc.data()?['caregiver_email']);

      if (caregiverEmail != null) {
        // Fetch the user's name
        final userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        final userName = userSnapshot.data()?['name'] ?? 'Unknown User';

        // Fetch the medication name using the medicationId
        final medicationSnapshot = await FirebaseFirestore.instance
            .collection('medications')
            .doc(medicationId)
            .get();
        final medicationName = medicationSnapshot.data()?['name'] ?? 'Unknown Medication';

        // Send email to caregiver
        await sendEmailToCaregiver(
          caregiverEmail: caregiverEmail,
          userName: userName, // Pass the user's name
          medicationName: medicationName, // Pass the medication name
          reminderTime: reminderTime,
          missedCount: missedCount,
        );
      }

      // Suggest a better time
      final suggestedTimeInfo = _suggestBetterTime(reminderTime, missedTimes);
      return {
        'missedCount': missedCount,
        'suggestedTime': suggestedTimeInfo['suggestedTime'],
        'reason': suggestedTimeInfo['reason'],
      };
    }

    return {
      'missedCount': missedCount,
      'suggestedTime': null,
      'reason': null,
    };
  } catch (e) {
    print('Error analyzing reminder time adherence: $e');
    return {
      'missedCount': 0,
      'suggestedTime': null,
      'reason': null,
    };
  }
}

Future<void> sendEmailToCaregiver({
  required String caregiverEmail,
  required String userName,
  required String medicationName,
  required String reminderTime,
  required int missedCount,
}) async {
  const String backendUrl = 'http://10.0.2.2:3000/send-email';

  final emailData = {
    'caregiverEmail': caregiverEmail,
    'userName': userName,
    'medicationName': medicationName,
    'suggestedTime': reminderTime,
    'missedCount': missedCount,
  };

  try {
    print('Sending email with data: $emailData'); // Debug log

    final response = await http.post(
      Uri.parse(backendUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(emailData),
    );

    if (response.statusCode == 200) {
      print('Email sent to caregiver successfully!');
    } else {
      print('Failed to send email to caregiver: ${response.body}');
    }
  } catch (e) {
    print('Error sending email to caregiver: $e');
  }
}
  
 // Update this method to always return a non-null suggestedTime
Map<String, String> _suggestBetterTime(String currentTime, List<DateTime> missedTimes) {
  try {
    // Parse the current reminder time
    final timeFormat = DateFormat('h:mm a');
    TimeOfDay? parsedTimeOfDay;  
    
    try {
      final parsedTime = timeFormat.parse(currentTime);
      parsedTimeOfDay = TimeOfDay(hour: parsedTime.hour, minute: parsedTime.minute);
    } catch (e) {
      print("Error parsing time: $e");
      // Fall back to default time if parsing fails
      parsedTimeOfDay = TimeOfDay(hour: 9, minute: 0);
    }
    
    // Simple strategy: shift by 30 minutes
    final suggestedHour = parsedTimeOfDay.hour;
    final suggestedMinute = (parsedTimeOfDay.minute + 30) % 60;
    final adjustedHour = suggestedMinute < parsedTimeOfDay.minute 
        ? (suggestedHour + 1) % 24 
        : suggestedHour;
    
    final suggestedTimeOfDay = TimeOfDay(hour: adjustedHour, minute: suggestedMinute);
    
    // Convert back to string format
    final now = DateTime.now();
    final suggestedDateTime = DateTime(
      now.year, now.month, now.day, 
      suggestedTimeOfDay.hour, suggestedTimeOfDay.minute
    );
    
    final suggestedTimeString = timeFormat.format(suggestedDateTime);
    
    return {
      'suggestedTime': suggestedTimeString,
      'reason': 'You often miss this medication. Would you prefer taking it at $suggestedTimeString instead?'
    };
  } catch (e) {
    print("Error in suggestion algorithm: $e");
    
    // Always provide a fallback suggestion if something goes wrong
    return {
      'suggestedTime': '9:00 AM',
      'reason': 'You often miss this medication. Would a different time work better?'
    };
  }
}

// Helper method to suggest a default time (30 minutes later)
String _suggestDefaultTime(String currentTime) {
  try {
    final timeFormat = DateFormat('h:mm a');
    final parsedTime = timeFormat.parse(currentTime);
    final laterTime = parsedTime.add(const Duration(minutes: 30));
    return timeFormat.format(laterTime);
  } catch (e) {
    print("Error creating default time suggestion: $e");
    return "9:00 AM"; // Absolute fallback if all else fails
  }
}
}