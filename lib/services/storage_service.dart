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
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  Future<String> uploadPostImage(String uid, File file) async {
    final ext = file.path.split('.').last;
    final name = _uuid.v4();
    final ref = _storage.ref(
      '${AppConstants.postsPath}/$uid/$name.$ext',
    );
    await ref.putFile(file);
    return ref.getDownloadURL();
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
