class CartItem {
  final String id;
  final String productId;
  final String buyerId;
  final String productName;
  final double price;
  final String unit;
  final int quantity;
  final DateTime addedAt;

  CartItem({
    required this.id,
    required this.productId,
    required this.buyerId,
    required this.productName,
    required this.price,
    required this.unit,
    required this.quantity,
    required this.addedAt,
  });

  // Calculate total price for this cart item
  double get totalPrice => price * quantity;

  // Convert CartItem to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'buyerId': buyerId,
      'productName': productName,
      'price': price,
      'unit': unit,
      'quantity': quantity,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  // Create CartItem from Map (database data)
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'],
      productId: map['productId'],
      buyerId: map['buyerId'],
      productName: map['productName'],
      price: map['price'],
      unit: map['unit'],
      quantity: map['quantity'],
      addedAt: DateTime.parse(map['addedAt']),
    );
  }

  // Create a copy of CartItem with some fields updated
  CartItem copyWith({
    String? id,
    String? productId,
    String? buyerId,
    String? productName,
    double? price,
    String? unit,
    int? quantity,
    DateTime? addedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      buyerId: buyerId ?? this.buyerId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
