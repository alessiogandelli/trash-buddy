// lib/repositories/monnezza_repository.dart

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:trashbuddu/monnezza_bloc.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;


const String apiEndpoint = 'https://dev.api.studybuddy.it/trash';

class MonnezzaRepository {
  List<Monnezza> _cachedMonnezza = [];
  //final String baseUrl = 'https://dev.api.studybuddy.it/trash';
  final String baseUrl = 'http://10.199.229.154:1234';

    Future<File> _compressImage(File imageFile) async {
    // Read image
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    
    if (image == null) throw Exception('Failed to decode image');

    // Resize image maintaining aspect ratio
    final resized = img.copyResize(
      image,
      width: 1024, // Max width
      
    );

    // Compress to jpg
    final compressed = img.encodeJpg(resized, quality: 85);

    // Save compressed image
    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final compressedFile = File(tempPath)..writeAsBytesSync(compressed);

    return compressedFile;
  }

  Future<void> addMonnezza({
    required double latitude,
    required double longitude,
    required String address,
    required File image,
  }) async {
    // Local cache update
    final tempMonnezza = Monnezza(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      latitude: latitude,
      longitude: longitude,
      address: address,
      image: image,
      createdAt: DateTime.now(),
    );
    _cachedMonnezza.add(tempMonnezza);

    try {
      // Create multipart request
      var uri = Uri.parse('$baseUrl/reports');
      var request = http.MultipartRequest('POST', uri);
      
      // Create file stream for image upload
      var stream = http.ByteStream(image.openRead());
      var length = await image.length();
      
      // Create multipart file
      var multipartFile = http.MultipartFile(
        'image',
        stream,
        length,
        filename: image.path.split('/').last,
        contentType: MediaType('image', 'jpeg'), // Add content type
      );
      
      // Add file and other fields to request
      request.files.add(multipartFile);
      request.fields.addAll({
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'address': address,
      });

      // Send request and handle response
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        
        // Update cache with server response
        _cachedMonnezza.remove(tempMonnezza);
        final serverMonnezza = Monnezza(
          id: jsonData['_id'],
          latitude: jsonData['location']['latitude'],
          longitude: jsonData['location']['longitude'],
          address: jsonData['address'],
          image: image,
          createdAt: DateTime.parse(jsonData['timestamp']),
        );
        _cachedMonnezza.add(serverMonnezza);
      } else {
        print('Upload failed: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to upload image');
      }
    } catch (e) {
      print('Error during upload: $e');
      // Keep cached version on failure
    }
  }

  Future<List<Monnezza>> getMonnezzaList() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/reports'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        // Update cache with server data
        _cachedMonnezza = data.map((item) => Monnezza(
          id: item['_id'],
          latitude: item['location']['latitude'],
          longitude: item['location']['longitude'],
          address: item['address'] ?? '',
          // For now, create an empty file as placeholder
          // The actual image will be loaded when needed in the UI
          image: File('${item['imageUrl']}'),
          createdAt: DateTime.parse(item['timestamp']),
        )).toList();
        
        print('Fetched ${_cachedMonnezza.length} reports from server');
      } else {
        print('Server error: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Failed to fetch reports: $e');
    }
    
    return _cachedMonnezza;
  }
}