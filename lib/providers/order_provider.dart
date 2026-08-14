import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/order_model.dart';

import '../services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();
  List<OrderModel> _buyerOrders = [];
  List<OrderModel> _sellerOrders = [];
  bool _isLoading = false;

  List<OrderModel> get buyerOrders => _buyerOrders;
  List<OrderModel> get sellerOrders => _sellerOrders;
  bool get isLoading => _isLoading;

  void loadBuyerOrders(String buyerId) {
    _isLoading = true;
    notifyListeners();
    _orderService.getBuyerOrders(buyerId).listen((orders) {
      _buyerOrders = orders;
      _isLoading = false;
      notifyListeners();
    });
  }

  void loadSellerOrders(String sellerId) {
    _isLoading = true;
    notifyListeners();
    _orderService.getSellerOrders(sellerId).listen((orders) {
      _sellerOrders = orders;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<String> placeOrder({
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
    return await _orderService.createOrder(
      buyerId: buyerId,
      buyerName: buyerName,
      sellerId: sellerId,
      sellerIds: sellerIds,
      items: items,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      total: total,
      customerName: customerName,
      phone: phone,
      address: address,
      note: note,
      paymentMethod: paymentMethod,
    );
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _orderService.updateOrderStatus(orderId, status);
  }

  Future<void> updateSellerStatus(
    String orderId,
    String sellerId,
    String status,
  ) async {
    await _orderService.updateSellerStatus(orderId, sellerId, status);
  }

  Future<void> deleteOrder(String orderId) async {
    await _orderService.deleteOrder(orderId);
  }
}
