import 'dart:typed_data';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CloudinaryService {
  static final CloudinaryService _instance = CloudinaryService._internal();
  factory CloudinaryService() => _instance;

  late CloudinaryPublic _cloudinary;
  bool _isConfigured = false;

  CloudinaryService._internal() {
    _initConfig();
  }

  void _initConfig() {
    final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'];
    final uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'];

    if (cloudName != null &&
        cloudName.isNotEmpty &&
        uploadPreset != null &&
        uploadPreset.isNotEmpty) {
      _cloudinary = CloudinaryPublic(cloudName, uploadPreset, cache: false);
      _isConfigured = true;
    }
  }

  Future<String?> uploadFile(
    Uint8List fileBytes,
    String fileName, {
    String folder = 'courses',
  }) async {
    // Try to reload config if not set (Hot Reload support)
    if (!_isConfigured) {
      await dotenv.load(fileName: ".env");
      _initConfig();
    }

    if (!_isConfigured) {
      print("Cloudinary credentials missing in .env");
      // Fallback relative URL for UI testing if no credentials
      // But user wants an "Alternative", so we should ideally fail or warn.
      // For now, return null to show error.
      return null;
    }

    try {
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromBytesData(
          fileBytes,
          identifier: fileName,
          folder: folder,
          resourceType: CloudinaryResourceType.Auto,
        ),
      );

      // Save to Firestore Media Library
      try {
        String type = 'other';
        final lowerName = fileName.toLowerCase();

        if (folder.contains('image') ||
            lowerName.endsWith('.jpg') ||
            lowerName.endsWith('.jpeg') ||
            lowerName.endsWith('.png') ||
            lowerName.endsWith('.gif') ||
            lowerName.endsWith('.webp') ||
            lowerName.endsWith('.svg')) {
          type = 'image';
        } else if (folder.contains('video') ||
            lowerName.endsWith('.mp4') ||
            lowerName.endsWith('.avi') ||
            lowerName.endsWith('.mov') ||
            lowerName.endsWith('.mkv') ||
            lowerName.endsWith('.webm')) {
          type = 'video';
        } else if (lowerName.endsWith('.pdf') ||
            lowerName.endsWith('.doc') ||
            lowerName.endsWith('.docx') ||
            lowerName.endsWith('.xls') ||
            lowerName.endsWith('.xlsx')) {
          type = 'pdf'; // Using 'pdf' as 'document' category for now
        }

        await FirebaseFirestore.instance.collection('media').add({
          'url': response.secureUrl,
          'publicId': response.publicId,
          'name': fileName,
          'type': type,
          'folder': folder,
          'size': fileBytes.lengthInBytes,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (dbError) {
        print("Firestore Media Save Error: $dbError");
        // Continue, don't fail the upload just because DB save failed
      }

      return response.secureUrl;
    } catch (e) {
      print("Cloudinary Upload Error: $e");
      return null;
    }
  }
}
