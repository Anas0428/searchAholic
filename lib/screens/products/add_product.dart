// Add Product Page

// Path: lib\addProduct.dart
import 'package:flutter/services.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shopwise/models/product.dart';
import 'package:shopwise/widgets/sidebar.dart';
import 'package:shopwise/services/product_service.dart';

import '../../utils/imports.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  // Controllers for the TextFields
  final TextEditingController _medicineName = TextEditingController();
  final TextEditingController _medicinePrice = TextEditingController();
  final TextEditingController _medicineQty = TextEditingController();
  String? _selectedMedicineForm;
  String? _selectedMedicinePurpose;

  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  TextEditingController dateinput = TextEditingController();

  // Using ProductService for Firebase integration

  @override
  // Update State
  void initState() {
    dateinput.text = "";
    super.initState();
  }

  void showAlert() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Failed!',
      text: '${_medicineName.text} Failed to Add !',
    );
  }

  void showAlert1() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: "Added!",
      text: '${_medicineName.text} Medicine Added !',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formkey,
        child: Row(
          children: [
            const Sidebar(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.057),
                      child: const Text("Add Medicine",
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
                        controller: _medicineName,
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
                        value: _selectedMedicineForm,
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
                            _selectedMedicineForm = value;
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
                        value: _selectedMedicinePurpose,
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
                            _selectedMedicinePurpose = value;
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
                        controller: _medicinePrice,
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
                        controller: _medicineQty,
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
                    // A Row with 2 buttons (left: Cancel, right: Add Medicine)
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
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Product()));
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
                              onPressed: () {
                                // Add Medicine to the Database
                                if (formkey.currentState!.validate()) {
                                  addProduct().then((value) {
                                    if (value) {
                                      showAlert1();
                                      _medicineName.clear();
                                      _medicinePrice.clear();
                                      _medicineQty.clear();
                                      _selectedMedicineForm = null;
                                      _selectedMedicinePurpose = null;
                                    } else {
                                      showAlert();
                                    }
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text("Add Medicine",
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

  Future<bool> addProduct() async {
    try {
      // Validate required fields
      if (_medicineName.text.isEmpty ||
          _medicinePrice.text.isEmpty ||
          _medicineQty.text.isEmpty ||
          _selectedMedicineForm == null) {
        debugPrint('Validation failed: Missing required fields');
        return false;
      }

      debugPrint('Attempting to add medicine: ${_medicineName.text}');

      // Use the new ProductService for Firebase integration
      try {
        final success = await ProductService.addProduct(
          name: _medicineName.text,
          price: double.parse(_medicinePrice.text),
          quantity: int.parse(_medicineQty.text),
          type: _selectedMedicineForm!,
          category: _selectedMedicinePurpose ?? "Not Set",
        );

        if (success) {
          debugPrint(
              'Medicine added successfully using ProductService: ${_medicineName.text}');
          // Clear form fields
          _medicineName.clear();
          _medicinePrice.clear();
          _medicineQty.clear();
          setState(() {
            _selectedMedicineForm = null;
            _selectedMedicinePurpose = null;
          });
          return true;
        } else {
          debugPrint('ProductService failed, trying fallback method');
        }
      } catch (e) {
        debugPrint('ProductService error: $e, trying fallback method');
      }

      debugPrint('ProductService failed to add medicine: ${_medicineName.text}');
      return false;
    } catch (e) {
      debugPrint('Error adding medicine: $e');
      return false;
    }
  }
}
