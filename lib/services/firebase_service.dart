import '../utils/imports.dart';

/// Legacy Firebase service - DEPRECATED
/// Use ProductService instead for new Firebase SDK integration
@Deprecated('Use ProductService instead for new Firebase SDK integration')
class FirebaseService {
  static FirebaseService? _instance;
  static FirebaseService get instance => _instance ??= FirebaseService._();

  FirebaseService._();

  /// Initialize Firebase services - DEPRECATED
  @Deprecated('Use ProductService.initialize() instead')
  Future<void> initialize() async {
    debugPrint("FirebaseService is deprecated. Use ProductService instead.");
  }

  /// All methods now throw deprecation warnings
  @Deprecated('Use ProductService.getCurrentUserId() instead')
  Future<String> getCurrentUserId() async {
    throw Exception(
        "FirebaseService is deprecated. Use ProductService instead.");
  }

  @Deprecated('Use ProductService.addProduct() instead')
  Future<bool> addProduct({
    required String name,
    required double price,
    required int quantity,
    required String type,
    String category = "Not Set",
    String expiry = "Not Set",
  }) async {
    throw Exception(
        "FirebaseService is deprecated. Use ProductService instead.");
  }

  @Deprecated('Use ProductService.getAllProducts() instead')
  Future<List<Map<String, dynamic>>> getAllProducts() async {
    throw Exception(
        "FirebaseService is deprecated. Use ProductService instead.");
  }

  @Deprecated('Use ProductService.getProductsStream() instead')
  Stream<List<Map<String, dynamic>>> getProductsStream() async* {
    throw Exception(
        "FirebaseService is deprecated. Use ProductService instead.");
  }

  @Deprecated('Use ProductService.updateProduct() instead')
  Future<bool> updateProduct({
    required String productId,
    String? name,
    double? price,
    int? quantity,
    String? type,
    String? category,
    String? expiry,
  }) async {
    throw Exception(
        "FirebaseService is deprecated. Use ProductService instead.");
  }

  @Deprecated('Use ProductService.deleteProduct() instead')
  Future<bool> deleteProduct(String productId) async {
    throw Exception(
        "FirebaseService is deprecated. Use ProductService instead.");
  }

  @Deprecated('Use ProductService.bulkUploadProducts() instead')
  Future<bool> bulkUploadProducts(
      List<Map<String, dynamic>> productsData) async {
    throw Exception(
        "FirebaseService is deprecated. Use ProductService instead.");
  }

  @Deprecated('Use ProductService.getUserProfile() instead')
  Future<Map<String, dynamic>?> getUserProfile() async {
    throw Exception(
        "FirebaseService is deprecated. Use ProductService instead.");
  }

  @Deprecated('Use ProductService.updateUserProfile() instead')
  Future<bool> updateUserProfile(Map<String, dynamic> profileData) async {
    throw Exception(
        "FirebaseService is deprecated. Use ProductService instead.");
  }
}
