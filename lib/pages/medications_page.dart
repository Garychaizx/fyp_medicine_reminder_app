import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medicine_reminder/add_medication_form.dart';
import 'package:medicine_reminder/constants/styles.dart';
import 'package:medicine_reminder/edit_medication_form.dart';
import 'package:medicine_reminder/services/medication_service.dart';
// import 'add_medication_form.dart';
// import 'edit_medication_form.dart';

class MedicationsPage extends StatelessWidget {
  const MedicationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(
        child: Text('Error: User not logged in'),
      );
    }

    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('medications')
            .where('user_uid', isEqualTo: currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final hasMedications =
              snapshot.hasData && snapshot.data!.docs.isNotEmpty;

          return Column(
            children: [
              if (!hasMedications) const _EmptyState(),
              if (hasMedications)
                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var medication = snapshot.data!.docs[index].data();
                      var medicationId = snapshot.data!.docs[index].id;

                      return MedicationCard(
                        medication: medication,
                        medicationId: medicationId,
                        onEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditMedicationForm(
                                medicationId: medicationId,
                                medicationData: medication,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              _AddMedicationButton(),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/giphy.gif',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Manage Your Meds',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Add your meds to be reminded on time \nand track your health',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color.fromARGB(255, 150, 145, 145)),
          ),
        ],
      ),
    );
  }
}

class MedicationCard extends StatelessWidget {
  final Map<String, dynamic> medication;
  final String medicationId;
  final VoidCallback onEdit;

  const MedicationCard({
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
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.medication,
                    size: 40,
                    color: Color.fromARGB(255, 27, 50, 126),
                  ),
                  const SizedBox(width: 16),
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
                        const SizedBox(height: 8),
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
                children: reminderTimes
                    .map((time) => Chip(
                          label: Text(time),
                          backgroundColor: Colors.blue[100],
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
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

class _AddMedicationButton extends StatelessWidget {
  const _AddMedicationButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddMedicationForm(
                  medicationService: MedicationService(),
                ),
              ),
            );
          },
          style: AppStyles.primaryButtonStyle,
          child: const Text('Add Medication'),
        ),
      ),
    );
  }
}
