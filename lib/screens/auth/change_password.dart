import 'dart:convert';

import 'package:firedart/firestore/firestore.dart';
import 'package:shopwise/utils/imports.dart';
import 'package:quickalert/quickalert.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _passwordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordObscure = true;
  bool _isNewPasswordObscure = true;
  bool _isConfirmPasswordObscure = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _showWrongPasswordAlert() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Error',
      text: 'Current password is incorrect',
    );
  }

  void _showPasswordMismatchAlert() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Error',
      text: 'New password and confirm password do not match',
    );
  }

  void _showSamePasswordAlert() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Error',
      text: 'New password cannot be the same as current password',
    );
  }

  void _showSuccessAlert() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: 'Success',
      text: 'Password changed successfully!',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left Side
          Container(
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.02,
            ),
            width: MediaQuery.of(context).size.width * 0.5,
            color: Colors.white,
            child: Expanded(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.116,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          "Confirm Credentials",
                          style: GoogleFonts.montserrat(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // Current Password Field
                    Container(
                      margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.035,
                      ),
                      width: MediaQuery.of(context).size.width * 0.37,
                      child: TextFormField(
                        obscureText: _isPasswordObscure,
                        maxLength: 18,
                        controller: _passwordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password required';
                          } else {
                            RegExp regExp = RegExp(
                              r"^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$",
                              caseSensitive: false,
                              multiLine: false,
                            );
                            if (!regExp.hasMatch(value)) {
                              return 'Please enter a valid password';
                            }
                          }
                          return null;
                        },

                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                              icon: Icon(_isPasswordObscure
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _isPasswordObscure = !_isPasswordObscure;
                                });
                              }),
                          hintText: "Current Password",
                          hintStyle: GoogleFonts.montserrat(
                            fontSize: 15,
                            color: Colors.grey[450],
                            fontWeight: FontWeight.w500,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(width: 0.15),
                          ),
                        ),
                      ),
                    ),

                    // New Password Field
                    Container(
                      margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.035,
                      ),
                      width: MediaQuery.of(context).size.width * 0.37,
                      child: TextFormField(
                        obscureText: _isNewPasswordObscure,
                        maxLength: 18,
                        controller: _newPasswordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password required';
                          } else {
                            RegExp regExp = RegExp(
                              r"^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$",
                              caseSensitive: false,
                              multiLine: false,
                            );
                            if (!regExp.hasMatch(value)) {
                              return 'Please enter a valid password';
                            }
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                              icon: Icon(_isNewPasswordObscure
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _isNewPasswordObscure = !_isNewPasswordObscure;
                                });
                              }),
                          hintText: "New Password",
                          hintStyle: GoogleFonts.montserrat(
                            fontSize: 15,
                            color: Colors.grey[450],
                            fontWeight: FontWeight.w500,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(width: 0.15),
                          ),
                        ),
                      ),
                    ),

                    // Confirm Password Field
                    Container(
                      margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.035,
                      ),
                      width: MediaQuery.of(context).size.width * 0.37,
                      child: TextFormField(
                        obscureText: _isConfirmPasswordObscure,
                        maxLength: 18,
                        controller: _confirmPasswordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password required';
                          } else {
                            RegExp regExp = RegExp(
                              r"^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$",
                              caseSensitive: false,
                              multiLine: false,
                            );
                            if (!regExp.hasMatch(value)) {
                              return 'Please enter a valid password';
                            }
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                              icon: Icon(_isConfirmPasswordObscure
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordObscure = !_isConfirmPasswordObscure;
                                });
                              }),
                          hintText: "Confirm Password",
                          hintStyle: GoogleFonts.montserrat(
                            fontSize: 15,
                            color: Colors.grey[450],
                            fontWeight: FontWeight.w500,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(width: 0.15),
                          ),
                        ),
                      ),
                    ),

                    // Change Password Button
                    Container(
                      margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.055,
                      ),
                      width: MediaQuery.of(context).size.width * 0.37,
                      height: MediaQuery.of(context).size.height * 0.06,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            if (await _checkCurrentPassword(_passwordController.text)) {
                              _showWrongPasswordAlert();
                            } else if (_isNewPasswordSameAsOld(
                                _passwordController.text, _newPasswordController.text)) {
                              _showSamePasswordAlert();
                            } else if (!_doPasswordsMatch(
                                _newPasswordController.text, _confirmPasswordController.text)) {
                              _showPasswordMismatchAlert();
                            } else {
                              await _changePassword(_confirmPasswordController.text);
                              _showSuccessAlert();
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(53, 108, 254, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Change Password",
                          style: GoogleFonts.montserrat(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    // Back Button
                    Container(
                      margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.025,
                      ),
                      width: MediaQuery.of(context).size.width * 0.37,
                      height: MediaQuery.of(context).size.height * 0.06,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Dashboard(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(53, 108, 254, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Back",
                          style: GoogleFonts.montserrat(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Right Side
          Container(
            width: MediaQuery.of(context).size.width * 0.5,
            color: const Color.fromRGBO(8, 92, 228, 1),
            child: Expanded(
              child: Column(
                children: [
                  // Txt Field
                  Container(
                    height: MediaQuery.of(context).size.height * 0.119,
                    margin: const EdgeInsets.only(top: 60),
                    child: Text(
                      "Change Password",
                      style: GoogleFonts.montserrat(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Image Container
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    color: const Color.fromRGBO(53, 108, 254, 1),
                    child: Image.asset(
                      'images/password_recover.jpg',
                      fit: BoxFit.contain,
                      height: MediaQuery.of(context).size.height * 0.5,
                    ),
                  ),
                  // Txt Field Container
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    child: Text(
                      'ShopWise',
                      style: GoogleFonts.montserrat(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.right,
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

  /// Check if the current password is correct
  Future<bool> _checkCurrentPassword(String password) async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path;

    File file = File('$path/ShopWise/user.json');
    String email = jsonDecode(file.readAsStringSync())['email'];

    var collection = Firestore.instance.collection(email);
    var document = collection.document('Store Details');
    var data = await document.get();
    
    return data['password'] != password;
  }

  /// Check if new password is the same as old password
  bool _isNewPasswordSameAsOld(String currentPassword, String newPassword) {
    return currentPassword == newPassword;
  }

  /// Check if new password matches confirm password
  bool _doPasswordsMatch(String newPassword, String confirmPassword) {
    return newPassword == confirmPassword;
  }

  /// Update password in database
  Future<bool> _changePassword(String newPassword) async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path;

    File file = File('$path/ShopWise/user.json');
    String email = jsonDecode(file.readAsStringSync())['email'];
    
    try {
      await Firestore.instance
          .collection(email)
          .document("Store Details")
          .update({
        'password': newPassword,
      });
      return true;
    } catch (e) {
      debugPrint("Failed to update password: $e");
      return false;
    }
  }
}
