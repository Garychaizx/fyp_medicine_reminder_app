// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:medicine_reminder/add_medication_form.dart';

// // Assuming you have an AddMedicationForm page defined somewhere else in your project
// // Import your AddMedicationForm here

// class MedicationsPage extends StatelessWidget {
//   const MedicationsPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: const Text('Medications'),
//           backgroundColor: Colors.blue[100],
//         ),
//         body: StreamBuilder(
//             stream: FirebaseFirestore.instance
//                 .collection('medications')
//                 .snapshots(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//               // Check if there is medication data
//               final hasMedications =
//                   snapshot.hasData && snapshot.data!.docs.isNotEmpty;

//               return Column(
//                 children: [
//                   if (!hasMedications)
//                     Expanded(
//                       // Expands the content to fill the available space
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Center(
//                             child: Container(
//                               width: 150, // Set the width of the circle
//                               height: 150, // Set the height of the circle
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: Colors.grey[
//                                     200], // Background color of the circle
//                               ),
//                               child: ClipOval(
//                                 child: Image.asset(
//                                   'assets/giphy.gif', // Replace with your GIF asset
//                                   fit: BoxFit.cover, // Cover the entire circle
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(
//                               height:
//                                   20), // Add 20 pixels of space between the GIF and the text
//                           const Text(
//                             'Manage Your Meds',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const Text(
//                             'Add your meds to be reminded on time \n and track your health',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               color: Color.fromARGB(255, 150, 145, 145),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   if (hasMedications)
//                     Expanded(
//                       child: ListView.builder(
//                         itemCount: snapshot.data!.docs.length,
//                         itemBuilder: (context, index) {
//                           var medication = snapshot.data!.docs[index].data();
//                           return Card(
//                             margin: const EdgeInsets.symmetric(
//                                 horizontal: 16.0, vertical: 8.0),
//                                 elevation: 4,
//                             child: ListTile(
//                               title: Text(medication['name'] ?? 'No Name'),
//                               subtitle: Text(
//                                   medication['frequency'] ?? 'No Frequency'),
//                               trailing: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Text(
//                                       '${medication['current_inventory']} ${medication['unit']} left'),
//                                   const Icon(Icons.alarm, color: Colors.green),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   Padding(
//                     padding: const EdgeInsets.all(
//                         20.0), // Add padding around the button
//                     child: SizedBox(
//                       width: double.infinity, // Make the button full-width
//                       child: ElevatedButton(
//                         onPressed: () {
//                           // Navigate to the AddMedicationForm page
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => AddMedicationForm(),
//                             ),
//                           );
//                         },
//                         child: const Text('Add Medication'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor:
//                               const Color.fromARGB(255, 27, 50, 126),
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(
//                               vertical: 15.0), // Vertical padding
//                           shape: RoundedRectangleBorder(
//                             borderRadius:
//                                 BorderRadius.circular(30.0), // Rounded corners
//                           ),
//                           textStyle: const TextStyle(
//                             fontSize: 18, // Font size
//                             fontWeight: FontWeight.bold, // Font weight
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               );
//             }));
//   }
// }
