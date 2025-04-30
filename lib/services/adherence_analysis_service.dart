import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  
  /// Analyze adherence for a specific medication at a specific time
// Fixed version of _analyzeReminderTimeAdherence method
Future<Map<String, dynamic>> _analyzeReminderTimeAdherence(
  String userId, 
  String medicationId, 
  String reminderTime
) async {
  try {
    // Get adherence logs for the past 30 days
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    
    print("⚠️ DEBUG QUERY: Checking logs for $medicationId at time $reminderTime");
    
    // First, check if ANY logs exist for this medication/time to confirm query structure
    final allLogsSnapshot = await FirebaseFirestore.instance
        .collection('adherence_logs')
        .where('medication_id', isEqualTo: medicationId)
        .limit(5)
        .get();
        
    print("⚠️ Found ${allLogsSnapshot.docs.length} total logs for this medication");
    
    if (allLogsSnapshot.docs.isNotEmpty) {
      print("⚠️ Sample log data: ${allLogsSnapshot.docs.first.data()}");
    }
    
    // Now perform the actual query for missed logs
    final logsSnapshot = await FirebaseFirestore.instance
        .collection('adherence_logs')
        .where('user_uid', isEqualTo: userId)
        .where('medication_id', isEqualTo: medicationId)
        .where('specific_reminder_time', isEqualTo: reminderTime)
        .where('status', isEqualTo: 'missed')
        .get();
    
    int missedCount = logsSnapshot.docs.length;
    List<DateTime> missedTimes = [];
    
    print("⚠️ Found $missedCount missed logs for time $reminderTime");
    
    // Print each missed log for debugging
    for (var logDoc in logsSnapshot.docs) {
      final logData = logDoc.data();
      print("⚠️ Missed log: ${logData['timestamp']}, ${logData['specific_reminder_time']}");
      
      if (logData['timestamp'] != null) {
        final timestamp = (logData['timestamp'] as Timestamp).toDate();
        missedTimes.add(timestamp);
      }
    }
    
    // Only suggest changes if there are enough misses
    if (missedCount >= MISSED_THRESHOLD) {
      print("⚠️ Threshold reached ($MISSED_THRESHOLD), calculating suggested time");
      
      // Analyze missed times to find patterns
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
    print('⚠️ Error analyzing reminder time adherence: $e');
    return {
      'missedCount': 0,
      'suggestedTime': null,
      'reason': null,
    };
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