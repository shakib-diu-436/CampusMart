import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/model/order_model.dart';
import 'package:rxdart/rxdart.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createOrder({
    required String buyerId,
    required String buyerName,
    String? sellerId,
    List<String>? sellerIds,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double deliveryFee,
    required double total,
    String? customerName,
    String? phone,
    String? address,
    String? note,
    String? paymentMethod,
  }) async {
    final orderData = {
      'buyerId': buyerId,
      'buyerName': buyerName,
      if (sellerId != null && sellerId.isNotEmpty) 'sellerId': sellerId,
      if (sellerIds != null && sellerIds.isNotEmpty) 'sellerIds': sellerIds,
      'items': items,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'orderStatus': 'pending',
      'paymentStatus': 'pending',
      if (customerName != null) 'customerName': customerName,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (note != null) 'note': note,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    final docRef = await _firestore.collection('orders').add(orderData);
    return docRef.id;
  }

  Stream<List<OrderModel>> getBuyerOrders(String buyerId) {
    return _firestore
        .collection('orders')
        .where('buyerId', isEqualTo: buyerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => OrderModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<List<OrderModel>> getSellerOrders(String sellerId) {
    final storeOrders = _firestore
        .collection('orders')
        .where('sellerIds', arrayContains: sellerId)
        .snapshots();
    final studentOrders = _firestore
        .collection('orders')
        .where('sellerId', isEqualTo: sellerId)
        .snapshots();
    return Rx.combineLatest2<QuerySnapshot, QuerySnapshot, List<OrderModel>>(
      storeOrders,
      studentOrders,
      (storeSnap, studentSnap) {
        final allDocs = <QueryDocumentSnapshot>[];
        allDocs.addAll(storeSnap.docs);
        allDocs.addAll(studentSnap.docs);
        final seen = <String>{};
        final unique = allDocs.where((doc) => seen.add(doc.id)).toList();
        unique.sort((a, b) {
          final aTime = (a.data() as Map)['createdAt'] as Timestamp?;
          final bTime = (b.data() as Map)['createdAt'] as Timestamp?;
          return (bTime ?? Timestamp.now()).compareTo(aTime ?? Timestamp.now());
        });
        return unique
            .map(
              (doc) => OrderModel.fromMap(
                doc.id,
                doc.data() as Map<String, dynamic>,
              ),
            )
            .toList();
      },
    );
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore.collection('orders').doc(orderId).update({
      'orderStatus': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateSellerStatus(
    String orderId,
    String sellerId,
    String status,
  ) async {
    await _firestore.collection('orders').doc(orderId).update({
      'sellerStatuses.$sellerId': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteOrder(String orderId) async {
    await _firestore.collection('orders').doc(orderId).delete();
  }
}
