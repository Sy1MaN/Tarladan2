import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/order.dart';

class BuyerHome extends StatefulWidget {
  final String buyerId;
  final List<Product>? products;

  const BuyerHome({
    super.key,
    required this.buyerId,
    this.products,
  });

  @override
  State<BuyerHome> createState() => _BuyerHomeState();
}

class _BuyerHomeState extends State<BuyerHome> {
  int _selectedIndex = 0;
  final _searchController = TextEditingController();
  late List<Product> _products;
  final List<CartItem> _cartItems = [];
  final List<Product> _favoriteProducts = [];
  String _selectedCategory = 'Tümü';
  final List<Order> _orders = []; // Add orders list

  double get _cartTotal => _cartItems.fold(
        0,
        (total, item) => total + (item.price * item.quantity),
      );

  final List<String> _categories = [
    'Tümü',
    'Sebzeler',
    'Meyveler',
    'Tahıllar',
    'Süt Ürünleri',
    'Et Ürünleri',
    'Diğer',
  ];

  @override
  void initState() {
    super.initState();
    _products = widget.products ?? [];
  }

  List<Product> get _filteredProducts {
    if (_selectedCategory == 'Tümü') {
      return _products;
    }
    return _products
        .where((product) => product.category == _selectedCategory)
        .toList();
  }

  Widget _buildProductImage(String imageUrl) {
    if (imageUrl.startsWith('data:image')) {
      final base64String = imageUrl.split(',')[1];
      return Image.memory(
        base64Decode(base64String),
        height: 120,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }
    return Image.network(
      imageUrl,
      height: 120,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }

  void _addToCart(Product product) {
    setState(() {
      final existingItemIndex = _cartItems.indexWhere(
        (item) => item.productId == product.id,
      );

      if (existingItemIndex != -1) {
        // Update existing item
        final existingItem = _cartItems[existingItemIndex];
        _cartItems[existingItemIndex] = existingItem.copyWith(
          quantity: existingItem.quantity + 1,
        );
      } else {
        // Add new item
        _cartItems.add(
          CartItem(
            id: DateTime.now().toString(),
            productId: product.id,
            buyerId: widget.buyerId,
            productName: product.name,
            price: product.price,
            unit: product.unit,
            quantity: 1,
            addedAt: DateTime.now(),
          ),
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} sepete eklendi'),
        action: SnackBarAction(
          label: 'Sepete Git',
          onPressed: () {
            setState(() {
              _selectedIndex = 1; // Switch to cart tab
            });
          },
        ),
      ),
    );
  }

  void _toggleFavorite(Product product) {
    setState(() {
      if (_favoriteProducts.contains(product)) {
        _favoriteProducts.remove(product);
      } else {
        _favoriteProducts.add(product);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _favoriteProducts.contains(product)
              ? '${product.name} favorilere eklendi'
              : '${product.name} favorilerden çıkarıldı',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _updateCartItemQuantity(CartItem item, int newQuantity) {
    setState(() {
      final index = _cartItems.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        if (newQuantity > 0) {
          _cartItems[index] = item.copyWith(quantity: newQuantity);
        } else {
          _cartItems.removeAt(index);
        }
      }
    });
  }

  void _removeFromCart(CartItem item) {
    setState(() {
      _cartItems.removeWhere((i) => i.id == item.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.productName} sepetten çıkarıldı'),
        action: SnackBarAction(
          label: 'Geri Al',
          onPressed: () {
            setState(() {
              _cartItems.add(item);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Ana Sayfa',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: 'Sepetim',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite_rounded),
            label: 'Favoriler',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildCartTab();
      case 2:
        return _buildFavoritesTab();
      case 3:
        return _buildProfileTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          title: const Text(
            'Atamdan',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tarım ürünlerinde ara...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCategorySection(),
                const SizedBox(height: 24),
                _buildFeaturedProducts(),
                const SizedBox(height: 24),
                _buildPopularProducts(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    final categories = [
      {'icon': Icons.grass, 'label': 'Tohumlar'},
      {'icon': Icons.eco, 'label': 'Bitkiler'},
      {'icon': Icons.water_drop, 'label': 'Gübreler'},
      {'icon': Icons.agriculture, 'label': 'Aletler'},
      {'icon': Icons.local_florist, 'label': 'Çiçekler'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kategoriler',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        category['icon'] as IconData,
                        color: Theme.of(context).colorScheme.primary,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category['label'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Öne Çıkan Ürünler',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Tümünü Gör'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _products.length,
            itemBuilder: (context, index) {
              final product = _products[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: _buildProductImage(
                            product.imageUrls.isNotEmpty
                                ? product.imageUrls.first
                                : 'https://placeholder.com/150',
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () => _toggleFavorite(product),
                                icon: Icon(
                                  _favoriteProducts.contains(product)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: _favoriteProducts.contains(product)
                                      ? Colors.red
                                      : Colors.white,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.black26,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.origin,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${product.price.toStringAsFixed(2)} ₺',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              IconButton(
                                onPressed: () => _addToCart(product),
                                icon: const Icon(Icons.add_shopping_cart),
                                iconSize: 20,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPopularProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Popüler Ürünler',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Tümünü Gör'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _products.length,
          itemBuilder: (context, index) {
            final product = _products[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: product.imageUrls.isNotEmpty
                        ? _buildProductImage(product.imageUrls.first)
                        : const Icon(
                            Icons.image,
                            size: 40,
                            color: Colors.grey,
                          ),
                  ),
                ),
                title: Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.origin,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${product.price.toStringAsFixed(2)} ₺',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _addToCart(product),
                      icon: const Icon(Icons.add_shopping_cart),
                      iconSize: 20,
                    ),
                    IconButton(
                      onPressed: () => _toggleFavorite(product),
                      icon: Icon(
                        _favoriteProducts.contains(product)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: _favoriteProducts.contains(product)
                            ? Colors.red
                            : null,
                      ),
                      iconSize: 20,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCartTab() {
    if (_cartItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Sepetiniz boş',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ürün eklemek için alışverişe başlayın',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                setState(() {
                  _selectedIndex = 0; // Switch to home tab
                });
              },
              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text('Alışverişe Başla'),
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          title: Text('Sepetim'),
          floating: true,
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == _cartItems.length) {
                  // Summary card at the bottom
                  return Card(
                    margin: const EdgeInsets.only(top: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sipariş Özeti',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Toplam'),
                              Text(
                                '${_cartTotal.toStringAsFixed(2)} ₺',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () {
                                _proceedToCheckout();
                              },
                              child: const Text('Ödemeye Geç'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final item = _cartItems[index];
                final product = _products.firstWhere(
                  (p) => p.id == item.productId,
                  orElse: () => Product(
                    id: '',
                    sellerId: '',
                    name: item.productName,
                    description: '',
                    price: item.price,
                    unit: item.unit,
                    stockQuantity: 0,
                    imageUrls: [],
                    category: '',
                    harvestDate: DateTime.now(),
                    origin: '',
                    isOrganic: false,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
                );

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        // Product Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 80,
                            height: 80,
                            child: product.imageUrls.isNotEmpty
                                ? _buildProductImage(product.imageUrls.first)
                                : const Icon(
                                    Icons.image,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Product Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item.price.toStringAsFixed(2)} ₺ / ${item.unit}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      _updateCartItemQuantity(
                                        item,
                                        item.quantity - 1,
                                      );
                                    },
                                    icon: const Icon(Icons.remove),
                                    iconSize: 20,
                                  ),
                                  Text(
                                    item.quantity.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      _updateCartItemQuantity(
                                        item,
                                        item.quantity + 1,
                                      );
                                    },
                                    icon: const Icon(Icons.add),
                                    iconSize: 20,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Price and Remove
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${(item.price * item.quantity).toStringAsFixed(2)} ₺',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () => _removeFromCart(item),
                              icon: const Icon(Icons.delete_outline),
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: _cartItems.length + 1,
            ),
          ),
        ),
      ],
    );
  }

  void _proceedToCheckout() {
    // Show a confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ödeme Ekranına Geç'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sipariş özeti:'),
            const SizedBox(height: 8),
            Text('${_cartItems.length} ürün'),
            Text('Toplam: ${_cartTotal.toStringAsFixed(2)} ₺'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to payment screen
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => PaymentScreen(
              //       cartItems: _cartItems,
              //       total: _cartTotal,
              //     ),
              //   ),
              // );
            },
            child: const Text('Ödemeye Geç'),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesTab() {
    if (_favoriteProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Henüz favori ürününüz bulunmuyor',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          title: Text('Favorilerim'),
          floating: true,
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final product = _favoriteProducts[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                                child: product.imageUrls.isNotEmpty
                                    ? _buildProductImage(
                                        product.imageUrls.first)
                                    : const Icon(
                                        Icons.image,
                                        size: 64,
                                        color: Colors.grey,
                                      ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () => _addToCart(product),
                                    icon: const Icon(Icons.add_shopping_cart),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      padding: const EdgeInsets.all(8),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () => _toggleFavorite(product),
                                    icon: const Icon(
                                      Icons.favorite,
                                      color: Colors.red,
                                    ),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      padding: const EdgeInsets.all(8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                product.origin,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${product.price.toStringAsFixed(2)} ₺',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              childCount: _favoriteProducts.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileTab() {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          title: Text('Profilim'),
          floating: true,
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Profile Header
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: const Icon(
                        Icons.person,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'John Doe',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'john.doe@example.com',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.edit),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Settings Sections
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hesap Ayarları',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsCard([
                      _buildSettingsTile(
                        icon: Icons.person_outline,
                        title: 'Kişisel Bilgiler',
                      ),
                      _buildSettingsTile(
                        icon: Icons.location_on_outlined,
                        title: 'Teslimat Adresleri',
                      ),
                      _buildSettingsTile(
                        icon: Icons.payment_outlined,
                        title: 'Ödeme Yöntemleri',
                      ),
                    ]),
                    const SizedBox(height: 24),
                    const Text(
                      'Tercihler',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsCard([
                      _buildSettingsTile(
                        icon: Icons.notifications_outlined,
                        title: 'Bildirimler',
                      ),
                      _buildSettingsTile(
                        icon: Icons.language_outlined,
                        title: 'Dil',
                      ),
                      _buildSettingsTile(
                        icon: Icons.dark_mode_outlined,
                        title: 'Karanlık Mod',
                        trailing: Switch(
                          value: false,
                          onChanged: (value) {},
                        ),
                      ),
                    ]),
                    const SizedBox(height: 24),
                    const Text(
                      'Destek',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsCard([
                      _buildSettingsTile(
                        icon: Icons.help_outline,
                        title: 'Yardım Merkezi',
                      ),
                      _buildSettingsTile(
                        icon: Icons.policy_outlined,
                        title: 'Gizlilik Politikası',
                      ),
                      _buildSettingsTile(
                        icon: Icons.description_outlined,
                        title: 'Kullanım Koşulları',
                      ),
                    ]),
                    const SizedBox(height: 24),
                    _buildSettingsCard([
                      _buildSettingsTile(
                        icon: Icons.logout,
                        title: 'Çıkış Yap',
                        iconColor: Colors.red,
                        textColor: Colors.red,
                      ),
                    ]),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    Color? iconColor,
    Color? textColor,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? Colors.grey[600],
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {},
    );
  }
}
