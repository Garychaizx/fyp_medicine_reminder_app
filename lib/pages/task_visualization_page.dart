import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/medication_service.dart';
import '../widgets/time_header.dart';
import '../widgets/medication_card.dart';

class TaskVisualizationPage extends StatefulWidget {
  const TaskVisualizationPage({Key? key}) : super(key: key);

  @override
  _TaskVisualizationPageState createState() => _TaskVisualizationPageState();
}

class _TaskVisualizationPageState extends State<TaskVisualizationPage> {
  final MedicationService _medicationService = MedicationService();
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  String _getDayDescription(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final difference = day.difference(today).inDays;

    if (difference == 0) return "Today, ${DateFormat('dd MMMM').format(day)}";
    if (difference == 1)
      return "Tomorrow, ${DateFormat('dd MMMM').format(day)}";
    if (difference == -1)
      return "Yesterday, ${DateFormat('dd MMMM').format(day)}";
    return "${DateFormat('EEEE').format(day)}, ${DateFormat('dd MMMM').format(day)}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Weekly view calendar
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            calendarFormat: CalendarFormat.week,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Color(0xFF8B9EB7), // Using ARGB format in hex
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Color.fromARGB(255, 11, 24, 66),
                shape: BoxShape.circle,
              ),
            ),
            headerVisible: false,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              _getDayDescription(_focusedDay),
              style: const TextStyle(
                fontSize: 20, // Increased font size
                fontWeight: FontWeight.bold, // Bolder font weight
                color: Color.fromARGB(255, 88, 88, 88), // Matched color
                fontFamily: 'Roboto', // Optional: Set preferred font
              ),
              textAlign: TextAlign.center, // Optional: center alignment
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey[00], // Adjust color to match your design
          ),
          // Medications List
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _medicationService.fetchMedicationsForUser(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error fetching data.'));
                }

                final medications = snapshot.data ?? [];
                final groupedMedications = _medicationService
                    .groupMedicationsByTime(medications, _selectedDay);
                final sortedTimes = groupedMedications.keys.toList()
                  ..sort((a, b) => DateFormat('h:mm a')
                      .parse(a)
                      .compareTo(DateFormat('h:mm a').parse(b)));

                return ListView.builder(
                  itemCount: groupedMedications.length,
                  itemBuilder: (context, index) {
                    final time = sortedTimes[index];
                    final meds = groupedMedications[time]!;
                    // print('Initial selected day: $_selectedDay');

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: TimeHeader(time: time),
                        ),
                        ...meds.map((medication) {
                          List<String> reminderTimes = List<String>.from(
                              medication['reminder_times'] ?? []);

                          // Check if medication follows "Every X Hours" pattern
                          if (medication['frequency'] == 'Every X Hours' &&
                              medication
                                  .containsKey('interval_starting_time') &&
                              medication.containsKey('interval_ending_time') &&
                              medication.containsKey('interval_hour')) {
                            // Dynamically calculate the reminder times
                            reminderTimes =
                                _medicationService.calculateHourlyReminderTimes(
                              medication['interval_starting_time'],
                              medication['interval_ending_time'],
                              medication['interval_hour'],
                            );
                          }

                          return Padding(
                            padding: const EdgeInsets.only(
                                bottom: 8.0), // Adds space below each card
                            child: MedicationCard(
                              name: medication['name'] ?? 'Unknown Medication',
                              unit: medication['unit'] ?? '',
                              doseQuantity: medication['dose_quantity'] ?? 0,
                              medicationId: medication['id'],
                              selectedDay: _selectedDay,
                              reminderTimes:
                                  reminderTimes, // Updated reminder times
                            ),
                          );
                        }),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';
// import 'package:table_calendar/table_calendar.dart';

// class TaskVisualizationPage extends StatefulWidget {
//   const TaskVisualizationPage({Key? key}) : super(key: key);

//   @override
//   _TaskVisualizationPageState createState() => _TaskVisualizationPageState();
// }

// class _TaskVisualizationPageState extends State<TaskVisualizationPage> {
//   DateTime _selectedDay = DateTime.now();
//   DateTime _focusedDay = DateTime.now();

//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   late User? currentUser;

//   @override
//   void initState() {
//     super.initState();
//     currentUser = _auth.currentUser;
//   }

//   String _getDayDescription(DateTime day) {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final difference = day.difference(today).inDays;

//     String prefix;
//     if (difference == 0) {
//       prefix = "Today";
//     } else if (difference == 1) {
//       prefix = "Tomorrow";
//     } else if (difference == -1) {
//       prefix = "Yesterday";
//     } else {
//       prefix = DateFormat('EEEE').format(day); // Weekday name (e.g., "Monday")
//     }

//     String formattedDate = DateFormat('dd MMMM').format(day);
//     return "$prefix, $formattedDate";
//   }

//   // Function to show the full calendar in a popup
//   void _showFullCalendar() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return Dialog(
//           child: Container(
//             padding: const EdgeInsets.all(16),
//             width: MediaQuery.of(context).size.width *
//                 0.8, // 80% of the screen width
//             height: MediaQuery.of(context).size.height *
//                 0.5, // 60% of the screen height
//             child: TableCalendar(
//               focusedDay: _focusedDay,
//               firstDay: DateTime.utc(2020, 1, 1),
//               lastDay: DateTime.utc(2030, 12, 31),
//               selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
//               onDaySelected: (selectedDay, focusedDay) {
//                 setState(() {
//                   _selectedDay = selectedDay;
//                   _focusedDay = focusedDay;
//                 });
//                 Navigator.pop(context); // Close the popup after selection
//               },
//               calendarStyle: const CalendarStyle(
//                 todayDecoration: BoxDecoration(
//                   color: Colors.blueAccent,
//                   shape: BoxShape.circle,
//                 ),
//                 selectedDecoration: BoxDecoration(
//                   color: Colors.orange,
//                   shape: BoxShape.circle,
//                 ),
//               ),
//               headerStyle: const HeaderStyle(
//                 formatButtonVisible: false,
//                 titleCentered: true,
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (currentUser == null) {
//       return const Center(
//         child: Text('Error: User not logged in'),
//       );
//     }

//     return Scaffold(
//       body: Column(
//         children: [
//           // Custom header with clickable title
//           // Padding(
//           //   padding: const EdgeInsets.symmetric(vertical: .0),
//           //   child: Row(
//           //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           //     children: [
//           //       IconButton(
//           //         icon: const Icon(Icons.chevron_left),
//           //         onPressed: () {
//           //           setState(() {
//           //             _focusedDay = DateTime(
//           //               _focusedDay.year,
//           //               _focusedDay.month - 1,
//           //               _focusedDay.day, // Retain the day of the current month
//           //             );
//           //           });
//           //         },
//           //       ),
//           //       GestureDetector(
//           //         onTap: _showFullCalendar,
//           //         child: Text(
//           //           "${_monthName(_focusedDay.month)} ${_focusedDay.year}",
//           //           style: const TextStyle(
//           //             fontSize: 18,
//           //             fontWeight: FontWeight.bold,
//           //           ),
//           //         ),
//           //       ),
//           //       IconButton(
//           //         icon: const Icon(Icons.chevron_right),
//           //         onPressed: () {
//           //           setState(() {
//           //             _focusedDay = DateTime(
//           //               _focusedDay.year,
//           //               _focusedDay.month + 1,
//           //               _focusedDay.day, // Retain the day of the current month
//           //             );
//           //           });
//           //         },
//           //       ),
//           //     ],
//           //   ),
//           // ),
//           // Weekly view calendar
//           TableCalendar(
//             focusedDay: _focusedDay, // Use the current focused day
//             firstDay: DateTime.utc(2020, 1, 1),
//             lastDay: DateTime.utc(2030, 12, 31),
//             calendarFormat: CalendarFormat.week, // Start in weekly view
//             selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
//             onDaySelected: (selectedDay, focusedDay) {
//               setState(() {
//                 _selectedDay = selectedDay;
//                 _focusedDay = focusedDay;
//               });
//             },
//             calendarStyle: const CalendarStyle(
//               todayDecoration: BoxDecoration(
//                 color: Colors.blueAccent,
//                 shape: BoxShape.circle,
//               ),
//               selectedDecoration: BoxDecoration(
//                 color: Colors.orange,
//                 shape: BoxShape.circle,
//               ),
//             ),
//             headerVisible: false, // Hide default header
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 0.0),
//             child: Text(
//               _getDayDescription(_focusedDay), // Format the focused day
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.normal,
//                 color: Colors.blue[800],
//               ),
//             ),
//           ),
          
//           // StreamBuilder to fetch medications from Firestore
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('medications')
//                   .where('user_uid', isEqualTo: currentUser!.uid)
//                   .snapshots(),
//               builder: (context, snap) {
//                 if (snap.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 if (snap.hasError) {
//                   return const Center(child: Text('Error fetching data.'));
//                 }

//                 final medications = snap.data!.docs
//                     .map((doc) => doc.data() as Map<String, dynamic>)
//                     .toList();

//                 final medicationsForSelectedDay = medications.where((medication) {
//                   final createdAt = (medication['created_at'] as Timestamp).toDate();
//                   return createdAt.isBefore(_selectedDay) ||
//                       createdAt.isAtSameMomentAs(_selectedDay);
//                 }).toList();

//                 // Group medications by time
//                 final Map<String, List<Map<String, dynamic>>> groupedMedications = {};
//                 for (final medication in medicationsForSelectedDay) {
//                   final reminderTimes = List<String>.from(medication['reminder_times'] ?? []);
//                   for (final time in reminderTimes) {
//                     groupedMedications[time] ??= [];
//                     groupedMedications[time]!.add({
//                       'name': medication['name'],
//                       'details': medication['details'],
//                       'time': time,
//                     });
//                   }
//                 }

//                 // Sort the times (keys) for consistent order
//                 final sortedTimes = groupedMedications.keys.toList()
//                   ..sort((a, b) => DateFormat('h:mm a').parse(a).compareTo(DateFormat('h:mm a').parse(b)));

//                 return ListView.builder(
//                   itemCount: groupedMedications.length,
//                   itemBuilder: (context, index) {
//                     final time = sortedTimes[index];
//                     final medications = groupedMedications[time]!;

//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Time header
//                         Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//                           child: Text(
//                             time,
//                             style: const TextStyle(
//                               fontSize: 22,
//                               fontWeight: FontWeight.w500,
//                               color: Colors.black,
//                             ),
//                           ),
//                         ),
//                         // Medication cards for the current time
//                         ...medications.map((medication) {
//                           return Card(
//                             margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
//                             child: ListTile(
//                               leading: const Icon(Icons.medication),
//                               title: Text(medication['name'] ?? 'Medication'),
//                               subtitle: Text(medication['details'] ?? 'No details available'),
//                             ),
//                           );
//                         }).toList(),
//                       ],
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Helper function to get the month name
//   String _monthName(int month) {
//     const monthNames = [
//       'January',
//       'February',
//       'March',
//       'April',
//       'May',
//       'June',
//       'July',
//       'August',
//       'September',
//       'October',
//       'November',
//       'December'
//     ];
//     return monthNames[month - 1];
//   }
// }
