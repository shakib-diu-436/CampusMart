import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getUserData(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data() ?? {};
  }

  Future<String> getUserName(String userId) async {
    final data = await getUserData(userId);
    return data['name']?.toString() ?? 'Student';
  }

  Future<bool> hasStore(String userId) async {
    final data = await getUserData(userId);
    final storeId = data['storeId']?.toString();
    return storeId != null && storeId.isNotEmpty;
  }

  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

  Future<String> getCurrentUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'Student';
    final data = await getUserData(user.uid);
    return data['name']?.toString() ?? user.displayName ?? 'Student';
  }
}
