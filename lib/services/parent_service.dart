import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../providers/language_provider.dart';

/// Service truy vấn và cập nhật dữ liệu phân hệ Phụ huynh trên Cloud Firestore.
class ParentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>?> getParentProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception(tr('Parent chưa đăng nhập', 'Parent is not logged in'));
    }
    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.data();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchParentProfile() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception(tr('Parent chưa đăng nhập', 'Parent is not logged in'));
    }
    return _firestore.collection('users').doc(user.uid).snapshots();
  }
}
