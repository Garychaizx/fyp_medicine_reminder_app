import 'package:flutter/material.dart';
import 'package:medicine_reminder/add_medication_form.dart';

// Assuming you have an AddMedicationForm page defined somewhere else in your project
// Import your AddMedicationForm here

class MedicationsPage extends StatelessWidget {
  const MedicationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medications'),
        backgroundColor: Colors.blue[100],
      ),
      body: Column(
        children: [
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
                      color: Colors.grey[200], // Background color of the circle
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
          Padding(
            padding:
                const EdgeInsets.all(20.0), // Add padding around the button
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
                  backgroundColor: const Color.fromARGB(255, 27, 50, 126),
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
      ),
    );
  }
}
