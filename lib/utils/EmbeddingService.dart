import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class EmbeddingService {
  /// Sends the descreption and image URL to the Flask backend and returns an embedding list
  static Future<List<double>> fetchEmbeddingFromServer({
    required String description,
    required String imageUrl,
  }) async {
    try {
      // Decide the server URL based on the platform
      final String baseUrl = Platform.isAndroid
          ? 'http://10.0.2.2:5001' // Android Emulator
          : 'http://192.168.1.3:5001'; // IOS Emulator

      final uri = Uri.parse('$baseUrl/generate_embedding');

      var request = http.MultipartRequest('POST', uri)
        ..fields['description'] = description
        ..fields['image_url'] = imageUrl.isNotEmpty ? imageUrl : "";

      var streamed = await request.send();
      var body = await streamed.stream.bytesToString();

      if (streamed.statusCode == 200) {
        final data = jsonDecode(body);
        final List raw = data['embedding'];
        return raw.map((e) => (e as num).toDouble()).toList();
      } else {
        throw Exception("Embedding API returned ${streamed.statusCode}: $body");
      }
    } catch (e) {
      throw Exception("Embedding fetch failed: $e"); // ✅ show real error
    }
  }
}
