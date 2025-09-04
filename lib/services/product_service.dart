import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product_model.dart';
import '../utils/imports.dart';

class ProductService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  static String? get _currentUserId => _auth.currentUser?.uid;

  // Add product to user's collection
  static Future<bool> addProduct({
    required String name,
    required double price,
    required int quantity,
    required String type,
    required String category,
  }) async {
    try {
      if (_currentUserId == null) {
        debugPrint('User not authenticated');
        return false;
      }

      final productId = _generateProductId(name);
      final productRef = _firestore
          .collection('Products')
          .doc(_currentUserId)
          .collection('products')
          .doc(productId);

      // Check if product already exists
      final existingProduct = await productRef.get();

      if (existingProduct.exists) {
        // Update quantity
        final currentData = existingProduct.data() as Map<String, dynamic>;
        final currentQty = currentData['quantity'] ?? 0;
        final newQty = currentQty + quantity;

        await productRef.update({
          'quantity': newQty,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        debugPrint('Updated product quantity: $newQty');
      } else {
        // Add new product
        await productRef.set({
          'name': name,
          'price': price,
          'quantity': quantity,
          'type': type,
          'category': category,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        debugPrint('Added new product: $name');
      }

      return true;
    } catch (e) {
      debugPrint('Error adding product: $e');
      return false;
    }
  }

  // Get all products for current user
  static Future<List<ProductModel>> getAllProducts() async {
    try {
      if (_currentUserId == null) {
        debugPrint('User not authenticated');
        return [];
      }

      final querySnapshot = await _firestore
          .collection('Products')
          .doc(_currentUserId)
          .collection('products')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return ProductModel.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      debugPrint('Error getting products: $e');
      return [];
    }
  }

  // Real-time stream of products
  static Stream<List<ProductModel>> getProductsStream() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('Products')
        .doc(_currentUserId)
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ProductModel.fromMap(data, doc.id);
      }).toList();
    });
  }

  // Update product
  static Future<bool> updateProduct({
    required String productId,
    required String name,
    required double price,
    required int quantity,
    required String type,
    required String category,
  }) async {
    try {
      if (_currentUserId == null) {
        debugPrint('User not authenticated');
        return false;
      }

      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      updateData['name'] = name;
      updateData['price'] = price;
      updateData['quantity'] = quantity;
      updateData['type'] = type;
      updateData['category'] = category;

      await _firestore
          .collection('Products')
          .doc(_currentUserId)
          .collection('products')
          .doc(productId)
          .update(updateData);

      debugPrint('Product updated: $productId');
      return true;
    } catch (e) {
      debugPrint('Error updating product: $e');
      return false;
    }
  }

  // Delete product
  static Future<bool> deleteProduct(String productId) async {
    try {
      if (_currentUserId == null) {
        debugPrint('User not authenticated');
        return false;
      }

      await _firestore
          .collection('Products')
          .doc(_currentUserId)
          .collection('products')
          .doc(productId)
          .delete();

      debugPrint('Product deleted: $productId');
      return true;
    } catch (e) {
      debugPrint('Error deleting product: $e');
      return false;
    }
  }

  // Search products
  static Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final allProducts = await getAllProducts();
      
      if (query.isEmpty) return allProducts;

      return allProducts.where((product) {
        return product.name.toLowerCase().contains(query.toLowerCase()) ||
               product.category.toLowerCase().contains(query.toLowerCase()) ||
               product.type.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      debugPrint('Error searching products: $e');
      return [];
    }
  }

  // Filter products by category
  static Future<List<ProductModel>> getProductsByCategory(String category) async {
    try {
      if (_currentUserId == null) {
        debugPrint('User not authenticated');
        return [];
      }

      final querySnapshot = await _firestore
          .collection('Products')
          .doc(_currentUserId)
          .collection('products')
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return ProductModel.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      debugPrint('Error getting products by category: $e');
      return [];
    }
  }

  // Bulk upload products
  static Future<bool> bulkUploadProducts(List<Map<String, dynamic>> productsData) async {
    try {
      if (_currentUserId == null) {
        debugPrint('User not authenticated');
        return false;
      }

      final batch = _firestore.batch();

      for (var productData in productsData) {
        final productId = _generateProductId(productData['name']);
        final productRef = _firestore
            .collection('Products')
            .doc(_currentUserId)
            .collection('products')
            .doc(productId);

        batch.set(productRef, {
          'name': productData['name'],
          'price': productData['price'],
          'quantity': productData['quantity'],
          'type': productData['type'],
          'category': productData['category'] ?? 'Not Set',
          'expiry': productData['expiry'] ?? 'Not Set',
          'userId': _currentUserId,
          'productId': productId,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      debugPrint('Bulk upload completed: ${productsData.length} products');
      return true;
    } catch (e) {
      debugPrint('Error in bulk upload: $e');
      return false;
    }
  }

  // Get product categories
  static Future<List<String>> getCategories() async {
    try {
      final products = await getAllProducts();
      final categories = products
          .map((product) => product.category)
          .where((category) => category.isNotEmpty && category != 'Not Set')
          .toSet()
          .toList();
      
      categories.sort();
      return categories;
    } catch (e) {
      debugPrint('Error getting categories: $e');
      return [];
    }
  }

  // Generate product ID from name
  static String _generateProductId(String productName) {
    return productName.toLowerCase().replaceAll(' ', '_').replaceAll(RegExp(r'[^a-z0-9_]'), '');
  }
}
