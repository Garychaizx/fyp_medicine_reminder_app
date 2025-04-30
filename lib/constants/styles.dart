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
        borderSide: BorderSide(color: Color.fromARGB(255, 56, 26, 3), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    minimumSize: const Size(400, 40),
    backgroundColor: Color.fromARGB(255, 56, 26, 3),
    foregroundColor: Color(0xFFF8F4F1),
    padding: const EdgeInsets.symmetric(vertical: 15.0),
    textStyle: const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    ),
  );

  static ButtonStyle secondaryButtonStyle = ElevatedButton.styleFrom(
    minimumSize: const Size(400, 40),
    backgroundColor: const Color.fromARGB(255, 255, 234, 219),
    foregroundColor: Color.fromARGB(255, 56, 26, 3),
    padding: const EdgeInsets.symmetric(vertical: 15.0),
    textStyle: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  );
  
  static ButtonStyle deleteButtonStyle = ElevatedButton.styleFrom(
    minimumSize: const Size(400, 40),
    backgroundColor: const Color.fromARGB(173, 238, 49, 49),
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 15.0),
    textStyle: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  );

  static ButtonStyle submitButtonStyle = ElevatedButton.styleFrom(
    minimumSize: const Size(400, 40),
    backgroundColor: Color.fromARGB(255, 56, 26, 3),
    foregroundColor: Color(0xFFF8F4F1),
    padding: const EdgeInsets.symmetric(vertical: 15.0),
    textStyle: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  );
}