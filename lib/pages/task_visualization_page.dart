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
      backgroundColor: const Color(0xFFF8F4F1),
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
                color: Color.fromARGB(255, 255, 110, 110), // Using ARGB format in hex
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Color.fromARGB(255, 252, 52, 68),
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
                color: Color.fromARGB(255, 16, 15, 15), // Matched color
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

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Show the time header
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16.0, top: 8.0, bottom: 4.0),
                          child: TimeHeader(time: time),
                        ),

                        // Only show medications that actually match this reminder time
                        ...meds.where((medication) {
                          List<String> reminderTimes = List<String>.from(
                              medication['reminder_times'] ?? []);

                          // If "Every X Hours", dynamically calculate the reminder times
                          if (medication['frequency'] == 'Every X Hours' &&
                              medication
                                  .containsKey('interval_starting_time') &&
                              medication.containsKey('interval_ending_time') &&
                              medication.containsKey('interval_hour')) {
                            reminderTimes =
                                _medicationService.calculateHourlyReminderTimes(
                              medication['interval_starting_time'],
                              medication['interval_ending_time'],
                              medication['interval_hour'],
                            );
                          }

                          return reminderTimes
                              .contains(time); // Only show if it matches
                        }).map((medication) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: MedicationCard(
                              name: medication['name'] ?? 'Unknown Medication',
                              unit: medication['unit'] ?? '',
                              doseQuantity: medication['dose_quantity'] ?? 0,
                              medicationId: medication['id'],
                              selectedDay: _selectedDay,
                              reminderTimes: [
                                time
                              ], // Only show the relevant reminder time
                              imageBase64:medication['imageBase64'],
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

