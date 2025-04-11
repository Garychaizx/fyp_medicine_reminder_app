import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:medicine_reminder/navbar.dart';
import 'package:medicine_reminder/pages/login_page.dart';
import 'package:medicine_reminder/services/medication_service.dart';
import 'package:medicine_reminder/services/medicines_databse_service.dart';
import 'package:medicine_reminder/services/notification_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:medicine_reminder/widgets/medication_card.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


// Add this static method to receive notification actions
@pragma('vm:entry-point')
Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
  if (receivedAction.buttonKeyPressed == 'MARK_TAKEN') {
    print('User marked medication as taken.');
    
    final payload = receivedAction.payload;
    if (payload == null) {
      print('No payload found in notification');
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final medicationService = MedicationService();
    final reminderTime = payload['specificReminderTime'] ?? '';
    final medicationId = payload['medicationId'] ?? '';
    final medicationName = payload['medicationName'] ?? '';
    final doseQuantity = int.parse(payload['doseQuantity'] ?? '0');

    // Check for existing missed log
    final status = await medicationService.fetchLatestTakenAt(
      currentUser.uid,
      medicationId,
      DateTime.now(),
      reminderTime,
    );

    final isMissed = status?['status'] == 'missed';

    if (isMissed) {
      await medicationService.updateAdherenceLog(
        userUid: currentUser.uid,
        medicationId: medicationId,
        specificReminderTime: reminderTime,
        selectedDay: DateTime.now(),
        newStatus: 'taken'
      );
    } else {
      await medicationService.logAdherence(
        userUid: currentUser.uid,
        medicationId: medicationId,
        medicationName: medicationName,
        doseQuantity: doseQuantity,
        selectedDay: DateTime.now(),
        specificReminderTime: reminderTime,
        status: 'taken',
        followUpId: int.parse(payload['followUpId'] ?? '0'),
      );
    }

    // Update inventory
    await medicationService.updateInventory(medicationId, doseQuantity);

    // Refresh all medication cards
    MedicationCard.refreshAll();
    
  } else {
    print('No action taken. Logging missed medication.');
    // Existing code for logging missed medications
  }
}

@pragma('vm:entry-point')
Future<void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
  print('Notification displayed:');
  print('ID: ${receivedNotification.id}');
  print('Title: ${receivedNotification.title}');
  print('Body: ${receivedNotification.body}');
  print('Payload: ${receivedNotification.payload}');

  final payload = receivedNotification.payload;
  if (payload == null) {
    print('Payload is null');
    return;
  }

  // Check if this is a missed medication check
  if (payload['type'] == 'missed_check') {
    print('Processing missed medication check');

    final userUid = FirebaseAuth.instance.currentUser?.uid;
    if (userUid == null) {
      print('No user logged in');
      return;
    }

    final medicationService = MedicationService();

    // Check if medication was taken
    final latestTaken = await medicationService.fetchLatestTakenAt(
      userUid,
      payload['medicationId'] ?? '',
      DateTime.now(),
      payload['specificReminderTime'] ?? '',
    );

    print('Latest taken status: $latestTaken');

    // If no "taken" log exists, create a "missed" log
    if (latestTaken == null) {
      print('No taken log found, creating missed log');
      await medicationService.logAdherence(
        userUid: userUid,
        medicationId: payload['medicationId'] ?? '',
        medicationName: payload['medicationName'] ?? '',
        doseQuantity: int.parse(payload['doseQuantity'] ?? '0'),
        selectedDay: DateTime.now(),
        specificReminderTime: payload['specificReminderTime'] ?? '',
        status: 'missed',
      );
      print('Missed medication log created');
      MedicationCard.refreshAll();
    } else {
      print('Medication was already taken at: $latestTaken');
    }
  }
}

Future<void> scheduleAllNotifications() async {
  try {
    MedicationService medicationService = MedicationService();
    String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      print('No user is currently logged in.');
      return;
    }

    var medications = await FirebaseFirestore.instance.collection('medications').where('user_uid', isEqualTo: currentUserId).get();
    print('Fetched ${medications.docs.length} medications from Firestore.');
    
    // List to hold scheduled medications
    List<String> scheduledMedications = [];

    for (var doc in medications.docs) {
      var medication = doc.data();
      print('Scheduling reminders for medication: ${medication['name']}');
      
      // Handle "Every X Hours" frequency
      if (medication['frequency'] == 'Every X Hours' &&
          medication['interval_starting_time'] != null &&
          medication['interval_ending_time'] != null &&
          medication['interval_hour'] != null) {
        
        // Calculate reminder times for interval-based medication
        List<String> calculatedTimes = medicationService.calculateHourlyReminderTimes(
          medication['interval_starting_time'],
          medication['interval_ending_time'],
          medication['interval_hour']
        );
        
        // Schedule notifications for each calculated time
        for (String time in calculatedTimes) {
          print('Scheduling interval-based reminder at $time for ${medication['name']}');
          await NotificationService().scheduleMedicationReminder(
            doc.id,
            medication['name'],
            time,
            medication['dose_quantity'],
            medication['unit']
          );
          // Add to the list of scheduled medications
          scheduledMedications.add('${medication['name']} at $time (interval-based)');
        }
      }
      // Handle specific reminder times
      else if (medication['reminder_times'] != null && medication['name'] != null) {
        for (String time in List<String>.from(medication['reminder_times'])) {
          print('Scheduling reminder at $time for ${medication['name']}');
          await NotificationService().scheduleMedicationReminder(
            doc.id,
            medication['name'],
            time,
            medication['dose_quantity'],
            medication['unit'],
          );
          // Add to the list of scheduled medications
          scheduledMedications.add('${medication['name']} at $time');
        }
      }
    }
    
    // Print all scheduled medications
    if (scheduledMedications.isNotEmpty) {
      print('Scheduled Medications:');
      for (var scheduled in scheduledMedications) {
        print(scheduled);
      }
    } else {
      print('No medications scheduled.');
    }

  } catch (e) {
    print('Error scheduling notifications: $e');
  }
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  print('Firebase initialized.');

  await dotenv.load(fileName: ".env");
  print("API Key Loaded: ${dotenv.env['GOOGLE_MAPS_API_KEY'] ?? 'NOT FOUND'}");

  // Initialize NotificationService
  NotificationService notificationService = NotificationService();
  await notificationService.initializeNotification();
  print('NotificationService initialized.');

  // Initialize Awesome Notifications
  await AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'medication_channel',
        channelName: 'Medication Reminders',
        channelDescription: 'Channel for medication reminders',
        defaultColor: const Color.fromARGB(255, 27, 50, 126),
        ledColor: Colors.white,
        importance: NotificationImportance.High,
        channelShowBadge: true,
        soundSource: 'resource://raw/alarm_sound',
        playSound: true,
        enableVibration: true,
      ),
          NotificationChannel(
      channelKey: 'refill_channel',
      channelName: 'Refill Reminders',
      channelDescription: 'Channel for medication refill reminders',
      defaultColor: const Color.fromARGB(255, 126, 50, 27),
      ledColor: Colors.red,
      importance: NotificationImportance.High,
      channelShowBadge: true,
    ),
    ],
    debug: true,//change when cant run
  );
  print('AwesomeNotifications initialized.');

  // Set up the action listener for notifications
await AwesomeNotifications().setListeners(
  onActionReceivedMethod: onActionReceivedMethod,
  onNotificationCreatedMethod: (ReceivedNotification receivedNotification) async {
    print('Notification created: ${receivedNotification.title}');
    return;
  },
  onNotificationDisplayedMethod: onNotificationDisplayedMethod, // Add this listener
);
  print('Notification action listener set up.');

  // Cancel all existing notifications at app start to prevent previous set reminder pop up
  await notificationService.cancelAllMedicationReminders();

   // Set up a listener for medication changes
  String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
  if (currentUserId != null) {
    FirebaseFirestore.instance.collection('medications')
        .where('user_uid', isEqualTo: currentUserId)
        .snapshots()
        .listen((snapshot) {
          // Check if there are no medications
          if (snapshot.docs.isEmpty) {
            // Cancel all notifications if no medications are found
            NotificationService().cancelAllMedicationReminders();
          } else {
            // Handle changes in the medications collection
            for (var change in snapshot.docChanges) {
              if (change.type == DocumentChangeType.removed) {
                // Cancel the notification for the removed medication
                NotificationService().cancelMedicationReminder(change.doc.id);
              }
            }
            // Re-schedule notifications for the current medications
            //****
            // scheduleAllNotifications();
          }
        });
  }

  // Schedule notifications at app start
  await scheduleAllNotifications();
  print('All notifications scheduled.');

  NotificationService().monitorMedicationInventory();
  await MedicineDatabase.loadMedicines();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Medicine Reminder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      // Redirect to appropriate page based on authentication status
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            // User is logged in, navigate to the main app (Navbar)
            return const Navbar();
          }
          
          // User is not logged in, show the LoginPage
          return LoginPage();
        },
      ),
    );
  }
}
