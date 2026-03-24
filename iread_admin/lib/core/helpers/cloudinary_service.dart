import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../constants/cloudinary_config.dart';

class CloudinaryService {
  static Future<String?> uploadFile({
    required File file,
    required String resourceType, // 'image' or 'video' (for audio)
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(CloudinaryConfig.uploadUrl));
      
      request.fields['upload_preset'] = CloudinaryConfig.uploadPreset;
      
      final fileStream = http.ByteStream(file.openRead());
      final length = await file.length();
      
      final multipartFile = http.MultipartFile(
        'file',
        fileStream,
        length,
        filename: file.path.split('/').last,
        contentType: resourceType == 'image' 
            ? MediaType('image', 'jpeg') 
            : MediaType('audio', 'mpeg'),
      );
      
      request.files.add(multipartFile);
      
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(responseBody);
        return jsonResponse['secure_url'];
      } else {
        print('Cloudinary Upload Error: ${response.statusCode} - $responseBody');
        return null;
      }
    } catch (e) {
      print('Cloudinary Service Error: $e');
      return null;
    }
  }

  static Future<String?> uploadBytes({
    required List<int> bytes,
    required String filename,
    required String resourceType,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(CloudinaryConfig.uploadUrl));
      
      request.fields['upload_preset'] = CloudinaryConfig.uploadPreset;
      
      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename,
        contentType: resourceType == 'image' 
            ? MediaType('image', 'jpeg') 
            : MediaType('audio', 'mpeg'),
      );
      
      request.files.add(multipartFile);
      
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(responseBody);
        return jsonResponse['secure_url'];
      } else {
        print('Cloudinary Upload Error: ${response.statusCode} - $responseBody');
        return null;
      }
    } catch (e) {
      print('Cloudinary Service Error: $e');
      return null;
    }
  }
}
