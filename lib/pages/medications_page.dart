import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:medicine_reminder/add_medication_form.dart';
import 'package:medicine_reminder/services/notification_service.dart';
// import 'package:medicine_reminder/services/notification_service.dart';

// Assuming you have an AddMedicationForm page defined somewhere else in your project
// Import your AddMedicationForm here

class MedicationsPage extends StatelessWidget {
  const MedicationsPage({super.key});
void _scheduleNotification(String id, Map<String, dynamic> medication) {
  if (medication['reminder_time'] != null && medication['name'] != null) {
    NotificationService().scheduleMedicationReminder(
      id,
      medication['name'],
      medication['reminder_time'],
    );
    debugPrint('Scheduling medicine notification for: ${medication['reminder_time']}');
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Medications'),
          backgroundColor: Colors.blue[100],
        ),
        body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('medications')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              // Check if there is medication data
              final hasMedications =
                  snapshot.hasData && snapshot.data!.docs.isNotEmpty;

              return Column(
                children: [
                  if (!hasMedications)
                    Expanded(
                      // Expands the content to fill the available space
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Container(
                              width: 150, // Set the width of the circle
                              height: 150, // Set the height of the circle
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[
                                    200], // Background color of the circle
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/giphy.gif', // Replace with your GIF asset
                                  fit: BoxFit.cover, // Cover the entire circle
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                              height:
                                  20), // Add 20 pixels of space between the GIF and the text
                          const Text(
                            'Manage Your Meds',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Add your meds to be reminded on time \n and track your health',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color.fromARGB(255, 150, 145, 145),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (hasMedications)
                    Expanded(
                      child: ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var medication = snapshot.data!.docs[index].data();
                          // Inside ListView.builder
var medicationId = snapshot.data!.docs[index].id;
_scheduleNotification(medicationId, medication);
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            elevation: 4, // Add some shadow
                            // shape: RoundedRectangleBorder(
                            //   borderRadius:
                            //       BorderRadius.circular(15), // Rounded corners
                            // ),
                            child: Container(
                              // padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Left side - Medicine Icon
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[50],
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.medication,
                                          size: 40,
                                          color:
                                              Color.fromARGB(255, 27, 50, 126),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      // Right side - Medicine Details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              medication['name'] ?? 'No Name',
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                const Icon(Icons.schedule,
                                                    size: 16,
                                                    color: Colors.grey),
                                                const SizedBox(width: 4),
                                                Text(
                                                  medication['frequency'] ??
                                                      'No Frequency',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  // const SizedBox(height: 16),
                                  // Bottom section
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Inventory
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Current Inventory',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
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
                                        // Next Reminder
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.alarm,
                                              color: Color.fromARGB(
                                                  255, 27, 50, 126),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              medication['reminder_time'] ??
                                                  'No reminder set',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(
                        20.0), // Add padding around the button
                    child: SizedBox(
                      width: double.infinity, // Make the button full-width
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to the AddMedicationForm page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddMedicationForm(),
                            ),
                          );
                        },
                        child: const Text('Add Medication'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 27, 50, 126),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 15.0), // Vertical padding
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(30.0), // Rounded corners
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18, // Font size
                            fontWeight: FontWeight.bold, // Font weight
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }));
  }
}
