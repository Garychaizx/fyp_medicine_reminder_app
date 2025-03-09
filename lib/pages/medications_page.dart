import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medicine_reminder/edit_medication_form.dart';
import 'package:medicine_reminder/widgets/medication_details_card.dart';
import '../widgets/medication_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/add_medication_button.dart';

class MedicationsPage extends StatelessWidget {
  const MedicationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(child: Text('Error: User not logged in'));
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
              if (!hasMedications) const EmptyState(),
              if (hasMedications)
                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var medication = snapshot.data!.docs[index].data();
                      var medicationId = snapshot.data!.docs[index].id;

                      return MedicationDetailsCard(
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
              const AddMedicationButton(),
            ],
          );
        },
      ),
    );
  }
}
