import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  final String cloudName = "dkahbm2m4";
  final String uploadPreset = "khulikitab";

  Future<String?> uploadImage(XFile file) async {
    try {
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );
      final request = http.MultipartRequest('POST', url);

      request.fields['upload_preset'] = uploadPreset;

      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes('file', bytes, filename: file.name),
        );
      } else {
        request.files.add(await http.MultipartFile.fromPath('file', file.path));
      }

      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonMap = jsonDecode(responseString);

      if (response.statusCode == 200) {
        return jsonMap['secure_url'];
      } else {
        debugPrint(
          'Cloudinary Upload Error: ${response.statusCode} - $responseString',
        );
        return null;
      }
    } catch (e) {
      debugPrint('Cloudinary Upload Exception: $e');
      return null;
    }
  }
}
