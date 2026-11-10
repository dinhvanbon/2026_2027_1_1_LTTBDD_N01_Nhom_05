import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadTaskProofImage({
    required String taskId,
    required String childId,
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    final ref = _storage
        .ref()
        .child('task_proofs')
        .child(childId)
        .child('$taskId-$fileName');

    final result = await ref.putData(imageBytes);

    return result.ref.getDownloadURL();
  }
}
