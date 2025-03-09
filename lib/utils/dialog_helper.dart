import 'dart:convert';
import 'package:flutter/material.dart';

void showImageDialog(BuildContext context, String base64Image) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Image.memory(base64Decode(base64Image), fit: BoxFit.contain),
      );
    },
  );
}
