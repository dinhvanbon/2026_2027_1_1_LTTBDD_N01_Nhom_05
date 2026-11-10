import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String generateLinkCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final code = List.generate(
      6,
      (_) => chars[random.nextInt(chars.length)],
    ).join();

    return 'KQ$code';
  }

  Future<void> createUserProfile({
    required String username,
    required String phone,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User chưa đăng nhập');
    }

    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'username': username,
      'phone': phone,
      'role': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> saveUserRoleIfNotExists(String role) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User chưa đăng nhập');
    }

    final userRef = _firestore.collection('users').doc(user.uid);
    final userDoc = await userRef.get();

    if (userDoc.exists && userDoc.data()?['role'] != null) {
      return;
    }

    await userRef.set({
      'role': role,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final data = (await userRef.get()).data();

    if (role == 'parent') {
      await _firestore.collection('parents').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'username': data?['username'] ?? '',
        'phone': data?['phone'] ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    if (role == 'child') {
      await _firestore.collection('children').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'username': data?['username'] ?? '',
        'phone': data?['phone'] ?? '',
        'level': 1,
        'exp': 0,
        'coins': 0,
        'parentId': '',
        'linkCode': generateLinkCode(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<String?> getCurrentUserRole() async {
    final user = _auth.currentUser;

    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (!doc.exists) return null;

    return doc.data()?['role'] as String?;
  }

  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final user = _auth.currentUser;

    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (!doc.exists) return null;

    return doc.data();
  }

  Future<void> ensureChildDocumentExists() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User chưa đăng nhập');
    }

    final userDoc = await _firestore.collection('users').doc(user.uid).get();

    final userData = userDoc.data();

    if (userData == null || userData['role'] != 'child') {
      return;
    }

    final childRef = _firestore.collection('children').doc(user.uid);

    final childDoc = await childRef.get();

    if (childDoc.exists) {
      return;
    }

    await childRef.set({
      'uid': user.uid,
      'email': user.email,
      'username': userData['username'] ?? '',
      'phone': userData['phone'] ?? '',
      'level': 1,
      'exp': 0,
      'coins': 0,
      'parentId': '',
      'linkCode': generateLinkCode(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> linkChildToParent(String childId) async {
    final parent = _auth.currentUser;

    if (parent == null) {
      throw Exception('Parent chưa đăng nhập');
    }

    final childRef = _firestore.collection('children').doc(childId);

    final childDoc = await childRef.get();

    if (!childDoc.exists) {
      throw Exception('Không tìm thấy Child');
    }

    await childRef.update({
      'parentId': parent.uid,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> linkChildByCode(String code) async {
    final parent = _auth.currentUser;

    if (parent == null) {
      throw Exception('Parent chưa đăng nhập');
    }

    final normalizedCode = code.trim().toUpperCase();

    if (normalizedCode.isEmpty) {
      throw Exception('Vui lòng nhập mã liên kết');
    }

    final snapshot = await _firestore
        .collection('children')
        .where('linkCode', isEqualTo: normalizedCode)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      throw Exception('Không tìm thấy Child');
    }

    final childDoc = snapshot.docs.first;

    final parentId = (childDoc.data()['parentId'] ?? '').toString();

    if (parentId.isNotEmpty) {
      throw Exception('Child đã được liên kết');
    }

    await childDoc.reference.update({
      'parentId': parent.uid,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _firestore
        .collection('parents')
        .doc(parent.uid)
        .collection('children')
        .doc(childDoc.id)
        .set({
          'childId': childDoc.id,
          'linkedAt': FieldValue.serverTimestamp(),
        });
  }

  Future<void> unlinkChild(String childId) async {
    final parent = _auth.currentUser;

    if (parent == null) {
      throw Exception('Parent chưa đăng nhập');
    }

    final childRef = _firestore.collection('children').doc(childId);
    final childDoc = await childRef.get();

    if (!childDoc.exists) {
      throw Exception('Không tìm thấy Child');
    }

    final currentParentId = (childDoc.data()?['parentId'] ?? '').toString();

    if (currentParentId != parent.uid) {
      throw Exception('Bạn không có quyền hủy liên kết Child này');
    }

    await childRef.update({
      'parentId': '',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _firestore
        .collection('parents')
        .doc(parent.uid)
        .collection('children')
        .doc(childId)
        .delete();
  }

  Stream<List<Map<String, dynamic>>> getLinkedChildrenStream() {
    final parent = _auth.currentUser;

    if (parent == null) {
      throw Exception('Parent chưa đăng nhập');
    }

    return _firestore
        .collection('children')
        .where('parentId', isEqualTo: parent.uid)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return {'uid': doc.id, ...data};
          }).toList();
        });
  }

  Future<void> updateCurrentUserProfile({
    required String username,
    required String phone,
    String? avatar,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User chưa đăng nhập');
    }

    final userRef = _firestore.collection('users').doc(user.uid);

    await userRef.set({
      'username': username,
      'phone': phone,
      'avatar': avatar,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final userDoc = await userRef.get();
    final role = userDoc.data()?['role'];

    if (role == 'parent') {
      await _firestore.collection('parents').doc(user.uid).set({
        'username': username,
        'phone': phone,
        'avatar': avatar,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    if (role == 'child') {
      await _firestore.collection('children').doc(user.uid).set({
        'username': username,
        'phone': phone,
        'avatar': avatar,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<Map<String, dynamic>?> getCurrentParentProfile() async {
    final user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    final userDoc = await _firestore.collection('users').doc(user.uid).get();

    if (!userDoc.exists) {
      return {
        'uid': user.uid,
        'email': user.email ?? '',
        'username': 'Parent',
        'phone': '',
        'role': 'parent',
      };
    }

    return userDoc.data();
  }

  Future<Map<String, dynamic>?> getCurrentChildProfile() async {
    final user = _auth.currentUser;

    if (user == null) return null;

    final childDoc = await _firestore
        .collection('children')
        .doc(user.uid)
        .get();

    if (childDoc.exists) {
      return childDoc.data();
    }

    final userDoc = await _firestore.collection('users').doc(user.uid).get();

    return userDoc.data();
  }
}
