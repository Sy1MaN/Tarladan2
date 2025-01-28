class Order {
  final String id;
  final String buyerId;
  final String sellerId;
  final List<OrderItem> items;
  final double total;
  final String status;
  final DateTime createdAt;
  final String buyerName;
  final bool isDelivered;

  Order({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.buyerName,
    required this.isDelivered,
  });
}

class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });
}
