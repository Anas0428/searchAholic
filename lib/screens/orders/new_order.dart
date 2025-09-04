// ignore_for_file: camel_case_types, library_private_types_in_public_api, non_constant_identifier_names, avoid_function_literals_in_foreach_calls, depend_on_referenced_packages, unused_local_variable

import 'package:flutter/services.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shopwise/widgets/order_card.dart';
import 'package:shopwise/widgets/sidebar.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../utils/imports.dart';
import '../../services/product_service.dart';
import '../../services/sales_service.dart';
import '../../services/auth_service.dart';
import '../../models/product_model.dart';

class newOrder extends StatefulWidget {
  const newOrder({super.key});
  @override
  _newOrderState createState() => _newOrderState();
}

class _newOrderState extends State<newOrder> {
  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];
  final List<Map<String, dynamic>> _selectedProducts = [];
  
  double totalBill = 0.0;
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  
  final quantityController = TextEditingController();
  final _phoneController = TextEditingController();
  final _searchController = TextEditingController();
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  
  String? storeName;
  String? email;
  String? phoneNumber;
  String? address;
  String? date;

  Future<void> _loadUserProfile() async {
    try {
      final user = AuthService.currentUser;
      if (user != null) {
        setState(() {
          email = user.email;
          // You can expand this to load more profile data from Firestore if needed
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  void _updateDateTime() {
    final now = DateTime.now();
    final formatter = DateFormat.yMMMMd().add_jm();
    setState(() {
      date = formatter.format(now);
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _loadUserProfile();
    _updateDateTime();
    _loadProducts();
  }

  void _loadProducts() {
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
    if (_searchQuery.isEmpty) {
      _filteredProducts = List.from(_allProducts);
    } else {
      _filteredProducts = _allProducts.where((product) {
        final name = product.name.toLowerCase();
        final type = product.type.toLowerCase();
        final category = product.category.toLowerCase();
        final searchTerm = _searchQuery.toLowerCase();
        return name.contains(searchTerm) || 
               type.contains(searchTerm) ||
               category.contains(searchTerm);
      }).toList();
    }
  }

  void _removeFromBasket(int index) {
    setState(() {
      final item = _selectedProducts[index];
      final itemTotal = double.parse(item['price'].toString()) * 
                       double.parse(item['quantity'].toString());
      totalBill -= itemTotal;
      _selectedProducts.removeAt(index);
    });
  }

  void _addToBasket(ProductModel product, int quantity) {
    setState(() {
      // Check if product already exists in basket
      final existingIndex = _selectedProducts.indexWhere(
        (item) => item['id'] == product.id,
      );

      if (existingIndex >= 0) {
        // Update existing item
        final existingQty = int.parse(_selectedProducts[existingIndex]['quantity'].toString());
        _selectedProducts[existingIndex]['quantity'] = existingQty + quantity;
      } else {
        // Add new item
        _selectedProducts.add({
          'id': product.id,
          'name': product.name,
          'price': product.price,
          'quantity': quantity,
          'type': product.type,
          'category': product.category,
        });
      }

      totalBill += product.price * quantity;
    });
  }

  Widget _buildProductsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text('Error loading products', 
                 style: TextStyle(fontSize: 18, color: Colors.red[700])),
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(fontSize: 14, color: Colors.red[600])),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _loadProducts();
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
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No products found for "$_searchQuery"'
                  : 'No products found',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try a different search term'
                  : 'Add your first product to get started',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Card(
            elevation: 2,
            color: Colors.blue[300],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListTile(
              title: Text(
                product.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              subtitle: Text(
                "Rs. ${product.price.toStringAsFixed(2)}",
                style: const TextStyle(color: Colors.white),
              ),
              trailing: Text(
                "Qty: ${product.quantity}",
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () => _showQuantityDialog(product),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showQuantityDialog(ProductModel product) async {
    quantityController.clear();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add ${product.name}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Available: ${product.quantity}"),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Quantity",
                border: OutlineInputBorder(),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              final qty = int.tryParse(quantityController.text) ?? 0;
              if (qty > 0 && qty <= product.quantity) {
                _addToBasket(product, qty);
                Navigator.pop(context);
              } else {
                QuickAlert.show(
                  context: context,
                  type: QuickAlertType.error,
                  title: 'Invalid Quantity',
                  text: 'Please enter a valid quantity (1-${product.quantity})',
                );
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  Future<void> _showInvoiceDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Order Summary"),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            children: [
              Text("Date: $date"),
              Text("Customer: ${_phoneController.text}"),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: _selectedProducts.length,
                  itemBuilder: (context, index) {
                    final item = _selectedProducts[index];
                    final price = double.parse(item['price'].toString());
                    final qty = int.parse(item['quantity'].toString());
                    return ListTile(
                      title: Text(item['name'].toString()),
                      subtitle: Text("Rs. ${price.toStringAsFixed(2)} x $qty"),
                      trailing: Text("Rs. ${(price * qty).toStringAsFixed(2)}"),
                    );
                  },
                ),
              ),
              const Divider(),
              ListTile(
                title: const Text("Total", style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: Text("Rs. ${totalBill.toStringAsFixed(2)}", 
                              style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _processOrder();
            },
            child: const Text("Confirm Order"),
          ),
        ],
      ),
    );
  }

  Future<void> _processOrder() async {
    if (!mounted) return;
    
    try {
      // Show loading
      QuickAlert.show(
        context: context,
        type: QuickAlertType.loading,
        title: 'Processing Order',
        text: 'Please wait...',
      );

      // Prepare sale data
      Map<String, int> saleProducts = {};
      for (var item in _selectedProducts) {
        saleProducts[item['name'].toString()] = int.parse(item['quantity'].toString());
      }

      // Record sale
      final saleSuccess = await SalesService.addSale(
        customerPhone: _phoneController.text,
        saleAmount: totalBill,
        saleProducts: saleProducts,
        notes: 'Order placed via New Order screen',
      );

      // Update product quantities
      bool updateSuccess = true;
      for (var item in _selectedProducts) {
        final productId = item['id'].toString();
        final quantity = int.parse(item['quantity'].toString());
        
        // Find the product and update its quantity
        final product = _allProducts.firstWhere((p) => p.id == productId);
        
        final success = await ProductService.updateProduct(
          productId: product.id,
          name: product.name,
          price: product.price,
          quantity: product.quantity - quantity,
          type: product.type,
          category: product.category,
        );
        if (!success) {
          updateSuccess = false;
          break;
        }
      }

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (saleSuccess && updateSuccess) {
        // Generate invoice message
        String invoiceMsg = _generateInvoiceMessage();
        
        // Share invoice
        await Share.share(invoiceMsg);

        if (!mounted) return;
        // Show success and reset
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Order Completed',
          text: 'Order has been processed successfully!',
          onConfirmBtnTap: () {
            if (mounted) {
              Navigator.pop(context);
              _resetOrder();
            }
          },
        );
      } else {
        if (!mounted) return;
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Order Failed',
          text: 'Failed to process order. Please try again.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        text: 'An error occurred: $e',
      );
    }
  }

  String _generateInvoiceMessage() {
    String msg = "SALES INVOICE\n";
    msg += "Date: $date\n";
    msg += "Customer: ${_phoneController.text}\n";
    msg += "=" * 30 + "\n";
    
    for (var item in _selectedProducts) {
      final name = item['name'].toString();
      final price = double.parse(item['price'].toString());
      final qty = int.parse(item['quantity'].toString());
      msg += "$name - Rs. ${price.toStringAsFixed(2)} x $qty = Rs. ${(price * qty).toStringAsFixed(2)}\n";
    }
    
    msg += "=" * 30 + "\n";
    msg += "TOTAL: Rs. ${totalBill.toStringAsFixed(2)}\n";
    msg += "Thank you for your business!";
    
    return msg;
  }

  void _resetOrder() {
    setState(() {
      _selectedProducts.clear();
      totalBill = 0.0;
      _phoneController.clear();
      _searchController.clear();
      _searchQuery = '';
      _filterProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: Column(
              children: [
                // Header
                const Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                      "New Order",
                      style: TextStyle(
                        fontFamily: "NTR",
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 30,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 9,
                  child: Row(
                    children: [
                      // Left Side - Basket
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            // Basket Header
                            Expanded(
                              flex: 1,
                              child: Container(
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(20),
                                    bottomRight: Radius.circular(20),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Expanded(
                                      flex: 3,
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 20),
                                        child: Text(
                                          "Basket",
                                          style: TextStyle(
                                            fontFamily: "NTR",
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 30,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 120,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        onPressed: () {
                                          if (_selectedProducts.isNotEmpty) {
                                            QuickAlert.show(
                                              context: context,
                                              type: QuickAlertType.confirm,
                                              title: "Clear Basket",
                                              text: "Are you sure you want to clear the basket?",
                                              onConfirmBtnTap: () {
                                                Navigator.pop(context);
                                                setState(() {
                                                  _selectedProducts.clear();
                                                  totalBill = 0.0;
                                                });
                                              },
                                            );
                                          }
                                        },
                                        child: const Text(
                                          "Clear Basket",
                                          style: TextStyle(
                                            fontFamily: "NTR",
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Basket Items
                            Expanded(
                              flex: 8,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                                    color: Colors.grey[200],
                                  ),
                                  child: _selectedProducts.isEmpty
                                      ? const Center(
                                          child: Text(
                                            'No items in basket',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey,
                                              fontFamily: 'NTR',
                                            ),
                                          ),
                                        )
                                      : ListView.builder(
                                          itemCount: _selectedProducts.length,
                                          itemBuilder: (context, index) {
                                            final item = _selectedProducts[index];
                                            return GestureDetector(
                                              onTap: () => _removeFromBasket(index),
                                              child: OrderCard(
                                                productName: item['name'].toString(),
                                                productPrice: double.parse(item['price'].toString()),
                                                productQty: double.parse(item['quantity'].toString()),
                                                productID: item['id'].toString(),
                                              ),
                                            );
                                          },
                                        ),
                                ),
                              ),
                            ),
                            // Total
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                        ),
                                      ),
                                      height: MediaQuery.of(context).size.height,
                                      child: const Center(
                                        child: Text(
                                          "TOTAL",
                                          style: TextStyle(
                                            fontFamily: "NTR",
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 25,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(20),
                                        ),
                                      ),
                                      height: MediaQuery.of(context).size.height,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Padding(
                                          padding: const EdgeInsets.only(right: 20),
                                          child: Text(
                                            "Rs. ${totalBill.toStringAsFixed(2)}",
                                            style: const TextStyle(
                                              fontFamily: "NTR",
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 25,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Right Side - Products
                      Expanded(
                        child: Column(
                          children: [
                            // Search Bar
                            Expanded(
                              flex: 10,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 30,
                                  right: 30,
                                  top: 20,
                                ),
                                child: TextFormField(
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    hintText: "Search Product",
                                    hintStyle: const TextStyle(
                                      fontFamily: "NTR",
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 20,
                                    ),
                                    prefixIcon: const Icon(Icons.search),
                                    suffixIcon: _searchQuery.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(Icons.clear),
                                            onPressed: () {
                                              _searchController.clear();
                                              setState(() {
                                                _searchQuery = '';
                                                _filterProducts();
                                              });
                                            },
                                          )
                                        : null,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _searchQuery = value;
                                      _filterProducts();
                                    });
                                  },
                                ),
                              ),
                            ),
                            // Products List
                            Flexible(
                              flex: 55,
                              fit: FlexFit.tight,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 35,
                                  right: 30,
                                  bottom: 20,
                                ),
                                child: _buildProductsList(),
                              ),
                            ),
                            // Checkout Section
                            Expanded(
                              flex: 10,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 30),
                                child: Row(
                                  children: [
                                    // Phone Input
                                    Flexible(
                                      child: Form(
                                        key: formkey,
                                        child: TextFormField(
                                          maxLines: 1,
                                          controller: _phoneController,
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Phone number required';
                                            }
                                            RegExp regExp = RegExp(
                                              r"^[0-9]{10,11}$",
                                              caseSensitive: false,
                                              multiLine: false,
                                            );
                                            if (!regExp.hasMatch(value)) {
                                              return 'Please enter a valid phone number';
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                            hintText: "Phone Number",
                                            hintStyle: const TextStyle(
                                              fontFamily: "NTR",
                                              color: Colors.black,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 15,
                                            ),
                                            prefixIcon: const Padding(
                                              padding: EdgeInsets.only(left: 15, right: 10),
                                              child: Icon(Icons.phone),
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            contentPadding: const EdgeInsets.only(),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    // Checkout Button
                                    SizedBox(
                                      height: 43,
                                      width: 100,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          if (_selectedProducts.isEmpty) {
                                            QuickAlert.show(
                                              context: context,
                                              type: QuickAlertType.warning,
                                              title: 'Empty Basket',
                                              text: 'Please add products to the basket before checkout.',
                                            );
                                            return;
                                          }
                                          
                                          if (formkey.currentState!.validate()) {
                                            _updateDateTime();
                                            QuickAlert.show(
                                              context: context,
                                              type: QuickAlertType.warning,
                                              title: 'Prescription Confirmation',
                                              text: 'Have you checked the prescription?',
                                              onConfirmBtnTap: () {
                                                Navigator.pop(context);
                                                _showInvoiceDialog();
                                              },
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                        ),
                                        child: const Text("Checkout"),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
