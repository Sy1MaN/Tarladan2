class Product {
  final String id;
  final String sellerId;
  final String name;
  final String description;
  final double price;
  final String unit; // kg, piece, etc.
  final int stockQuantity;
  final List<String> imageUrls;
  final String category;
  final DateTime harvestDate;
  final String origin; // Location/region where the product was grown
  final bool isOrganic;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.sellerId,
    required this.name,
    required this.description,
    required this.price,
    required this.unit,
    required this.stockQuantity,
    required this.imageUrls,
    required this.category,
    required this.harvestDate,
    required this.origin,
    required this.isOrganic,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert Product to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sellerId': sellerId,
      'name': name,
      'description': description,
      'price': price,
      'unit': unit,
      'stockQuantity': stockQuantity,
      'imageUrls': imageUrls,
      'category': category,
      'harvestDate': harvestDate.toIso8601String(),
      'origin': origin,
      'isOrganic': isOrganic,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create Product from Map (database data)
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      sellerId: map['sellerId'],
      name: map['name'],
      description: map['description'],
      price: map['price'],
      unit: map['unit'],
      stockQuantity: map['stockQuantity'],
      imageUrls: List<String>.from(map['imageUrls']),
      category: map['category'],
      harvestDate: DateTime.parse(map['harvestDate']),
      origin: map['origin'],
      isOrganic: map['isOrganic'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  // Create a copy of Product with some fields updated
  Product copyWith({
    String? id,
    String? sellerId,
    String? name,
    String? description,
    double? price,
    String? unit,
    int? stockQuantity,
    List<String>? imageUrls,
    String? category,
    DateTime? harvestDate,
    String? origin,
    bool? isOrganic,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      imageUrls: imageUrls ?? this.imageUrls,
      category: category ?? this.category,
      harvestDate: harvestDate ?? this.harvestDate,
      origin: origin ?? this.origin,
      isOrganic: isOrganic ?? this.isOrganic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
