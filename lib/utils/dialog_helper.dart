import 'dart:convert';
import 'package:flutter/material.dart';

  void showImageDialog(BuildContext context, String imageBase64) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(
                    base64Decode(imageBase64),
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
                CircleAvatar(
                  backgroundColor:
                      const Color.fromARGB(255, 237, 214, 197), // background
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    color: Colors.black, // icon color
                    onPressed: () => Navigator.pop(context),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

void showAdherenceSuggestionDialog(
  BuildContext context,
  String medicationName,
  String currentTime,
  String suggestedTime,
  String reason,
  Function onAccept,
) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Add a GIF at the top
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/reminder.gif', // Replace with your GIF path
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            // Title
            const Text(
              'Try a better time',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12), // Slightly increased spacing for better separation
            Text(
              'Missed your $medicationName at $currentTime?',
              style: const TextStyle(fontSize: 16, color: Colors.black87), // Slightly larger and darker for better readability
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Change reminder to $suggestedTime?',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black), // Slightly larger and bold for emphasis
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24), // Increased spacing before buttons
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Cancel Button
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Add padding for better touch target
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min, // Make Row take minimum space
                    children: [
                      Icon(Icons.close, color: Colors.black),
                      SizedBox(width: 8),
                      Text(
                        'Close',
                        style: TextStyle(color: Colors.black, fontSize: 16), // Slightly larger text
                      ),
                    ],
                  ),
                ),
                // Change Time Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onAccept();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Add padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min, // Make Row take minimum space
                    children: [
                      Icon(Icons.edit, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Accept',
                        style: TextStyle(color: Colors.white, fontSize: 16), // Slightly larger text
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
