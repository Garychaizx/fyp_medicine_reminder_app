import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:medicine_reminder/navbar.dart';
import 'package:medicine_reminder/services/notification_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Add this static method to receive notification actions
@pragma('vm:entry-point')
Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
  if (receivedAction.buttonKeyInput == 'MARK_TAKEN') {
    // Handle mark as taken action
  } else if (receivedAction.buttonKeyInput == 'SNOOZE') {
    // Handle snooze action
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Initialize NotificationService
  NotificationService notificationService = NotificationService();
  await notificationService.initializeNotification();

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
      ),
    ],
    debug: true
  );

  // Set up the action listener
  await AwesomeNotifications().setListeners(
    onActionReceivedMethod: onActionReceivedMethod,
  );

  // Fetch medications and schedule notifications on app startup
  FirebaseFirestore.instance.collection('medications').get().then((snapshot) {
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final medicationId = doc.id;
      final medicationName = data['name'];
      final reminderTime = data['reminder_time'];

      // Use the instance of notificationService to schedule notifications
      notificationService.scheduleMedicationReminder(
          medicationId, medicationName, reminderTime);
    }
  }).catchError((error) {
    debugPrint('Error fetching medications: $error');
  });

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
      home: const Navbar(),
    );
  }
}