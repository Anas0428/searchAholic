import 'package:shopwise/widgets/sidebar.dart';
import 'package:shopwise/widgets/text_box.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopwise/utils/imports.dart';
import '../../services/auth_service.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({
    super.key,
  });

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String? storeName;
  String? email;
  String? phoneNumber;
  double? addressLat;
  double? addressLong;

  /// Get profile data from database
  Future<void> getProfile() async {
    try {
      User? user = AuthService.currentUser;
      if (user == null) {
        debugPrint("No authenticated user");
        return;
      }

      // Get user profile from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>?;
        if (userData != null) {
          setState(() {
            storeName = userData['storeName'] ?? 'My Store';
            email = userData['email'] ?? user.email;
            phoneNumber = userData['phoneNumber'] ?? '';
            addressLat = userData['lat']?.toDouble();
            addressLong = userData['long']?.toDouble();
          });
        }
      } else {
        // Set default values if no profile exists
        setState(() {
          storeName = 'My Store';
          email = user.email;
          phoneNumber = '';
          addressLat = null;
          addressLong = null;
        });
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    getProfile();
  }

  // Image assets for the text boxes
  final AssetImage newOrder = const AssetImage("images/newOrder.png");
  final AssetImage searchProduct = const AssetImage("images/searchProduct.png");
  final AssetImage addProduct = const AssetImage("images/addProduct.png");
  final AssetImage addCategory = const AssetImage("images/addCategory.png");
  final AssetImage viewOrders = const AssetImage("images/viewOrders.png");
  final AssetImage reports = const AssetImage("images/report.png");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04,
              ),
              child: Column(
                children: [
                  // Store name header
                  Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.087,
                    ),
                    child: Text(
                      storeName ?? "",
                      style: TextStyle(
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.w600,
                        fontSize: MediaQuery.of(context).size.width / 45,
                      ),
                    ),
                  ),

                  // Today's report section
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Today's report",
                      style: TextStyle(
                        color: Colors.blue,
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.w400,
                        fontSize: MediaQuery.of(context).size.width / 55,
                      ),
                    ),
                  ),

                  ///Today's report card
                  Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.017,
                      bottom: MediaQuery.of(context).size.height * 0.02,
                    ),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.width * 0.1,
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ///Revenue
                            Padding(
                              padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.width * 0.01,
                                bottom:
                                    MediaQuery.of(context).size.width * 0.01,
                                left: MediaQuery.of(context).size.width * 0.01,
                                right: MediaQuery.of(context).size.width * 0.01,
                              ),
                              child: Card(
                                elevation: 1,
                                color: Colors.grey[100],
                                child: Padding(
                                    padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        ///Text
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Revenue",
                                              style: TextStyle(
                                                color: Colors.blue,
                                                fontFamily: "Montserrat",
                                                fontWeight: FontWeight.w300,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    55,
                                              ),
                                            ),
                                          ],
                                        ),

                                        ///Padding
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.015,
                                        ),

                                        ///Icon
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.007,
                                              bottom: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.007),
                                          child: const Image(
                                            image: AssetImage(
                                                "images/revenue_icon.png"),
                                          ),
                                        )
                                      ],
                                    )),
                              ),
                            ),

                            ///Sale
                            Padding(
                              padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.width * 0.01,
                                left: MediaQuery.of(context).size.width * 0.075,
                                bottom:
                                    MediaQuery.of(context).size.width * 0.01,
                                right: MediaQuery.of(context).size.width * 0.01,
                              ),
                              child: Card(
                                elevation: 1,
                                color: Colors.grey[100],
                                child: Padding(
                                    padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        ///Text
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Sale",
                                              style: TextStyle(
                                                color: Colors.blue,
                                                fontFamily: "Montserrat",
                                                fontWeight: FontWeight.w300,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    55,
                                              ),
                                            ),
                                          ],
                                        ),

                                        ///Padding
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.015,
                                        ),

                                        ///Icon
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.007,
                                              bottom: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.007),
                                          child: const Image(
                                            image: AssetImage(
                                                "images/sale_icon.png"),
                                          ),
                                        )
                                      ],
                                    )),
                              ),
                            ),

                            ///Orders
                            Padding(
                              padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.width * 0.01,
                                bottom:
                                    MediaQuery.of(context).size.width * 0.01,
                                left: MediaQuery.of(context).size.width * 0.057,
                                right:
                                    MediaQuery.of(context).size.width * 0.0009,
                              ),
                              child: Card(
                                elevation: 1,
                                color: Colors.grey[100],
                                child: Padding(
                                    padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        ///Text
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Orders",
                                              style: TextStyle(
                                                color: Colors.blue,
                                                fontFamily: "Montserrat",
                                                fontWeight: FontWeight.w300,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    55,
                                              ),
                                            ),
                                          ],
                                        ),

                                        ///Padding
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.015,
                                        ),

                                        ///Icon
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.007,
                                              bottom: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.007),
                                          child: const Image(
                                            image: AssetImage(
                                                "images/orders_icon.png"),
                                          ),
                                        )
                                      ],
                                    )),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Items & Inventory section
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Items & Inventory",
                      style: TextStyle(
                        color: Colors.blue,
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.w400,
                        fontSize: MediaQuery.of(context).size.width / 45,
                      ),
                    ),
                  ),

                  // Items & Inventory card
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.017,
                        bottom: MediaQuery.of(context).size.height * 0.02,
                      ),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            MediaQuery.of(context).size.width * 0.02,
                            MediaQuery.of(context).size.height * 0.022,
                            MediaQuery.of(context).size.width * 0.02,
                            MediaQuery.of(context).size.height * 0.022,
                          ),

                          // Action buttons grid
                          child: ListView(
                            children: [
                              // First row of buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // New Order
                                  textBox(
                                    context,
                                    "New Order",
                                    const Color.fromRGBO(152, 156, 228, 1),
                                    const Color.fromRGBO(168, 204, 236, 1),
                                    newOrder,
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  // Search Product
                                  textBox(
                                    context,
                                    "Search Product",
                                    const Color.fromRGBO(255, 196, 116, 0.9),
                                    const Color.fromRGBO(255, 172, 124, 1),
                                    searchProduct,
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  // Add Product
                                  textBox(
                                    context,
                                    "Add Product",
                                    const Color.fromRGBO(128, 194, 255, 1),
                                    const Color.fromRGBO(53, 253, 253, 1),
                                    addProduct,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.03,
                              ),
                              // Second row of buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Upload Data
                                  textBox(
                                    context,
                                    "Upload Data",
                                    const Color.fromRGBO(255, 162, 180, 1),
                                    const Color.fromRGBO(255, 162, 180, 0.95),
                                    addCategory,
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  // View Sales
                                  textBox(
                                    context,
                                    "View Sales",
                                    const Color.fromRGBO(184, 204, 252, 1),
                                    const Color.fromRGBO(252, 212, 244, 1),
                                    viewOrders,
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  // Report
                                  textBox(
                                    context,
                                    "Report",
                                    const Color.fromRGBO(248, 207, 127, 1),
                                    const Color.fromRGBO(184, 206, 132, 1),
                                    reports,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
