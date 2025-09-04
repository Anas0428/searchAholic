import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/sale_model.dart';
import '../utils/imports.dart';

class SalesService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  static String? get _currentUserId => _auth.currentUser?.uid;

  // Add sale record
  static Future<bool> addSale({
    required String customerPhone,
    required double saleAmount,
    required Map<String, int> saleProducts,
    String? notes,
  }) async {
    try {
      if (_currentUserId == null) {
        debugPrint('User not authenticated');
        return false;
      }

      final saleId = _generateSaleId();
      await _firestore
          .collection('Sales')
          .doc(_currentUserId)
          .collection('sales')
          .doc(saleId)
          .set({
        'saleId': saleId,
        'customerPhone': customerPhone,
        'saleAmount': saleAmount,
        'saleProducts': saleProducts,
        'notes': notes ?? '',
        'saleDate': FieldValue.serverTimestamp(),
        'userId': _currentUserId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('Sale added successfully: $saleId');
      return true;
    } catch (e) {
      debugPrint('Error adding sale: $e');
      return false;
    }
  }

  // Get all sales for current user
  static Future<List<SaleModel>> getAllSales() async {
    try {
      if (_currentUserId == null) {
        debugPrint('User not authenticated');
        return [];
      }

      final querySnapshot = await _firestore
          .collection('Sales')
          .doc(_currentUserId)
          .collection('sales')
          .orderBy('saleDate', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return SaleModel.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      debugPrint('Error getting sales: $e');
      return [];
    }
  }

  // Real-time stream of sales
  static Stream<List<SaleModel>> getSalesStream() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('Sales')
        .doc(_currentUserId)
        .collection('sales')
        .orderBy('saleDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return SaleModel.fromMap(data, doc.id);
      }).toList();
    });
  }

  // Get sales by date range
  static Future<List<SaleModel>> getSalesByDateRange(
      DateTime startDate, DateTime endDate) async {
    try {
      if (_currentUserId == null) {
        debugPrint('User not authenticated');
        return [];
      }

      final querySnapshot = await _firestore
          .collection('Sales')
          .doc(_currentUserId)
          .collection('sales')
          .where('saleDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('saleDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('saleDate', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return SaleModel.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      debugPrint('Error getting sales by date range: $e');
      return [];
    }
  }

  // Get sales analytics
  static Future<Map<String, dynamic>> getSalesAnalytics() async {
    try {
      final sales = await getAllSales();
      
      if (sales.isEmpty) {
        return {
          'totalSales': 0.0,
          'totalOrders': 0,
          'averageOrderValue': 0.0,
          'todaysSales': 0.0,
          'thisWeekSales': 0.0,
          'thisMonthSales': 0.0,
          'dailySales': <String, double>{},
          'topProducts': <String, int>{},
        };
      }

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final weekStart = today.subtract(Duration(days: now.weekday - 1));
      final monthStart = DateTime(now.year, now.month, 1);

      double totalSales = 0.0;
      double todaysSales = 0.0;
      double thisWeekSales = 0.0;
      double thisMonthSales = 0.0;
      Map<String, double> dailySales = {};
      Map<String, int> productCounts = {};

      for (var sale in sales) {
        totalSales += sale.saleAmount;
        
        final saleDate = sale.saleDate;
        if (saleDate != null) {
          final saleDateOnly = DateTime(saleDate.year, saleDate.month, saleDate.day);
          
          // Today's sales
          if (saleDateOnly.isAtSameMomentAs(today)) {
            todaysSales += sale.saleAmount;
          }
          
          // This week's sales
          if (saleDate.isAfter(weekStart)) {
            thisWeekSales += sale.saleAmount;
          }
          
          // This month's sales
          if (saleDate.isAfter(monthStart)) {
            thisMonthSales += sale.saleAmount;
          }
          
          // Daily sales for chart
          final dateKey = '${saleDate.day}/${saleDate.month}';
          dailySales[dateKey] = (dailySales[dateKey] ?? 0.0) + sale.saleAmount;
          
          // Product counts
          sale.saleProducts.forEach((product, quantity) {
            productCounts[product] = (productCounts[product] ?? 0) + quantity;
          });
        }
      }

      // Get top 5 products
      final topProducts = Map.fromEntries(
        productCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value))
          ..take(5)
      );

      return {
        'totalSales': totalSales,
        'totalOrders': sales.length,
        'averageOrderValue': sales.isNotEmpty ? totalSales / sales.length : 0.0,
        'todaysSales': todaysSales,
        'thisWeekSales': thisWeekSales,
        'thisMonthSales': thisMonthSales,
        'dailySales': dailySales,
        'topProducts': topProducts,
      };
    } catch (e) {
      debugPrint('Error getting sales analytics: $e');
      return {};
    }
  }

  // Delete sale
  static Future<bool> deleteSale(String saleId) async {
    try {
      if (_currentUserId == null) {
        debugPrint('User not authenticated');
        return false;
      }

      await _firestore
          .collection('Sales')
          .doc(_currentUserId)
          .collection('sales')
          .doc(saleId)
          .delete();

      debugPrint('Sale deleted: $saleId');
      return true;
    } catch (e) {
      debugPrint('Error deleting sale: $e');
      return false;
    }
  }

  // Generate unique sale ID
  static String _generateSaleId() {
    final now = DateTime.now();
    return 'SALE_${now.millisecondsSinceEpoch}';
  }
}
