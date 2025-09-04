import 'package:flutter/material.dart';
import 'package:shopwise/services/product_service.dart';
import 'package:shopwise/widgets/product_card.dart';
import 'package:shopwise/models/product_model.dart';

/// Real-time product list that automatically syncs across multiple apps
class RealtimeProductList extends StatefulWidget {
  final String? searchQuery;
  final Function(String)? onProductTap;

  const RealtimeProductList({
    super.key,
    this.searchQuery,
    this.onProductTap,
  });

  @override
  State<RealtimeProductList> createState() => _RealtimeProductListState();
}

class _RealtimeProductListState extends State<RealtimeProductList> {
  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeProducts();
  }

  void _initializeProducts() {
    // Listen to real-time updates
    ProductService.getProductsStream().listen(
      (products) {
        if (mounted) {
          setState(() {
            _allProducts = products;
            _filterProducts();
            _isLoading = false;
            _error = null;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _error = error.toString();
            _isLoading = false;
          });
        }
      },
    );
  }

  void _filterProducts() {
    if (widget.searchQuery == null || widget.searchQuery!.isEmpty) {
      _filteredProducts = List.from(_allProducts);
    } else {
      _filteredProducts = _allProducts.where((product) {
        final name = product.name.toLowerCase();
        final type = product.type.toLowerCase();
        final category = product.category.toLowerCase();
        final searchTerm = widget.searchQuery!.toLowerCase();
        return name.contains(searchTerm) || 
               type.contains(searchTerm) ||
               category.contains(searchTerm);
      }).toList();
    }
  }

  @override
  void didUpdateWidget(RealtimeProductList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _filterProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading products',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.red[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _initializeProducts();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredProducts.isEmpty) {
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
              widget.searchQuery != null && widget.searchQuery!.isNotEmpty
                  ? 'No products found for "${widget.searchQuery}"'
                  : 'No products found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.searchQuery != null && widget.searchQuery!.isNotEmpty
                  ? 'Try a different search term'
                  : 'Add your first product to get started',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];

        // Convert to the format expected by ProductCard
        final productMap = {
          'Name': product.name,
          'Price': product.price,
          'Quantity': product.quantity,
          'Type': product.type,
          'Category': product.category,
          'id': product.id,
        };

        return ProductCard(
          product: productMap,
        );
      },
    );
  }
}

/// Real-time product counter widget
class RealtimeProductCounter extends StatefulWidget {
  const RealtimeProductCounter({super.key});

  @override
  State<RealtimeProductCounter> createState() => _RealtimeProductCounterState();
}

class _RealtimeProductCounterState extends State<RealtimeProductCounter> {
  int _productCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeCounter();
  }

  void _initializeCounter() {
    ProductService.getProductsStream().listen(
      (products) {
        if (mounted) {
          setState(() {
            _productCount = products.length;
            _isLoading = false;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$_productCount',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
