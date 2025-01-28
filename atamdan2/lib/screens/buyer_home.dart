import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/order.dart';

class BuyerHome extends StatefulWidget {
  final String buyerId;

  const BuyerHome({super.key, required this.buyerId});

  @override
  State<BuyerHome> createState() => _BuyerHomeState();
}

class _BuyerHomeState extends State<BuyerHome> {
  int _selectedIndex = 0;
  final _searchController = TextEditingController();
  late List<Product> _products;
  final List<CartItem> _cartItems = [];
  final List<Product> _favoriteProducts = []; // Favorite products
  String _selectedCategory = 'Tümü';
  final List<Order> _orders = []; // Add orders list

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
    // Initialize with dummy products
    _products = [
      Product(
        id: '1',
        sellerId: 'seller1',
        name: 'Taze Domates',
        description: 'Yerel yetiştirilmiş organik domatesler',
        price: 12.99,
        unit: 'kg',
        stockQuantity: 100,
        imageUrls: ['https://example.com/tomatoes.jpg'],
        category: 'Sebzeler',
        harvestDate: DateTime.now().subtract(const Duration(days: 1)),
        origin: 'Antalya',
        isOrganic: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '2',
        sellerId: 'seller1',
        name: 'Kırmızı Elma',
        description: 'Tatlı ve sulu elmalar',
        price: 8.99,
        unit: 'kg',
        stockQuantity: 150,
        imageUrls: ['https://example.com/apples.jpg'],
        category: 'Meyveler',
        harvestDate: DateTime.now().subtract(const Duration(days: 2)),
        origin: 'Isparta',
        isOrganic: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '3',
        sellerId: 'seller2',
        name: 'Taze Süt',
        description: 'Çiftlikten taze tam yağlı süt',
        price: 15.99,
        unit: 'L',
        stockQuantity: 50,
        imageUrls: ['https://example.com/milk.jpg'],
        category: 'Süt Ürünleri',
        harvestDate: DateTime.now(),
        origin: 'Bursa',
        isOrganic: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '4',
        sellerId: 'seller2',
        name: 'Organic Eggs',
        description: 'Free-range organic eggs',
        price: 24.99,
        unit: 'dozen',
        stockQuantity: 80,
        imageUrls: ['https://example.com/eggs.jpg'],
        category: 'Süt Ürünleri',
        harvestDate: DateTime.now(),
        origin: 'Izmir',
        isOrganic: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '5',
        sellerId: 'seller3',
        name: 'White Rice',
        description: 'Premium quality white rice',
        price: 45.99,
        unit: 'kg',
        stockQuantity: 200,
        imageUrls: ['https://example.com/rice.jpg'],
        category: 'Tahıllar',
        harvestDate: DateTime.now().subtract(const Duration(days: 30)),
        origin: 'Edirne',
        isOrganic: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  List<Product> get _filteredProducts {
    if (_selectedCategory == 'Tümü') {
      return _products;
    }
    return _products
        .where((product) => product.category == _selectedCategory)
        .toList();
  }

  void _addToCart(Product product) {
    setState(() {
      // Check if product already exists in cart
      final existingItem = _cartItems.firstWhere(
        (item) => item.productId == product.id,
        orElse: () => CartItem(
          id: DateTime.now()
              .toString(), // In real app, use proper ID generation
          productId: product.id,
          buyerId: widget.buyerId,
          productName: product.name,
          price: product.price,
          unit: product.unit,
          quantity: 0,
          addedAt: DateTime.now(),
        ),
      );

      if (existingItem.quantity == 0) {
        // New item
        _cartItems.add(existingItem.copyWith(quantity: 1));
      } else {
        // Update existing item
        final index =
            _cartItems.indexWhere((item) => item.productId == product.id);
        _cartItems[index] =
            existingItem.copyWith(quantity: existingItem.quantity + 1);
      }
    });

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart'),
        duration: const Duration(seconds: 2),
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
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag_rounded),
            label: 'Siparişler',
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
        return _buildOrdersTab();
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
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(
                        product.imageUrls.isNotEmpty
                            ? product.imageUrls.first
                            : 'https://placeholder.com/150',
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
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
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.origin,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
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
                  child: Image.network(
                    product.imageUrls.isNotEmpty
                        ? product.imageUrls.first
                        : 'https://placeholder.com/80',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
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
                trailing: IconButton(
                  onPressed: () => _toggleFavorite(product),
                  icon: Icon(
                    _favoriteProducts.contains(product)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color:
                        _favoriteProducts.contains(product) ? Colors.red : null,
                  ),
                  iconSize: 20,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildOrdersTab() {
    if (_orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Henüz siparişiniz bulunmuyor',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Siparişleriniz burada görüntülenecek',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          AppBar(
            title: const Text('Siparişlerim'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Aktif'),
                Tab(text: 'Geçmiş'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildActiveOrders(),
                _buildPastOrders(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveOrders() {
    final activeOrders = _orders.where((order) => !order.isDelivered).toList();

    if (activeOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aktif siparişiniz bulunmuyor',
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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sipariş #${1000 + index}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'İşlemde',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  '3 ürün • Toplam: 299,97 ₺',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Tahmini teslimat: 2-3 gün',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPastOrders() {
    final pastOrders = _orders.where((order) => order.isDelivered).toList();

    if (pastOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Geçmiş siparişiniz bulunmuyor',
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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sipariş #${1000 - index}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Teslim Edildi',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  '2 ürün • Toplam: 199,98 ₺',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Teslim tarihi: ${15 - index} Mayıs 2024',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            child: Image.network(
                              'https://placeholder.com/150',
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
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
                              'Satıcı Adı',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
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
