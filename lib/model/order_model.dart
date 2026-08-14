import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderModel {
  final String id;
  final String buyerId;
  final String buyerName;
  final String? sellerId;
  final List<String>? sellerIds;
  final List<Map<String, dynamic>> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String orderStatus;
  final String paymentStatus;
  final String? customerName;
  final String? phone;
  final String? address;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.id,
    required this.buyerId,
    required this.buyerName,
    this.sellerId,
    this.sellerIds,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.orderStatus,
    required this.paymentStatus,
    this.customerName,
    this.phone,
    this.address,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromMap(String id, Map<String, dynamic> map) {
    return OrderModel(
      id: id,
      buyerId: map['buyerId'] ?? map['userId'] ?? '',
      buyerName: map['buyerName'] ?? map['customerName'] ?? '',
      sellerId: map['sellerId']?.toString(),
      sellerIds: map['sellerIds'] != null
          ? List<String>.from(map['sellerIds'])
          : null,
      items: List<Map<String, dynamic>>.from(map['items'] ?? []),
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      deliveryFee: (map['deliveryFee'] ?? 0).toDouble(),
      total: (map['total'] ?? 0).toDouble(),
      orderStatus: map['orderStatus'] ?? 'pending',
      paymentStatus: map['paymentStatus'] ?? 'pending',
      customerName: map['customerName']?.toString(),
      phone: map['phone']?.toString(),
      address: map['address']?.toString(),
      note: map['note']?.toString(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'buyerId': buyerId,
      'buyerName': buyerName,
      if (sellerId != null) 'sellerId': sellerId,
      if (sellerIds != null) 'sellerIds': sellerIds,
      'items': items,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'orderStatus': orderStatus,
      'paymentStatus': paymentStatus,
      if (customerName != null) 'customerName': customerName,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (note != null) 'note': note,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  bool get isStoreOrder => sellerIds != null && sellerIds!.isNotEmpty;
  bool get isStudentOrder => sellerId != null && sellerId!.isNotEmpty;
  bool get isBuyer {
    final user = FirebaseAuth.instance.currentUser;
    return user != null && user.uid == buyerId;
  }

  bool get isSeller {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    if (sellerId == user.uid) return true;
    if (sellerIds != null && sellerIds!.contains(user.uid)) return true;
    return false;
  }
}
