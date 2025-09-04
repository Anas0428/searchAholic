import 'dart:convert';
import '../utils/imports.dart';
import '../utils/local_auth.dart';
import 'package:firedart/firedart.dart';
import 'package:crypto/crypto.dart';
import 'package:csv/csv.dart';

// TODO: These values should be moved to environment variables
// For now, using placeholder values - configure in your environment
const apiKey = "YOUR_FIREBASE_API_KEY";
const projectId = "YOUR_PROJECT_ID";
const databaseSecret = "YOUR_DATABASE_SECRET";

class FlutterApi {
  // Main Function
  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      // Initialize Firestore with authentication
      Firestore.initialize(projectId);
      FirebaseAuth.initialize(apiKey, VolatileStore());
      debugPrint("Firestore Initialized with project: $projectId");
    } catch (e) {
      debugPrint("Error initializing Firebase: $e");
    }
  }

  // check offline login
  Future<bool> checkOffline(String email, String password) async {
    try {
      Directory directory = await getApplicationDocumentsDirectory();
      String path = directory.path;
      File file = File('$path/ShopWise/user.json');

      // Check if file exists
      if (!file.existsSync()) {
        return false;
      }

      String content = file.readAsStringSync().trim();
      if (content.isEmpty) {
        return false;
      }

      var data = jsonDecode(content);
      String localEmail = data['email'] ?? '';
      String localPassword = data['password'] ?? '';

      debugPrint('Offline credentials check:');
      debugPrint('Stored email: "$localEmail"');
      debugPrint('Entered email: "$email"');
      debugPrint('Stored password: "$localPassword"');
      debugPrint('Entered password: "$password"');
      debugPrint('Email match: ${localEmail == email}');
      debugPrint('Password match: ${localPassword == password}');

      if (localEmail == email && localPassword == password) {
        debugPrint("Offline Login Successful");
        return true;
      } else {
        debugPrint("Offline Login Failed - credentials mismatch");
        return false;
      }
    } catch (e) {
      debugPrint('Offline check error: $e');
      return false;
    }
  }

  // checking login of members
  Future<bool> checkLogin(String email, String password) async {
    debugPrint('checkLogin called with email: $email');

    // First, try local data.json authentication
    try {
      if (await LocalAuth.checkLocalLogin(email, password)) {
        debugPrint('Local data.json authentication successful');
        return true;
      }
    } catch (e) {
      debugPrint('Local data.json authentication failed: $e');
    }

    // if internet is not connected then login offline (with the credentials saved from the last login)
    try {
      if (await checkOffline(email, password)) {
        debugPrint('Offline login successful');
        return true;
      }
    } catch (e) {
      debugPrint('Offline check failed: $e');
    }

    debugPrint('Attempting online login...');
    // Getting the User Collection
    try {
      final managers = Firestore.instance.collection(email);
      final manager = managers.document("Store Details");

      debugPrint('Attempting to fetch user data from Firestore...');
      final data = await manager.get();

      debugPrint('Retrieved data from Firestore');
      debugPrint('Stored email: "${data['email']}"');
      debugPrint('Entered email: "$email"');
      debugPrint('Stored password: "${data['password']}"');
      debugPrint('Entered password: "$password"');
      debugPrint('Email match: ${data['email'] == email}');
      debugPrint('Password match: ${data['password'] == password}');

      if (data['password'] == password && data['email'] == email) {
        debugPrint('Online login successful');
        return true;
      } else {
        debugPrint('Online login failed - credentials mismatch');
        return false;
      }
    } catch (e) {
      debugPrint('Online login error: $e');
      return false;
    }
  }

  // Registration
  Future<bool> register(String email, String storeName, String location,
      String phNo, String password) async {
    // Splitting the Location
    List<String> locationParts = location.split(",");
    String lat = locationParts[0];
    String long = locationParts[1];

    // Checking if the email is already registered
    final managers = Firestore.instance.collection(email);

    // Checking for the document with the email
    if (await managers.document(email).exists) {
      debugPrint(managers.document(email).toString());
      debugPrint("Email Already Registered");
      return Future<bool>.value(false);
    } else {
      // Creating a new document with the email
      final manager = managers.document("Store Details");
      debugPrint("Created New Document");
      // Adding the data to the document

      await manager.set({
        'email': email,
        'storeName': storeName,
        'phNo': phNo,
        'password': password,
        "storeLocation": GeoPoint(double.parse(lat), double.parse(long)),
        "storeId": generateStoreId(email),
      });
      debugPrint("Data Added");
      return Future<bool>.value(true);
    }
  }

  Future<bool> addProduct(String productName, String productPrice,
      String productQty, String productType) async {
    String email = await getEmail();
    String userId = generateStoreId(email); // This will be the user's unique ID
    String productID = generateProductId(productName);
    List storeDetails = await getStoreDetails();

    try {
      // Check if product already exists in user's products subcollection
      final existingProduct = await Firestore.instance
          .collection("Products")
          .document(userId)
          .collection("products")
          .document(productID)
          .get();

      if (existingProduct.map.isNotEmpty) {
        // Update existing product quantity
        int prevQty = int.parse(existingProduct['quantity'] ?? '0');
        int newQty = prevQty + int.parse(productQty);

        await Firestore.instance
            .collection("Products")
            .document(userId)
            .collection("products")
            .document(productID)
            .update({
          'quantity': newQty.toString(),
          'updatedAt': DateTime.now().toIso8601String(),
        });
        debugPrint("Updated existing product quantity: $newQty");
      } else {
        // Add new product to user's products subcollection
        await Firestore.instance
            .collection("Products")
            .document(userId)
            .collection("products")
            .document(productID)
            .set({
          'name': productName,
          'quantity': productQty,
          'price': double.parse(productPrice),
          'type': productType,
          'expiry': "Not Set",
          'category': "Not Set",
          'userId': userId,
          'productId': productID,
          'storeName': storeDetails[0],
          'storeLocation': GeoPoint(
              double.parse(storeDetails[1]), double.parse(storeDetails[2])),
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        });
        debugPrint("Added new product: $productName");
      }

      return Future<bool>.value(true);
    } catch (e) {
      debugPrint("Error adding product: $e");
      return Future<bool>.value(false);
    }
  }

  Future<bool> emailCheck(String email1) async {
    final managers = Firestore.instance.collection(email1);
    debugPrint(managers.toString());

    final manager = managers.document("Store Details");
    debugPrint(manager.toString());
    debugPrint("Got Managers");

    // Getting the Data from the Document
    try {
      final data = await manager.get();
      if (data['email'] == email1) {
        return Future<bool>.value(true);
      } else {
        return Future<bool>.value(false);
      }
    } catch (e) {
      debugPrint("Error Occured - Does not Find Data ");
      return Future<bool>.value(false);
    }
  }

  ///change password
  Future<bool> forgetPassword(String email1, String password) async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path;
    // getting the email from the user.json file
    File file = File('$path/ShopWise/user.json');
    String email = jsonDecode(file.readAsStringSync())['email'];
    try {
      // Adding the product to the database
      await Firestore.instance
          .collection(email)
          .document("Store Details")
          .update({
        'password': password,
      });
      return Future<bool>.value(true);
    } catch (e) {
      debugPrint("Not Connected to the Internet");
      return Future<bool>.value(false);
    }
  }

  // Add Order
  Future<bool> addOrder(
      List<dynamic> selectedProc, var totalBill, var phoneNo) async {
    var email = await getEmail();
    var time = DateTime.now();
    var saleId = generateStoreId(time.toString());
    var storeId = generateStoreId(email);

    Map saleProducts = {};

    // Storing the products in the map in key value pair key == productName value == quantity

    for (var i = 0; i < selectedProc.length; i++) {
      // if product is already in saleProducts then add the quantity
      if (saleProducts.containsKey(selectedProc[i]["Name"])) {
        int prevQty = int.parse(saleProducts[selectedProc[i]["Name"]]);
        int newQty = prevQty + int.parse(selectedProc[i]["Quantity"]);
        saleProducts[selectedProc[i]["Name"]] = newQty.toString();
        continue;
      }
      saleProducts.addAll({
        selectedProc[i]["Name"]: selectedProc[i]["Quantity"],
      });
    }

    try {
      Firestore.instance.collection(storeId).document(saleId).set({
        "customerPhone": phoneNo.toString(),
        "saleAmount": totalBill,
        "saleDate": time,
        "saleProducts": saleProducts,
      });
      return Future<bool>.value(true);
    } catch (e) {
      debugPrint(e.toString());
      return Future<bool>.value(false);
    }
  }

  // Updating the Products Quantity
  Future<bool> updateProductsQuantity(List<Document> selectedProc) async {
    var email = await getEmail();
    debugPrint(email);
    try {
      for (var i = 0; i < selectedProc.length; i++) {
        Firestore.instance
            .collection(email)
            .document("Product")
            .collection("products")
            .document(selectedProc[i].id)
            .update({
          'productQty': selectedProc[i]["quantity"],
        });
      }
      return Future<bool>.value(true);
    } catch (e) {
      debugPrint("Not Connected to the Internet");
      return Future<bool>.value(false);
    }
  }

  getEmail() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path;
    // Directory folder = Directory('$path/ShopWise'); // UNUSED

    // getting the email from the user.json file
    File file = File('$path/ShopWise/user.json');
    String email = jsonDecode(file.readAsStringSync())['email'];
    return email;
  }

  // Generate StoreID based on the email using MD5
  String generateStoreId(String email) {
    var content = Utf8Encoder().convert(email);
    var digest = md5.convert(content);
    return digest.toString();
  }

  // Generate ProductID based on the productName using MD5
  String generateProductId(String productName) {
    var content = Utf8Encoder().convert(productName);
    var digest = md5.convert(content);
    return digest.toString();
  }

  // Converting File Data To Correct Format csv to list of products with productId and Store ID
  Future<List<List<dynamic>>> readCsvFile(String filePath) async {
    final input = File(filePath).openRead();
    const parser = CsvToListConverter(
        eol: '\n', fieldDelimiter: ',', shouldParseNumbers: true);

    final result =
        await input.transform(utf8.decoder).transform(parser).toList();

    result.removeAt(0);
    return result;
  }

  // listCompare function

  bool listEql(List a, List b) {
    debugPrint(a.toString());
    debugPrint(b.toString());
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }

  // get Store Name and Store Locaion by email
  Future<List<String>> getStoreDetails() async {
    String email = await getEmail();
    var data = await Firestore.instance
        .collection(email)
        .document("Store Details")
        .get();
    var lat = data['storeLocation'].latitude.toString();
    var lon = data['storeLocation'].longitude.toString();
    List<String> storeDetails = [
      data['storeName'],
      lat,
      lon,
    ];
    return storeDetails;
  }

  // check csv file herder and return the if the file is valid or not
  Future<bool> checkFileHeader(String filepath) async {
    // final file = File(filepath).openRead(); // Removed unused variable
    return Future<bool>.value(true);
    // var newFields = input[0].split(',');
    // if (listEql(fields.toString() isnewFields.elementAt(0).toString())) {
    //   print("File is Valid");
    //   return Future<bool>.value(true);
    // } else {
    //   print("File is not Valid");
    //   return Future<bool>.value(false);
    // }
  }

  // Uploading the File to the Data Base Against the StoreId
  Future<bool> uploadFile(String filePath) async {
    try {
      Map<String, dynamic> data = {};
      List<List<dynamic>> products = await readCsvFile(filePath);

      // Adding the products to the database using correct CSV format
      // Expected CSV format: Name, Category, Type, Price, Quantity
      for (var i = 0; i < products.length; i++) {
        String productId = generateProductId(products[i][0]);
        var x = {
          productId: {
            "name": products[i][0],      // Column 1: Name
            "category": products[i][1],  // Column 2: Category
            "type": products[i][2],      // Column 3: Type
            "price": products[i][3],     // Column 4: Price
            "quantity": products[i][4],  // Column 5: Quantity
            "createdAt": DateTime.now().toIso8601String(),
            "updatedAt": DateTime.now().toIso8601String(),
          }
        };
        data.addAll(x);
      }
      await adddProduct(data);
      debugPrint("Products Uploaded Successfully");
      return Future<bool>.value(true);
    } catch (e) {
      debugPrint(e.toString());
      return Future<bool>.value(false);
    }
  }

  Future<bool> adddProduct(Map<String, dynamic> data) async {
    try {
      final userId = generateStoreId(await getEmail());

      // Add each product to the user's products subcollection
      for (String productId in data.keys) {
        final productData = data[productId];
        await Firestore.instance
            .collection("Products")
            .document(userId)
            .collection("products")
            .document(productId)
            .set({
          ...productData,
          'userId': userId,
          'productId': productId,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }

      debugPrint("Bulk products uploaded successfully");
      return Future<bool>.value(true);
    } catch (e) {
      debugPrint("Error uploading bulk products: $e");
      return Future<bool>.value(false);
    }
  }

  Future<List<Document>> getAllProducts() async {
    final userId = generateStoreId(await getEmail());

    try {
      final productsSnapshot = await Firestore.instance
          .collection("Products")
          .document(userId)
          .collection("products")
          .get();

      if (productsSnapshot.isEmpty) {
        debugPrint("No Products Found - User has no products");
        return [];
      }

      return productsSnapshot;
    } catch (e) {
      debugPrint("Error getting products: $e");
      return [];
    }
  }

  // Real-time stream for products (for multi-app synchronization)
  Stream<List<Document>> getProductsStream() async* {
    // For now, return a simple stream that gets all products
    // Real-time streaming will be implemented when needed
    final products = await getAllProducts();
    yield products;
  }
}

// Data Model
/*
var DATA = {
          "Name": data["Name"],
          "Quantity": data["Quantity"], // double
          "Price": data["Price"], // double
          "Type": data["Type"], // Public, Private
          "ExpireDate": data["ExpireDate"], // Date
          "Category": data["Category"],
          "StoreId": store.id,
          "ProductId": product.id,
          "StoreName": data["StoreName"],
          "StoreLocation": data["StoreLocation"],
        };
        
        */

// // Add Product to database
// Future<bool> adddProduct(
//   String Name,
//   String Quantity,
//   String Price,
//   String Type,
//   String Expire,
//   String Category,
//   String StoreId,
//   String ProductId,
//   String StoreName,
//   List StoreLocation,
// ) async {
//   try {
//     // Uploading the Product to the database
//     Firestore.instance
//         .collection("products")
//         .document(StoreId)
//         .collection("product")
//         .document(ProductId)
//         .set({
//       "Name": Name,
//       "Quantity": Quantity, // double
//       "Price": Price, // double
//       "Type": Type, // Public, Private
//       "ExpireDate": Expire, // Date
//       "Category": Category,
//       "StoreId": StoreId,
//       "ProductId": ProductId,
//       "StoreName": StoreName,
//       "StoreLocation": GeoPoint(
//           double.parse(StoreLocation[1]), double.parse(StoreLocation[2])),
//     });
//     print("Product ${Name} added");
//     return Future<bool>.value(true);
//   } catch (e) {
//     print(e);
//     return Future<bool>.value(false);
//   }
// }
