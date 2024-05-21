import 'dart:io';
import 'package:path_provider/path_provider.dart';

class GalleryHelper {
  static Future<List<File>> fetchImages() async {
    try {
      // Dapatkan direktori penyimpanan eksternal yang berisi foto-foto
      Directory? directory = await getExternalStorageDirectory();
      if (directory != null) {
        // Dapatkan daftar file yang ada di direktori tersebut
        List<FileSystemEntity> files = directory.listSync();
        // Filter hanya file gambar (JPEG, PNG, dsb.)
        List<File> images = files.whereType<File>().where((file) {
          return file.path.endsWith('.jpg') ||
              file.path.endsWith('.jpeg') ||
              file.path.endsWith('.png');
        }).toList();
        return images;
      } else {
        print('External storage directory not found');
        return [];
      }
    } catch (e) {
      print('Error fetching images: $e');
      return [];
    }
  }
}
