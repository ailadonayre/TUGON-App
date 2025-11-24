import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  final Box _userProfileBox = Hive.box('user_profile');

  Future<String?> uploadProfilePicture(String userId) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        maxWidth: 1024,
      );

      if (pickedFile == null) {
        print('No image selected.');
        return null;
      }

      const int maxFileSize = 2 * 1024 * 1024;
      final int fileSize = await pickedFile.length();

      if (fileSize > maxFileSize) {
        throw Exception(
            'Image is too large. Please select an image smaller than 2 MB.');
      }

      final imageBytes = await pickedFile.readAsBytes();

      await _userProfileBox.put('profile_image', imageBytes);

      final ref = _storage.ref().child('profile_pictures').child('$userId.jpg');
      final uploadTask = await ref.putFile(File(pickedFile.path));
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;

    } on FirebaseException catch (e) {
      throw Exception('Error uploading profile picture: ${e.message}');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<String> uploadReportImage(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) {
        throw Exception('File does not exist at path: $path');
      }

      const int maxFileSize = 5 * 1024 * 1024;
      final int fileSize = await file.length();

      if (fileSize > maxFileSize) {
        throw Exception(
            'Report image is too large. Please select an image smaller than 5 MB.');
      }

      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}-${p.basename(path)}';

      final ref = _storage.ref().child('report_images').child(fileName);

      final uploadTask = await ref.putFile(file);

      final String downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;

    } on FirebaseException catch (e) {
      throw Exception('Error uploading report image: ${e.message}');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
