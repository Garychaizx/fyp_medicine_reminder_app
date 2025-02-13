import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class TaskVisualizationPage extends StatefulWidget {
  const TaskVisualizationPage({Key? key}) : super(key: key);

  @override
  _TaskVisualizationPageState createState() => _TaskVisualizationPageState();
}

class _TaskVisualizationPageState extends State<TaskVisualizationPage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  // Sample data: Replace this with your actual data from Firebase or local storage
  final Map<DateTime, List<Map<String, String>>> _medications = {
    DateTime(2024, 12, 25): [
      {'time': '8:00 AM', 'name': 'S', 'details': 'Take 1 pill(s)'},
      {'time': '8:00 AM', 'name': 'Vitamin D', 'details': 'Take 1 tablet'},
      {
        'time': '12:00 PM',
        'name': 'Lunch Medication',
        'details': 'Take after meal'
      },
    ],
    DateTime(2024, 12, 24): [
      {'time': '8:00 AM', 'name': 'S', 'details': 'Take 1 pill(s)'},
      {'time': '8:00 AM', 'name': 'Vitamin D', 'details': 'Take 1 tablet'},
      {
        'time': '12:00 PM',
        'name': 'Lunch Medication',
        'details': 'Take after meal'
      },
    ],
  };

  String _getDayDescription(DateTime day) {
    final now = DateTime.now();
    final today =
        DateTime(now.year, now.month, now.day); // Normalize to midnight
    final normalizedDay =
        DateTime(day.year, day.month, day.day); // Normalize `day`

    final difference = normalizedDay.difference(today).inDays;

    String prefix;
    if (difference == 0) {
      prefix = "Today";
    } else if (difference == 1) {
      prefix = "Tomorrow";
    } else if (difference == -1) {
      prefix = "Yesterday";
    } else {
      prefix = DateFormat('EEEE')
          .format(normalizedDay); // Weekday name (e.g., "Monday")
    }

    String formattedDate = DateFormat('dd MMMM').format(normalizedDay);
    return "$prefix, $formattedDate";
  }

  // Function to show the full calendar in a popup
  void _showFullCalendar() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(16),
            width: MediaQuery.of(context).size.width *
                0.8, // 80% of the screen width
            height: MediaQuery.of(context).size.height *
                0.5, // 60% of the screen height
            child: TableCalendar(
              focusedDay: _focusedDay,
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                Navigator.pop(context); // Close the popup after selection
              },
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Custom header with clickable title
          Padding(
            padding: const EdgeInsets.symmetric(vertical: .0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      _focusedDay = DateTime(
                        _focusedDay.year,
                        _focusedDay.month - 1,
                        _focusedDay.day, // Retain the day of the current month
                      );
                    });
                  },
                ),
                GestureDetector(
                  onTap: _showFullCalendar,
                  child: Text(
                    "${_monthName(_focusedDay.month)} ${_focusedDay.year}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      _focusedDay = DateTime(
                        _focusedDay.year,
                        _focusedDay.month + 1,
                        _focusedDay.day, // Retain the day of the current month
                      );
                    });
                  },
                ),
              ],
            ),
          ),
          // Weekly view calendar
          TableCalendar(
            focusedDay: _focusedDay, // Use the current focused day
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            calendarFormat: CalendarFormat.week, // Start in weekly view
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
            headerVisible: false, // Hide default header
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0.0),
            child: Text(
              _getDayDescription(_selectedDay), // Format the focused day
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.normal,
                color: Colors.blue[800],
              ),
            ),
          ),
          // const SizedBox(height: 16),

          // List of medications for the selected day
          Expanded(
            child: PageView.builder(
              controller: PageController(initialPage: 100), // Start from today
              onPageChanged: (index) {
                setState(() {
                  // Update the selected day based on the swipe
                  _selectedDay =
                      DateTime.now().add(Duration(days: index - 100));
                });
              },
              itemBuilder: (context, index) {
                // Calculate the day to display based on the index
                final swipedDay =
                    DateTime.now().add(Duration(days: index - 100));
                final normalizedDay = DateTime(
                  swipedDay.year,
                  swipedDay.month,
                  swipedDay.day,
                );

                // Get medications for the swiped day
                final medicationsForSelectedDay =
                    _medications[normalizedDay] ?? [];

                // Group medications by time
                final Map<String, List<Map<String, String>>>
                    groupedMedications = {};
                for (final medication in medicationsForSelectedDay) {
                  final time = medication['time'] ?? 'Unknown Time';
                  groupedMedications[time] ??= [];
                  groupedMedications[time]!.add(medication);
                }

                // Sort the times (keys) for consistent order
                final sortedTimes = groupedMedications.keys.toList()
                  ..sort((a, b) => DateFormat('h:mm a')
                      .parse(a)
                      .compareTo(DateFormat('h:mm a').parse(b)));

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: groupedMedications.length,
                        itemBuilder: (context, index) {
                          final time = sortedTimes[index];
                          final medications = groupedMedications[time]!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Time header
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                child: Text(
                                  time,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              // Medication cards for the current time
                              ...medications.map((medication) {
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 16),
                                  child: ListTile(
                                    leading: const Icon(Icons.medication),
                                    title: Text(
                                        medication['name'] ?? 'Medication'),
                                    subtitle: Text(medication['details'] ??
                                        'No details available'),
                                  ),
                                );
                              }),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to get the month name
  String _monthName(int month) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return monthNames[month -
        1]; //need to minus 1 as array is from 0-11 and the month we get will be eg:(december,12) and dsecemeber is in monthNames[11]
  }
}
