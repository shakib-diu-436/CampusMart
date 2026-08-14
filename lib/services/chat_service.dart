import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String getChatId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return ids.join('_');
  }

  // মেসেজ পাওয়া
  Stream<List<Map<String, dynamic>>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              ...data,
              'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
            };
          }).toList(),
        );
  }

  // মেসেজ পাঠানো (type যোগ করা হয়েছে)
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String senderName,
    required String text,
    String? productId,
    String? productTitle,
    String? type, // 'store' or 'student'
  }) async {
    final chatRef = _firestore.collection('chats').doc(chatId);
    await chatRef.set({
      'participants': FieldValue.arrayUnion([senderId, receiverId]),
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      if (productId != null) 'productId': productId,
      if (productTitle != null) 'productTitle': productTitle,
      if (type != null) 'type': type,
    }, SetOptions(merge: true));

    await chatRef.collection('messages').add({
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ইউজারের সব চ্যাট পাওয়া
  Stream<List<Map<String, dynamic>>> getUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'chatId': doc.id,
              ...data,
              'lastMessageTime': (data['lastMessageTime'] as Timestamp?)
                  ?.toDate(),
            };
          }).toList(),
        );
  }

  // অন্য পক্ষের ইউজার আইডি বের করা
  String getOtherUserId(Map<String, dynamic> chatData, String currentUserId) {
    final participants = List<String>.from(chatData['participants'] ?? []);
    return participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }
}
