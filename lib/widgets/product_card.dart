// ignore_for_file: unrelated_type_equality_checks, prefer_interpolation_to_compose_strings, prefer_const_constructors, must_be_immutable, sized_box_for_whitespace

import 'dart:convert';

import 'package:firedart/firestore/firestore.dart';
import 'package:shopwise/screens/products/edit_product.dart';
import 'package:shopwise/utils/imports.dart';
import 'package:shopwise/models/product.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});
  final Map<String, dynamic> product;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.15,
      margin: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height * 0.01,
        horizontal: MediaQuery.of(context).size.width * 0.02,
      ),
      child: Card(
        shadowColor: Colors.grey[300],
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Product Name
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      product['Name'] ?? 'Unknown Product',
                      style: TextStyle(
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Category: ${product['Category'] ?? 'N/A'}',
                      style: TextStyle(
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Quantity
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Quantity',
                      style: TextStyle(
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 74, 135, 249).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${product['Quantity'] ?? '0'}',
                        style: TextStyle(
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color.fromARGB(255, 74, 135, 249),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Price
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Price',
                      style: TextStyle(
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Rs. ${product['Price'] ?? '0'}',
                      style: TextStyle(
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color.fromARGB(255, 231, 79, 87),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Actions
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Edit Button
                    ElevatedButton(
                      onPressed: () {
                        navigate(context, product["id"]);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 74, 135, 249),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: Text(
                        "Edit",
                        style: TextStyle(
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    
                    // Delete Button
                    ElevatedButton(
                      onPressed: () {
                        // Delete product
                        var productID = product["id"];
                        // Are you sure?
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Are you sure?"),
                              content: Text("This action cannot be undone."),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    // Delete product
                                    if (await deleteProduct(productID) ==
                                        true) {
                                      if (context.mounted) {
                                        Navigator.pop(context);

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text("Product deleted, "),
                                          ),
                                        );
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const Product()));
                                      }
                                    }
                                  },
                                  child: const Text("Delete"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 255, 125, 125),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: Text(
                        "Delete",
                        style: TextStyle(
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void navigate(context, productID) {
    debugPrint("Navigating to edit product page...");
    getEmail().then((value) {
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditProduct(
              productID: productID,
              email: value,
            ),
          ),
        );
      }
    });
  }

  Future<String> getEmail() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path;

    // getting the email from the user.json file
    File file = File('$path/ShopWise/user.json');
    String email = jsonDecode(file.readAsStringSync())['email'];

    return Future<String>.value(email);
  }

  Map<String, dynamic> removeMapData(Map<String, dynamic> map, String id) {
    map.remove(id);
    map.forEach((key, value) {
      if (key == id) {
        debugPrint("Found the key to be deleted");
        map.remove(key);
      }
    });
    return map;
  }

  Future<bool> deleteProduct(String id) async {
    debugPrint("Product Deleted: $id");

    String email = await FlutterApi().getEmail();
    var x = FlutterApi().generateStoreId(email);

    // Deleting the Product from Firestore
    try {
      final data =
          await Firestore.instance.collection("Products").document(x).get();
      final map = removeMapData(data.map, id);
      await Firestore.instance.collection("Products").document(x).set(map);
      return Future.value(true);
    } catch (e) {
      debugPrint(e.toString());
      return Future.value(false);
    }
  }
}
