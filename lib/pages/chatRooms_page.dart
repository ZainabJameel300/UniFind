import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatroomsPage extends StatefulWidget {
  @override
  _ChatroomsPageState createState() => _ChatroomsPageState();
}

class _ChatroomsPageState extends State<ChatroomsPage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _loading = false;
  String _status = '';

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (picked != null) setState(() => _image = File(picked.path));
  }

  Future<void> _testPythonConnection(File imageFile, String title) async {
    setState(() {
      _loading = true;
      _status = 'Uploading...';
    });

    try {
      // Change to 10.0.2.2 for Android emulator, or to your LAN IP for real device
      var uri = Uri.parse('http://10.0.2.2:5000/test');

      var request = http.MultipartRequest('POST', uri)
        ..fields['title'] = title
        ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      var streamedResponse = await request.send().timeout(
        Duration(seconds: 20),
      );
      var responseBody = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode == 200) {
        var data = jsonDecode(responseBody);
        setState(() {
          _status = '✅ Success: ${data['message']}';
        });
      } else {
        setState(() {
          _status = '❌ Server error: ${streamedResponse.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _status = '🔥 Connection error: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chatrooms Page')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _image == null
                ? const Placeholder(fallbackHeight: 150)
                : Image.file(_image!, height: 150),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pick Image'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _image == null
                  ? null
                  : () => _testPythonConnection(_image!, 'Lost Wallet'),
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Send to Flask'),
            ),
            const SizedBox(height: 20),
            Text(_status),
          ],
        ),
      ),
    );
  }
}
