import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  late GenerativeModel _model;
  String? _apiKey;

  GeminiService() : _apiKey = dotenv.env['GEMINI_API_KEY'] {
    if (_apiKey != null && _apiKey!.isNotEmpty) {
      _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey!);
    }
  }

  Future<Map<String, dynamic>> generateCourseOutline(String topic) async {
    // Attempt to reload .env if key is missing (Hot Reload support)
    if (_apiKey == null || _apiKey!.isEmpty) {
      try {
        await dotenv.load(fileName: ".env");
        _apiKey = dotenv.env['GEMINI_API_KEY'];
        if (_apiKey != null && _apiKey!.isNotEmpty) {
          _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey!);
        }
      } catch (e) {
        print("Failed to reload .env: $e");
      }
    }

    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception(
        'GEMINI_API_KEY is missing in .env. Please ADD it and RESTART the app.',
      );
    }

    final prompt =
        '''
You are an expert course creator. Create a detailed and professional course outline on the topic: "$topic".
Return ONLY a valid JSON object (no markdown formatting, no comments) with the following structure:
{
  "title": "Engaging Course Title",
  "subtitle": "Compelling subtitle",
  "duration": "e.g. 5h 30m",
  "level": "Beginner | Intermediate | Advanced",
  "description": "A comprehensive description of what students will learn.",
  "price": 5000,
  "discountPrice": 3000,
  "curriculum": [
    {
      "title": "Lesson 1 Title"
    },
    {
      "title": "Lesson 2 Title"
    }
  ]
}
Ensure the price is a number. "curriculum" should be a list of objects with "title".
''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      String? responseText = response.text;
      if (responseText == null) throw Exception('No response from AI');

      // Clean up potential markdown code blocks
      responseText = responseText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      return jsonDecode(responseText);
    } catch (e) {
      print("Gemini Error: $e");
      rethrow;
    }
  }
}
