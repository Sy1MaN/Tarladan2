import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'dart:convert';
import '../models/product.dart';

class AddProductScreen extends StatefulWidget {
  final String sellerId;

  const AddProductScreen({super.key, required this.sellerId});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  String _selectedCategory = 'Sebzeler';
  String _selectedUnit = 'kg';
  bool _isOrganic = false;
  String _origin = '';
  final List<String> _imageBase64List = [];

  final List<String> _categories = [
    'Sebzeler',
    'Meyveler',
    'Tahıllar',
    'Süt Ürünleri',
    'Et Ürünleri',
    'Diğer',
  ];

  final List<String> _units = [
    'kg',
    'g',
    'L',
    'adet',
    'demet',
    'paket',
  ];

  Future<void> _pasteImage() async {
    try {
      final ClipboardData? clipboardData =
          await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text == null ||
          !clipboardData!.text!.startsWith('data:image')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Panoda resim bulunamadı'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final String base64String = clipboardData.text!.split(',')[1];
      setState(() {
        _imageBase64List.add(base64String);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Resim başarıyla eklendi'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Resim eklenirken bir hata oluştu'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imageBase64List.removeAt(index);
    });
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (_imageBase64List.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lütfen en az bir ürün fotoğrafı ekleyin'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final product = Product(
        id: DateTime.now().toString(),
        sellerId: widget.sellerId,
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        unit: _selectedUnit,
        stockQuantity: int.parse(_stockController.text),
        imageUrls: _imageBase64List
            .map((base64) => 'data:image/png;base64,$base64')
            .toList(),
        category: _selectedCategory,
        harvestDate: DateTime.now(),
        origin: _origin,
        isOrganic: _isOrganic,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ürün başarıyla eklendi'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, product);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Ürün Ekle'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageSection(),
                const SizedBox(height: 24),
                _buildInputSection(),
                const SizedBox(height: 24),
                _buildPricingSection(),
                const SizedBox(height: 24),
                _buildAdditionalInfoSection(),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: _handleSubmit,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Ürünü Ekle',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ürün Fotoğrafları',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Bir resmi kopyalayıp buraya yapıştırabilirsiniz',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _imageBase64List.length + 1,
            itemBuilder: (context, index) {
              if (index == _imageBase64List.length) {
                return Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    onPressed: _pasteImage,
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    iconSize: 32,
                  ),
                );
              }
              return Stack(
                children: [
                  Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image:
                            MemoryImage(base64Decode(_imageBase64List[index])),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 12,
                    child: IconButton(
                      onPressed: () => _removeImage(index),
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.all(4),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ürün Bilgileri',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Ürün Adı',
            hintText: 'Örn: Taze Domates',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Lütfen ürün adını girin';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Ürün Açıklaması',
            hintText: 'Ürününüzü detaylı bir şekilde tanımlayın',
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Lütfen ürün açıklamasını girin';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: const InputDecoration(
            labelText: 'Kategori',
          ),
          items: _categories.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPricingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fiyat ve Stok',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Fiyat',
                  prefixText: '₺ ',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen fiyat girin';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedUnit,
                decoration: const InputDecoration(
                  labelText: 'Birim',
                ),
                items: _units.map((unit) {
                  return DropdownMenuItem(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedUnit = value!;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _stockController,
          decoration: const InputDecoration(
            labelText: 'Stok Miktarı',
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Lütfen stok miktarını girin';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ek Bilgiler',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Menşei',
            hintText: 'Örn: Antalya',
          ),
          onChanged: (value) => _origin = value,
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Organik Ürün'),
          subtitle: const Text('Bu ürün organik sertifikasına sahip'),
          value: _isOrganic,
          onChanged: (value) {
            setState(() {
              _isOrganic = value;
            });
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }
}
