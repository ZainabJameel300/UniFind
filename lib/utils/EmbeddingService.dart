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
        ..fields['image_url'] = imageUrl;

      var streamed = await request.send().timeout(const Duration(seconds: 30));
      var body = await streamed.stream.bytesToString();

      if (streamed.statusCode == 200) {
        final data = jsonDecode(body);

        // Convert embedding list to List<double>
        final List<dynamic> raw = data['embedding'] as List<dynamic>;
        return raw.map((e) => (e as num).toDouble()).toList();
      } else {
        final err = body.isNotEmpty ? body : 'Status ${streamed.statusCode}';
        throw Exception('Embedding API error: $err');
      }
    } catch (e) {
      print('Error fetching embedding: $e');
      rethrow;
    }
  }
}
