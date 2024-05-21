import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CameraHelper {
  static Future<File?> takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      return File(pickedFile.path);
    } else {
      print('No image selected.');
      return null;
    }
  }
}
