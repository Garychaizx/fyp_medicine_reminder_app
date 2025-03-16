// lib/services/image_service.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();
  bool _isPickingImage = false;

  Future<File?> pickImage() async {
    if (_isPickingImage) return null;
    _isPickingImage = true;

    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    } finally {
      _isPickingImage = false;
    }
    return null;
  }

  String? encodeImageToBase64(File? image) {
    if (image == null) return null;
    try {
      return base64Encode(image.readAsBytesSync());
    } catch (e) {
      debugPrint("Error encoding image: $e");
      return null;
    }
  }

  Future<File?> loadImageFromBase64(String base64String) async {
    try {
      Uint8List imageBytes = base64Decode(base64String);
      Directory tempDir = await getTemporaryDirectory();
      String uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}.png';
      File imageFile = File('${tempDir.path}/$uniqueFileName');
      await imageFile.writeAsBytes(imageBytes);
      return imageFile;
    } catch (e) {
      debugPrint("Error loading image from base64: $e");
      return null;
    }
  }
}