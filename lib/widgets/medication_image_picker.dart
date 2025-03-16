// lib/widgets/medication_form/medication_image_picker.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:medicine_reminder/services/image_service.dart';

class MedicationImagePicker extends StatelessWidget {
  final File? medicationImage;
  final Function(File, String) onImagePicked;
  final VoidCallback onImageRemoved;

  const MedicationImagePicker({
    Key? key,
    required this.medicationImage,
    required this.onImagePicked,
    required this.onImageRemoved,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ImageService _imageService = ImageService();

    return Column(
      children: [
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final File? pickedImage = await _imageService.pickImage();
            if (pickedImage != null) {
              final String? base64Image = _imageService.encodeImageToBase64(pickedImage);
              if (base64Image != null) {
                onImagePicked(pickedImage, base64Image);
              }
            }
          },
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade200,
            ),
            child: medicationImage != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          medicationImage!,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 8,
                        child: GestureDetector(
                          onTap: onImageRemoved,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: const Icon(Icons.cancel,
                                color: Colors.red, size: 20),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.photo_camera,
                          size: 40, color: Colors.grey),
                      const SizedBox(height: 8),
                      Text(
                        "Tap to upload",
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}