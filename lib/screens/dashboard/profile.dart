import 'dart:convert';
import 'package:firedart/firedart.dart';
import 'package:firedart/firestore/firestore.dart';
import 'package:shopwise/utils/imports.dart';
import 'package:shopwise/widgets/sidebar.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? _storeName;
  String? _email;
  String? _phoneNumber;
  String? _address;

  ///getting profile data from databae
  Future<void> _getProfile() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path;
    File file = File('$path/ShopWise/user.json');
    String email = jsonDecode(file.readAsStringSync())['email'];

    var storeData = Firestore.instance.collection(email);
    var storeDetails = storeData.document('Store Details');
    var storeInfo = await storeDetails.get();

    setState(() {
      _storeName = storeInfo['storeName'];
      _email = storeInfo['email'];
      _phoneNumber = storeInfo['phNo'];
      _address = storeInfo['storeLocation'];
    });
  }

  @override
// Update State
  void initState() {
    _getProfile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Form(
      child: Row(children: [
        Sidebar(),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: Column(children: [
              ///Image with store name
              Container(
                height: MediaQuery.of(context).size.height * 0.32,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/profile.jpg'),
                    fit: BoxFit.fill,
                  ),
                  shape: BoxShape.rectangle,
                ),
                child: Center(
                  child: Text('$_storeName',
                      style: TextStyle(
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.w500,
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: MediaQuery.of(context).size.width / 13,
                      )),
                ),
              ),

              ///store name
              Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.057),
                width: MediaQuery.of(context).size.width * 0.6,
                // Options [Public or Private]
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    border:
                        Border.all(color: Color.fromARGB(255, 92, 154, 241))),
                child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height,
                    ),
                    child: Text(
                      "  Store Name :             $_storeName",
                      style: TextStyle(
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.w500,
                        fontSize: MediaQuery.of(context).size.width / 50,
                      ),
                    )),
              ),

              ///Phone Number
              Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.057),
                width: MediaQuery.of(context).size.width * 0.6,
                // Options [Public or Private]
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    border:
                        Border.all(color: Color.fromARGB(255, 92, 154, 241))),
                child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height,
                    ),
                    child: Text(
                      "  Phone No :                $_phoneNumber",
                      style: TextStyle(
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.w500,
                        fontSize: MediaQuery.of(context).size.width / 50,
                      ),
                    )),
              ),

              ///Address
              Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.057),
                width: MediaQuery.of(context).size.width * 0.6,
                // Options [Public or Private]
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    border:
                        Border.all(color: Color.fromARGB(255, 92, 154, 241))),
                child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height,
                    ),
                    child: Text(
                      "  Address :    $_address",
                      style: TextStyle(
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.w500,
                        fontSize: MediaQuery.of(context).size.width / 50,
                      ),
                    )),
              ),

              ///Email
              Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.057),
                width: MediaQuery.of(context).size.width * 0.6,
                // Options [Public or Private]
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    border:
                        Border.all(color: Color.fromARGB(255, 92, 154, 241))),
                child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height,
                    ),
                    child: Text(
                      "  Email :                        $_email",
                      style: TextStyle(
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.w500,
                        fontSize: MediaQuery.of(context).size.width / 50,
                      ),
                    )),
              ),
            ]),
          ),
        ),
      ]),
    ));
    //]));
  }
}
