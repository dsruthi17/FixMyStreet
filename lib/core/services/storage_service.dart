import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  // Upload media file and return download URL
  Future<String> uploadComplaintMedia(File file, {String? complaintId}) async {
    final extension = file.path.split('.').last;
    final fileName = '${_uuid.v4()}.$extension';
    final path = 'complaints/${complaintId ?? 'temp'}/$fileName';

    final ref = _storage.ref().child(path);
    final uploadTask = ref.putFile(
      file,
      SettableMetadata(
        contentType: _getContentType(extension),
      ),
    );

    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  // Upload media from XFile (works on both web and mobile)
  Future<String> uploadComplaintMediaFromXFile(XFile xfile,
      {String? complaintId}) async {
    try {
      // Use xfile.name instead of xfile.path (path is a blob URL on web)
      final fileName = xfile.name;
      print('🔍 StorageService - fileName: $fileName');

      final extension = fileName.split('.').last.toLowerCase();
      print('🔍 StorageService - extension: $extension');

      final uniqueFileName = '${_uuid.v4()}.$extension';
      final path = 'complaints/${complaintId ?? 'temp'}/$uniqueFileName';
      print('🔍 StorageService - upload path: $path');

      final ref = _storage.ref().child(path);

      // Read file as bytes (works on both web and mobile)
      print('🔍 StorageService - reading file bytes...');
      final Uint8List bytes = await xfile.readAsBytes();
      print('🔍 StorageService - file size: ${bytes.length} bytes');

      final mimeType = xfile.mimeType ?? _getContentType(extension);
      print('🔍 StorageService - MIME type: $mimeType');

      print('🔍 StorageService - starting upload...');

      // Add timeout to catch hanging uploads
      final uploadTask = ref
          .putData(
        bytes,
        SettableMetadata(
          contentType: mimeType,
        ),
      )
          .timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          print('❌ StorageService - upload timeout after 60 seconds');
          throw TimeoutException(
              'Upload timeout - check Firebase Storage CORS configuration');
        },
      );

      print('🔍 StorageService - waiting for upload completion...');
      final snapshot = await uploadTask;
      print('🔍 StorageService - getting download URL...');
      final downloadUrl = await snapshot.ref.getDownloadURL();
      print('✅ StorageService - upload successful: $downloadUrl');

      return downloadUrl;
    } catch (e, stackTrace) {
      print('❌ StorageService - upload failed: $e');
      print('   Stack trace: $stackTrace');

      if (e.toString().contains('CORS') || e.toString().contains('cors')) {
        throw Exception(
            'CORS Error: Firebase Storage not configured for web uploads. Please configure CORS in Firebase Console.');
      }

      rethrow;
    }
  }

  // Upload profile photo
  Future<String> uploadProfilePhoto(File file, String userId) async {
    final extension = file.path.split('.').last;
    final path = 'profiles/$userId/avatar.$extension';

    final ref = _storage.ref().child(path);
    final uploadTask = ref.putFile(
      file,
      SettableMetadata(contentType: 'image/$extension'),
    );

    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  // Delete file from storage
  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (_) {
      // File might already be deleted
    }
  }

  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      default:
        return 'application/octet-stream';
    }
  }
}
