// lib/repositories/monnezza_repository.dart

import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:trashbuddu/monnezza_bloc.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;


const String apiEndpoint = 'https://dev.api.studybuddy.it/trash';

class MonnezzaRepository {
  final String baseUrl = 'https://dev.api.studybuddy.it/trash';

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
    try {
      var uri = Uri.parse('$baseUrl/reports');
      var request = http.MultipartRequest('POST', uri);
      
      var stream = http.ByteStream(image.openRead());
      var length = await image.length();
      
      var multipartFile = http.MultipartFile(
        'image',
        stream,
        length,
        filename: image.path.split('/').last,
        contentType: MediaType('image', 'jpeg'),
      );
      
      request.files.add(multipartFile);
      request.fields.addAll({
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'address': address,
      });

      print('invio al server: $latitude, $longitude, $address, ${image.path}');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('risponde il server: ${response.body}');

      final String ai_res = json.decode(response.body)['type'];

      // if aires starts with <heavy> then it's a heavy trash emit the event
      

      print('risponde il server: $ai_res');
      
      if (response.statusCode != 201) {
        throw Exception('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during upload: $e');
      throw e;
    }
  }

  Future<List<Monnezza>> getMonnezzaList() async {
   // try {
      final response = await http.get(Uri.parse('$baseUrl/reports'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Monnezza(
          id: item['_id'],
          latitude: item['location']['latitude'],
          longitude: item['location']['longitude'],
          address: item['address'] ?? '',
          image: File('${item['imageUrl']}'),
          createdAt: DateTime.parse(item['timestamp']),
        )).toList();
      } else {
        print('risponde il server: ${response.body}');
        throw Exception('Server error: ${response.statusCode}');
      }
    // } catch (e) {
    //   print('Failed to fetch reports: $e');
    //   throw e;
    // }
  }
}
