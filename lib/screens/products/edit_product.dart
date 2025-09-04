// Edit Product Page

// Path: lib\screens\products\edit_product.dart
import 'package:flutter/services.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shopwise/widgets/sidebar.dart';
import 'package:shopwise/services/product_service.dart';
import '../../utils/imports.dart';

// ignore: must_be_immutable
class EditProduct extends StatefulWidget {
  String productID = "";
  String email = "";
  // Get the Product ID in the Constructor
  EditProduct({super.key, required this.productID, required this.email});

  @override
  State<EditProduct> createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  // Get the Product ID
  String productID = "";
  String email = "";
  GlobalKey<FormState> formkey = GlobalKey<FormState>();

  // Controllers for the TextFields
  final TextEditingController _productName = TextEditingController();
  final TextEditingController _productPrice = TextEditingController();
  final TextEditingController _productQty = TextEditingController();
  String? _selectedProductForm;
  String? _selectedProductPurpose;

  @override
  // Update State
  void initState() {
    super.initState();
    productID = widget.productID;
    email = widget.email;
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    try {
      final products = await ProductService.getAllProducts();
      final product = products.firstWhere(
        (p) => p.id == productID,
        orElse: () => throw Exception('Product not found'),
      );
      
      setState(() {
        _productName.text = product.name;
        _productPrice.text = product.price.toString();
        _productQty.text = product.quantity.toString();
        _selectedProductForm = product.type;
        _selectedProductPurpose = product.category != 'Not Set' ? product.category : null;
      });
    } catch (e) {
      debugPrint('Error loading product: $e');
    }
  }

  Future<bool> _updateProduct() async {
    try {
      // Validate required fields
      if (_productName.text.isEmpty ||
          _productPrice.text.isEmpty ||
          _productQty.text.isEmpty ||
          _selectedProductForm == null) {
        debugPrint('Validation failed: Missing required fields');
        return false;
      }

      debugPrint('Attempting to update medicine: ${_productName.text}');

      final success = await ProductService.updateProduct(
        productId: productID,
        name: _productName.text,
        price: double.parse(_productPrice.text),
        quantity: int.parse(_productQty.text),
        type: _selectedProductForm!,
        category: _selectedProductPurpose ?? "Not Set",
      );

      if (success) {
        debugPrint('Medicine updated successfully: ${_productName.text}');
        return true;
      } else {
        debugPrint('Failed to update medicine: ${_productName.text}');
        return false;
      }
    } catch (e) {
      debugPrint('Error updating medicine: $e');
      return false;
    }
  }

  void showAlert() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Failed!',
      text: '${_productName.text} Failed to Add !',
    );
  }

  void showAlert1() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: "Added!",
      text: '${_productName.text} Product Added !',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formkey,
        child: Row(
          children: [
            Sidebar(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.057),
                      child: const Text("Edit Product",
                          style: TextStyle(
                            fontFamily: "Montserrat",
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                    // Medicine Name Field
                    Container(
                      margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.047),
                      width: MediaQuery.of(context).size.width * 0.55,
                      height: MediaQuery.of(context).size.height * 0.07,
                      child: TextFormField(
                        controller: _productName,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          prefixIcon:
                              Icon(Icons.medication, color: Colors.blue),
                          labelText: 'Medicine Name *',
                          hintText: 'Enter medicine name',
                          hintMaxLines: 1,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Medicine Name required';
                          } else {
                            RegExp regExp = RegExp(
                              r"^[a-zA-Z][a-zA-Z0-9\s]*$",
                              caseSensitive: false,
                              multiLine: false,
                            );
                            if (!regExp.hasMatch(value)) {
                              return 'Please enter a valid medicine name';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                    // Medicine Form Field
                    Container(
                      margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.047),
                      width: MediaQuery.of(context).size.width * 0.55,
                      height: MediaQuery.of(context).size.height * 0.07,
                      child: DropdownButtonFormField<String>(
                        value: _selectedProductForm,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          prefixIcon:
                              Icon(Icons.medication_liquid, color: Colors.blue),
                          labelText: 'Medicine Form *',
                          hintText: 'Select medicine form',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: "Tablet",
                            child: Text("Tablet"),
                          ),
                          DropdownMenuItem(
                            value: "Capsule",
                            child: Text("Capsule"),
                          ),
                          DropdownMenuItem(
                            value: "Syrup",
                            child: Text("Syrup"),
                          ),
                          DropdownMenuItem(
                            value: "Drops",
                            child: Text("Drops"),
                          ),
                          DropdownMenuItem(
                            value: "Injection",
                            child: Text("Injection"),
                          ),
                          DropdownMenuItem(
                            value: "Cream",
                            child: Text("Cream"),
                          ),
                          DropdownMenuItem(
                            value: "Ointment",
                            child: Text("Ointment"),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedProductForm = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Medicine Form required';
                          }
                          return null;
                        },
                      ),
                    ),
                    // Medicine Purpose Field
                    Container(
                      margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.047),
                      width: MediaQuery.of(context).size.width * 0.55,
                      height: MediaQuery.of(context).size.height * 0.07,
                      child: DropdownButtonFormField<String>(
                        value: _selectedProductPurpose,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          prefixIcon:
                              Icon(Icons.medical_services, color: Colors.blue),
                          labelText: 'Medicine Purpose',
                          hintText: 'Select medicine purpose',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: "Pain Relief",
                            child: Text("Pain Relief"),
                          ),
                          DropdownMenuItem(
                            value: "Fever",
                            child: Text("Fever"),
                          ),
                          DropdownMenuItem(
                            value: "Cough",
                            child: Text("Cough"),
                          ),
                          DropdownMenuItem(
                            value: "Cold",
                            child: Text("Cold"),
                          ),
                          DropdownMenuItem(
                            value: "Headache",
                            child: Text("Headache"),
                          ),
                          DropdownMenuItem(
                            value: "Stomach",
                            child: Text("Stomach"),
                          ),
                          DropdownMenuItem(
                            value: "Allergy",
                            child: Text("Allergy"),
                          ),
                          DropdownMenuItem(
                            value: "Other",
                            child: Text("Other"),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedProductPurpose = value;
                          });
                        },
                      ),
                    ),
                    // Price Field
                    Container(
                      margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.047),
                      width: MediaQuery.of(context).size.width * 0.55,
                      height: MediaQuery.of(context).size.height * 0.07,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: _productPrice,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                              RegExp(r"^\d+\.?\d{0,2}"))
                        ],
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          prefixText: r"$ ",
                          prefixStyle:
                              TextStyle(color: Colors.blue, fontSize: 16),
                          labelText: 'Price (\$) *',
                          hintText: '0.00',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Price required';
                          }
                          return null;
                        },
                      ),
                    ),
                    // Quantity Field
                    Container(
                      margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.047),
                      width: MediaQuery.of(context).size.width * 0.55,
                      height: MediaQuery.of(context).size.height * 0.07,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: _productQty,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          prefixText: "# ",
                          prefixStyle:
                              TextStyle(color: Colors.blue, fontSize: 16),
                          labelText: 'Quantity *',
                          hintText: '0',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Quantity required';
                          }
                          return null;
                        },
                      ),
                    ),
                    // Required fields note
                    Container(
                      margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.02),
                      width: MediaQuery.of(context).size.width * 0.55,
                      child: const Text(
                        "* Required fields",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    // A Row with 2 buttons (left: Cancel, right: Update Medicine)
                    Container(
                      margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.047),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.15,
                            height: MediaQuery.of(context).size.height * 0.06,
                            margin: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * 0.15),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                foregroundColor: Colors.grey[700],
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.20,
                            height: MediaQuery.of(context).size.height * 0.06,
                            margin: EdgeInsets.only(
                                right:
                                    MediaQuery.of(context).size.width * 0.15),
                            child: ElevatedButton(
                              onPressed: () async {
                                if (formkey.currentState!.validate()) {
                                  final value = await _updateProduct();
                                  if (!context.mounted) return;
                                  if (value) {
                                    showAlert1();
                                    Navigator.pop(context);
                                  } else {
                                    showAlert();
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text("Update Medicine",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

