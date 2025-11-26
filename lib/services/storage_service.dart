import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  CloudinaryPublic? _cloudinary;

  CloudinaryPublic get cloudinary {
    if (_cloudinary == null) {
      final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'];
      final uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'];

      if (cloudName == null || uploadPreset == null) {
        throw Exception('Cloudinary credentials not found in .env file');
      }

      _cloudinary = CloudinaryPublic(cloudName, uploadPreset, cache: false);
    }
    return _cloudinary!;
  }

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

      print('Uploading to Cloudinary: ${pickedFile.path}');

      // Upload to Cloudinary
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          pickedFile.path,
          resourceType: CloudinaryResourceType.Image,
          folder: 'profile_pictures',
          publicId: userId,
        ),
      );

      print('Cloudinary upload successful: ${response.secureUrl}');
      print('Public ID: ${response.publicId}');

      return response.secureUrl;

    } on CloudinaryException catch (e) {
      print('Cloudinary error: ${e.message}');
      print('Error details: ${e.toString()}');
      throw Exception('Error uploading profile picture: ${e.message}');
    } catch (e) {
      print('Upload error: ${e.toString()}');
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

      print('Uploading report image to Cloudinary: $path');

      final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(path)}';

      // Upload to Cloudinary
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          path,
          resourceType: CloudinaryResourceType.Image,
          folder: 'report_images',
          publicId: fileName,
        ),
      );

      print('Cloudinary report upload successful: ${response.secureUrl}');
      print('Public ID: ${response.publicId}');

      return response.secureUrl;

    } on CloudinaryException catch (e) {
      print('Cloudinary error: ${e.message}');
      print('Error details: ${e.toString()}');
      throw Exception('Error uploading report image: ${e.message}');
    } catch (e) {
      print('Upload error: ${e.toString()}');
      throw Exception(e.toString());
    }
  }
}
