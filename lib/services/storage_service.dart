import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // TODO: Configure your Firebase Storage bucket in Firebase Console
  // This is a placeholder implementation

  Future<String?> uploadProfilePicture(String userId) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image == null) return null;

      final file = File(image.path);
      final ref = _storage.ref().child('profile_pictures/$userId.jpg');

      await ref.putFile(file);
      final url = await ref.getDownloadURL();

      return url;
    } catch (e) {
      print('Error uploading profile picture: $e');
      return null;
    }
  }

  Future<String?> uploadPostImage(String postId) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return null;

      final file = File(image.path);
      final ref = _storage.ref().child('post_images/$postId.jpg');

      await ref.putFile(file);
      final url = await ref.getDownloadURL();

      return url;
    } catch (e) {
      print('Error uploading post image: $e');
      return null;
    }
  }
}