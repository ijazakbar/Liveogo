import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/theme.dart';
import '../application/seller_inventory_providers.dart';
import '../data/seller_product.dart';

class SellerInventoryScreen extends ConsumerStatefulWidget {
  const SellerInventoryScreen({super.key});

  @override
  ConsumerState<SellerInventoryScreen> createState() =>
      _SellerInventoryScreenState();
}

class _SellerInventoryScreenState
    extends ConsumerState<SellerInventoryScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(sellerProductsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Inventory',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context),
        icon: const Icon(Icons.add),
        label: const Text('Add product'),
      ),
      body: products.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _InventoryError(
          message: _errorMessage(error),
          onRetry: () => ref.invalidate(sellerProductsProvider),
        ),
        data: (items) {
          final query = _search.trim().toLowerCase();
          final filtered = items.where((product) {
            if (query.isEmpty) return true;
            return product.title.toLowerCase().contains(query) ||
                (product.sku?.toLowerCase().contains(query) ?? false) ||
                (product.category?.toLowerCase().contains(query) ?? false);
          }).toList(growable: false);

          return RefreshIndicator(
            onRefresh: () => ref.refresh(sellerProductsProvider.future),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              children: [
                TextField(
                  onChanged: (value) => setState(() => _search = value),
                  decoration: const InputDecoration(
                    hintText: 'Search products, SKU or category',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      '${items.length} products',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const Spacer(),
                    Text(
                      '${items.where((item) => item.stock <= 5).length} low stock',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: items.any((item) => item.stock <= 5)
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (filtered.isEmpty)
                  _InventoryEmpty(hasProducts: items.isNotEmpty)
                else
                  ...filtered.map(
                    (product) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ProductTile(
                        product: product,
                        onEdit: () => _openEditor(context, product: product),
                        onDelete: () => _confirmDelete(context, product),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openEditor(
    BuildContext context, {
    SellerProduct? product,
  }) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (_) => _ProductEditorSheet(
        product: product,
        onSubmit: (draft, image) async {
          final repository = ref.read(sellerProductRepositoryProvider);
          if (product == null) {
            await repository.createProduct(draft, image: image);
          } else {
            await repository.updateProduct(product.id, draft, image: image);
          }
          ref.invalidate(sellerProductsProvider);
        },
      ),
    );

    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(product == null ? 'Product created' : 'Product updated'),
        ),
      );
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    SellerProduct product,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove product?'),
        content: Text(
          'Remove "${product.title}" from your active catalogue? '
          'Past order records should remain available.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    try {
      await ref.read(sellerProductRepositoryProvider).deleteProduct(product.id);
      ref.invalidate(sellerProductsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product removed from catalogue')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage(error))),
        );
      }
    }
  }

  String _errorMessage(Object error) {
    if (error is DioException) {
      final status = error.response?.statusCode;
      if (status != null) {
        return 'The server rejected the request (HTTP $status).';
      }
      return 'Could not reach the LiveOgo API. Check your connection and API_BASE_URL.';
    }
    if (error is FormatException) return error.message.toString();
    return 'Something went wrong. Please try again.';
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  final SellerProduct product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final lowStock = product.stock <= 5;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 68,
                height: 68,
                child: product.imageUrl == null
                    ? const ColoredBox(
                        color: Color(0xFFF0EFF5),
                        child: Icon(
                          Icons.inventory_2_outlined,
                          color: AppTheme.purple,
                        ),
                      )
                    : Image.network(
                        product.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const ColoredBox(
                          color: Color(0xFFF0EFF5),
                          child: Icon(Icons.broken_image_outlined),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text('PKR ${product.salePrice ?? product.price}'),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    children: [
                      Text(
                        'Stock: ${product.stock}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: lowStock
                                  ? Theme.of(context).colorScheme.error
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      if (!product.isActive)
                        Text(
                          'Inactive',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Product actions',
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Remove')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InventoryEmpty extends StatelessWidget {
  const _InventoryEmpty({required this.hasProducts});
  final bool hasProducts;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
        child: Column(
          children: [
            Icon(
              hasProducts ? Icons.search_off : Icons.inventory_2_outlined,
              size: 54,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 14),
            Text(
              hasProducts ? 'No matching products' : 'Your inventory is empty',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              hasProducts
                  ? 'Try a different product name, SKU or category.'
                  : 'Add a product to start managing your catalogue.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
}

class _InventoryError extends StatelessWidget {
  const _InventoryError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 48),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
}

class _ProductEditorSheet extends StatefulWidget {
  const _ProductEditorSheet({required this.onSubmit, this.product});

  final SellerProduct? product;
  final Future<void> Function(SellerProductDraft draft, XFile? image) onSubmit;

  @override
  State<_ProductEditorSheet> createState() => _ProductEditorSheetState();
}

class _ProductEditorSheetState extends State<_ProductEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _salePriceController;
  late final TextEditingController _stockController;
  late final TextEditingController _categoryController;
  late final TextEditingController _skuController;
  final _picker = ImagePicker();

  XFile? _image;
  bool _isActive = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _titleController = TextEditingController(text: product?.title ?? '');
    _descriptionController =
        TextEditingController(text: product?.description ?? '');
    _priceController = TextEditingController(text: product?.price.toString() ?? '');
    _salePriceController =
        TextEditingController(text: product?.salePrice?.toString() ?? '');
    _stockController =
        TextEditingController(text: product?.stock.toString() ?? '0');
    _categoryController =
        TextEditingController(text: product?.category ?? '');
    _skuController = TextEditingController(text: product?.sku ?? '');
    _isActive = product?.isActive ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _salePriceController.dispose();
    _stockController.dispose();
    _categoryController.dispose();
    _skuController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        imageQuality: 85,
      );
      if (image != null && mounted) setState(() => _image = image);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not open the image picker on this device.');
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final price = num.parse(_priceController.text.trim());
    final saleText = _salePriceController.text.trim();
    final salePrice = saleText.isEmpty ? null : num.parse(saleText);
    final stock = int.parse(_stockController.text.trim());

    setState(() {
      _saving = true;
      _error = null;
    });

    final draft = SellerProductDraft(
      title: _titleController.text.trim(),
      description: _nullable(_descriptionController.text),
      price: price,
      salePrice: salePrice,
      stock: stock,
      category: _nullable(_categoryController.text),
      sku: _nullable(_skuController.text),
      isActive: _isActive,
    );

    try {
      await widget.onSubmit(draft, _image);
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Product could not be saved. Check the API connection and try again.';
        });
      }
    }
  }

  String? _nullable(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String? _validateNumber(String? value, {required bool integer}) {
    final text = value?.trim() ?? '';
    final parsed = integer ? int.tryParse(text) : num.tryParse(text);
    if (parsed == null) return 'Enter a valid number';
    if (parsed < 0 || (!integer && parsed == 0)) {
      return integer
          ? 'Stock cannot be negative'
          : 'Price must be greater than zero';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.product == null ? 'Add product' : 'Edit product',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    IconButton(
                      onPressed: _saving ? null : () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      tooltip: 'Close',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _saving ? null : _pickImage,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    height: 132,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: _image != null
                        ? FutureBuilder<Uint8List>(
                            future: _image!.readAsBytes(),
                            builder: (context, snapshot) => snapshot.hasData
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image.memory(
                                      snapshot.data!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  )
                                : const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                          )
                        : widget.product?.imageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.network(
                                  widget.product!.imageUrl!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.add_photo_alternate_outlined,
                                    size: 36,
                                  ),
                                ),
                              )
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate_outlined, size: 36),
                                  SizedBox(height: 7),
                                  Text('Choose product image'),
                                ],
                              ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Product title *'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Product title is required'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Price (PKR) *'),
                        validator: (value) =>
                            _validateNumber(value, integer: false),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _salePriceController,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Sale price'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return null;
                          final error = _validateNumber(value, integer: false);
                          if (error != null) return error;
                          final basePrice = num.tryParse(_priceController.text.trim());
                          if (basePrice == null) return 'Enter base price first';
                          if (num.parse(value) >= basePrice) {
                            return 'Must be below price';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _stockController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Stock quantity *'),
                        validator: (value) =>
                            _validateNumber(value, integer: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _skuController,
                        decoration: const InputDecoration(labelText: 'SKU'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _isActive,
                  onChanged: _saving
                      ? null
                      : (value) => setState(() => _isActive = value),
                  title: const Text('Active in catalogue'),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            widget.product == null
                                ? 'Create product'
                                : 'Save changes',
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
}
