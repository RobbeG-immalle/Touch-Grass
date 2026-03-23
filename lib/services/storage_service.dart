import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:touch_grass/config/constants.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  static const _uuid = Uuid();

  Future<String> uploadAvatar(String uid, File file) async {
    final ext = file.path.split('.').last;
    final ref = _storage.ref(
      '${AppConstants.avatarsPath}/$uid.$ext',
    );
    await _upload(ref, file);
    return ref.getDownloadURL();
  }

  Future<String> uploadPostImage(String uid, File file) async {
    final ext = file.path.split('.').last;
    final name = _uuid.v4();
    final ref = _storage.ref(
      '${AppConstants.postsPath}/$uid/$name.$ext',
    );
    await _upload(ref, file);
    return ref.getDownloadURL();
  }

  Future<void> _upload(Reference ref, File file) async {
    try {
      await ref.putFile(file);
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found' || e.message?.contains('404') == true) {
        throw Exception(
          'Firebase Storage bucket not found. '
          'Go to Firebase Console → Storage → "Get started" to create the bucket, '
          'then run: firebase deploy --only storage',
        );
      }
      if (e.code == 'unauthorized' || e.code == 'permission-denied') {
        throw Exception(
          'Upload permission denied. Check your Firebase Storage security rules.',
        );
      }
      rethrow;
    }
  }

  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (_) {
      // Ignore if already deleted or URL is invalid
    }
  }
}
