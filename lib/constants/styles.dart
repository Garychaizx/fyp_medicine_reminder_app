import 'package:flutter/material.dart';

class AppStyles {
  static const double padding = 15.0;
  static const double borderRadius = 12.0;
  static const primaryColor = Color.fromARGB(255, 11, 24, 66);
  
  static InputDecoration getInputDecoration(String label, String? errorText) {
    return InputDecoration(
      labelText: label,
      errorText: errorText,
      labelStyle: TextStyle(color: Colors.grey[700]),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    minimumSize: const Size(400, 40),
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 15.0),
    textStyle: const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    ),
  );

  static ButtonStyle secondaryButtonStyle = ElevatedButton.styleFrom(
    minimumSize: const Size(400, 40),
    backgroundColor: Colors.blueGrey.shade200,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 15.0),
    textStyle: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  );
  
  static ButtonStyle deleteButtonStyle = ElevatedButton.styleFrom(
    minimumSize: const Size(400, 40),
    backgroundColor: Colors.red[300],
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 15.0),
    textStyle: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  );

  static ButtonStyle submitButtonStyle = ElevatedButton.styleFrom(
    minimumSize: const Size(400, 40),
    backgroundColor: Colors.teal[700],
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 15.0),
    textStyle: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  );
}