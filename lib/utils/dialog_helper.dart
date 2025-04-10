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
