import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class EmbeddingService {
  /// Sends the description and image URL to the Flask backend and returns
  /// text, image, and combined embeddings.
  static Future<Map<String, List<double>>> fetchEmbeddingFromServer({
    required String description,
    required String imageUrl,
  }) async {
    try {
      final String baseUrl = Platform.isAndroid
          ? 'http://10.0.2.2:5001'
          : 'http://192.168.1.3:5001';

      final uri = Uri.parse('$baseUrl/generate_embedding');

      var request = http.MultipartRequest('POST', uri)
        ..fields['description'] = description
        ..fields['image_url'] = imageUrl.isNotEmpty ? imageUrl : "";

      var streamed = await request.send();
      var body = await streamed.stream.bytesToString();

      if (streamed.statusCode == 200) {
        final data = jsonDecode(body);

        return {
          "textEmbedding": (data['text_embedding'] as List)
              .map((e) => (e as num).toDouble())
              .toList(),
          "imageEmbedding":
              (data['image_embedding'] as List?)
                  ?.map((e) => (e as num).toDouble())
                  .toList() ??
              [],
          "combinedEmbedding": (data['combined_embedding'] as List)
              .map((e) => (e as num).toDouble())
              .toList(),
        };
      } else {
        throw Exception("Embedding API returned ${streamed.statusCode}: $body");
      }
    } catch (e) {
      throw Exception("Embedding fetch failed: $e");
    }
  }
}
