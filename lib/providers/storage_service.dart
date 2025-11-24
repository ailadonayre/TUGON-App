import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProfilePicture(String userId, XFile file) async {
    try {
      final ref = _storage.ref().child('profile_pictures').child('$userId.jpg');

      final uploadTask = await ref.putFile(File(file.path));

      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      throw Exception('Error uploading profile picture: ${e.message}');
    } catch (e) {
      throw Exception('An unknown error occurred during image upload.');
    }
  }
}
