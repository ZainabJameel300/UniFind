import 'dart:convert';
import 'package:http/http.dart' as http;

class EmbeddingService {
  /// Sends the title and image URL to the Flask backend and returns an embedding list
  static Future<List<double>> fetchEmbeddingFromServer({
    required String title,
    required String imageUrl,
  }) async {
    try {
      // For Android emulator use 10.0.2.2, for physical device use your local IP address
      final uri = Uri.parse('http://10.0.2.2:5000/generate_embedding');

      var request = http.MultipartRequest('POST', uri)
        ..fields['title'] = title
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
