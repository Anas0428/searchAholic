import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../../services/auth_service.dart';
import '../../utils/imports.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isObscure = true;
  GlobalKey<FormState> formkey = GlobalKey<FormState>();

  void showAlert() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Oops...',
      text: 'Invalid credentials!!',
    );
  }

  void showAlert1() {
    QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: 'Yahoooo...',
        text: 'Registration successful!!',
        confirmBtnText: 'Ok',
        onConfirmBtnTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Login(),
            ),
          );
        });
  }

  void showAlert2() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Sorry.....',
      text: 'Email is already registered. Try to signin',
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left Side
          Container(
            width: MediaQuery.of(context).size.width * 0.5,
            color: Colors.white,
            child: SingleChildScrollView(
              child: Form(
                key: formkey,
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.116,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          "Registration",
                          style: GoogleFonts.montserrat(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // Text Field Email
                    Container(
                      margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.027,
                      ),
                      width: MediaQuery.of(context).size.width * 0.37,
                      child: TextFormField(
                        controller: _emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email Required';
                          } else {
                            RegExp regExp = RegExp(
                              r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                              caseSensitive: false,
                              multiLine: false,
                            );

                            if (!regExp.hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "Email",
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
                    // Store Name
                    Container(
                      margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.015,
                      ),
                      width: MediaQuery.of(context).size.width * 0.37,
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Name required';
                          } else {
                            RegExp regExp = RegExp(
                              r"^[A-Za-z\s]*$",
                              caseSensitive: false,
                              multiLine: false,
                            );
                            if (!regExp.hasMatch(value)) {
                              return 'Please enter a valid name';
                            }
                          }
                          return null;
                        },
                        controller: _storeNameController,
                        decoration: InputDecoration(
                          hintText: "Store Name",
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
                    // Password (with eye icon)
                    Container(
                      margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.015,
                      ),
                      width: MediaQuery.of(context).size.width * 0.37,
                      child: TextFormField(
                        obscureText: _isObscure,
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
                              icon: Icon(_isObscure
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _isObscure = !_isObscure;
                                });
                              }),
                          hintText: "Password",
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
                    // Register Button
                    Container(
                      margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.025,
                      ),
                      width: MediaQuery.of(context).size.width * 0.37,
                      height: MediaQuery.of(context).size.height * 0.06,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (formkey.currentState!.validate()) {
                            try {
                              final result =
                                  await AuthService.signUpWithEmailAndPassword(
                                email: _emailController.text,
                                password: _passwordController.text,
                                fullName: _storeNameController.text,
                              );

                              if (result != null) {
                                showAlert1();
                              } else {
                                showAlert2();
                              }
                            } catch (e) {
                              debugPrint('Registration error: $e');
                              showAlert();
                            }
                          } else {
                            showAlert();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(53, 108, 254, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Register",
                          style: GoogleFonts.montserrat(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    // LOGIN INSTEAD Button
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
                              builder: (context) => const Login(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(53, 108, 254, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Already have account? Login",
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
            color: const Color.fromRGBO(53, 108, 254, 1),
            child: Column(
              children: [
                // Txt Field
                Container(
                  height: MediaQuery.of(context).size.height * 0.119,
                  margin: const EdgeInsets.only(top: 60),
                  child: Text(
                    "Sign up",
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
                    'images/registration.jpg',
                    fit: BoxFit.contain,
                    height: MediaQuery.of(context).size.height * 0.5,
                  ),
                ),
                // Txt Field Container
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: Text(
                    'Welcome to ShopWise',
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
        ],
      ),
    );
  }
}
