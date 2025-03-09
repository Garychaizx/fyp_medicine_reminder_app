import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medicine_reminder/add_medication_form.dart';
import 'package:medicine_reminder/constants/styles.dart';
import 'package:medicine_reminder/widgets/custom_form_field.dart';
import 'package:medicine_reminder/widgets/custom_dropdown.dart';

class Step1 extends StatefulWidget {
  final FormData formData;
  final VoidCallback onNext;
  final bool hasAttempted;

  const Step1({
    super.key,
    required this.formData,
    required this.onNext,
    required this.hasAttempted,
  });

  @override
  _Step1State createState() => _Step1State();
}

class _Step1State extends State<Step1> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      // Convert image to Base64
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64String = base64Encode(imageBytes);

      setState(() {
        widget.formData.medicationImage =
            imageFile; // Store image file for UI display
        widget.formData.imageBase64 = base64String; // Store Base64 string
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Image.asset('assets/medication.png',
                height: 150, fit: BoxFit.contain),
          ),
          CustomFormField(
            controller: widget.formData.medicationNameController,
            label: 'Medication Name',
            errorText: widget.hasAttempted &&
                    widget.formData.medicationNameController.text.isEmpty
                ? 'Medication name is required'
                : null,
          ),
          CustomDropdown(
            value: widget.formData.unit,
            items: const ['ml', 'pill(s)', 'gram(s)', 'spray(s)'],
            onChanged: (value) => setState(() => widget.formData.unit = value),
            label: 'Unit',
            errorText: widget.hasAttempted && widget.formData.unit == null
                ? 'Please select a unit'
                : null,
          ),
          CustomFormField(
            controller: widget.formData.inventoryController,
            label: 'Current Inventory (Amounts)',
            keyboardType: TextInputType.number,
            errorText: widget.hasAttempted &&
                    widget.formData.inventoryController.text.isEmpty
                ? 'Current Inventory is required'
                : null,
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.translate(
                offset: const Offset(-50, 0), // Moves it 10 pixels left
                child: const Text(
                  'Upload Medication Photo (Optional)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Transform.translate(
                offset: const Offset(-40, 0),
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade200,
                    ),
                    child: widget.formData.medicationImage != null
                        ? Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  widget.formData.medicationImage!,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              // Remove Image Button (Top Right)
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      widget.formData.medicationImage = null;
                                      widget.formData.imageBase64 = null;
                                    });
                                  },
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
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 380,
            child: ElevatedButton(
              onPressed: widget.onNext,
              style: AppStyles.primaryButtonStyle,
              child: const Text('Next'),
            ),
          ),
        ],
      ),
    );
  }
}
