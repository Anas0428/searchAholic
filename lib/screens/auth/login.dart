import 'dart:convert';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:form_validator/form_validator.dart';
import 'forget_password.dart';

import '../../services/auth_service.dart';
import '../../utils/imports.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => LoginScreen();
}

class LoginScreen extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isObscure = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    if (await checkLoginFile()) {
      final credentials = await getDetails();
      _emailController.text = credentials[0];
      _passwordController.text = credentials[1];
    }
  }

  void _showLoginError() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Login Failed',
      text: 'Wrong Email or Password',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.height,
            color: Color.fromRGBO(250, 250, 250, 255),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 160),
                      child: Text(
                        "Login",
                        style: GoogleFonts.montserrat(
                            fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 50),
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: _emailController,
                        decoration: InputDecoration(
                            hintText: "Email",
                            hintStyle: GoogleFonts.montserrat(
                                fontSize: 16, fontWeight: FontWeight.w300)),
                        validator:
                            ValidationBuilder().email().required().build(),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 25),
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: TextFormField(
                        validator: ValidationBuilder().required().build(),
                        obscureText: _isObscure,
                        controller: _passwordController,
                        cursorColor: Color.fromRGBO(53, 108, 254, 1),
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
                                fontSize: 16, fontWeight: FontWeight.w300)),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      width: MediaQuery.of(context).size.width * 0.4,
                      alignment: Alignment.centerRight,
                      child: RichText(
                          text: TextSpan(
                        text: "Forget?",
                        style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            color: Color.fromRGBO(53, 108, 254, 1)),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ForgetPassword(),
                              ),
                            );
                          },
                      )),
                    ),
                    Container(
                        margin: const EdgeInsets.only(
                            top: 30, left: 150, right: 150),
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              await _handleLogin();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromRGBO(53, 108, 254, 1),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30))),
                          child: Text(
                            "Login",
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                            ),
                          ),
                        )),
                    Container(
                      margin: EdgeInsets.only(top: 15),
                      alignment: Alignment.center,
                      child: RichText(
                        text: TextSpan(
                            text: "Don't have Account?",
                            style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                                color: Colors.black),
                            children: <TextSpan>[
                              TextSpan(
                                  text: " Create one!",
                                  style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w300,
                                      color: Color.fromRGBO(53, 108, 254, 1)),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => SignUp()),
                                      );
                                    })
                            ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                  color: Color.fromRGBO(53, 108, 254, 1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(740),
                    bottomLeft: Radius.circular(640),
                  )),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 120, left: 90),
                    child: Text(
                      "Welcome to",
                      style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 0),
                    child: Text(
                      "ShopWise!",
                      style: GoogleFonts.montserrat(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(
                      child: Image.asset(
                        'images/logo.png',
                        height: MediaQuery.of(context).size.height * 0.42,
                        width: MediaQuery.of(context).size.width * 0.42,
                      ),
                    ),
                  ),
                ],
              ))
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    try {
      debugPrint('Starting Firebase login process...');

      // Basic validation
      if (_emailController.text.isEmpty) {
        debugPrint('Email is empty');
        _showLoginError();
        return;
      }
      if (_passwordController.text.isEmpty) {
        debugPrint('Password is empty');
        _showLoginError();
        return;
      }

      debugPrint('Attempting Firebase login for: ${_emailController.text}');

      final result = await AuthService.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (result != null) {
        debugPrint('Firebase login successful');
        // Save credentials to local file for compatibility
        await updateLoginFile(_emailController.text, _passwordController.text);
        // The AuthWrapper will handle navigation automatically
        // No need to manually navigate as the StreamBuilder will detect the auth state change
      } else {
        debugPrint('Firebase login failed');
        _showLoginError();
      }
    } catch (e) {
      debugPrint('Login error: $e');
      _showLoginError();
    }
  }
}


Future<bool> updateLoginFile(String email, String password) async {
  try {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path;
    Directory folder = Directory('$path/ShopWise');
    File file = File('$path/ShopWise/user.json');

    if (await folder.exists() && file.existsSync()) {
      final userData = {"email": email, "password": password};

      await file.writeAsString(jsonEncode(userData));
      return true;
    }
    return false;
  } catch (e) {
    return false;
  }
}

Future<bool> checkLoginFile() async {
  try {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path;
    Directory folder = Directory('$path/ShopWise');
    File file = File('$path/ShopWise/user.json');

    return await folder.exists() && file.existsSync();
  } catch (e) {
    return false;
  }
}

Future<List<String>> getDetails() async {
  try {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path;
    File file = File('$path/ShopWise/user.json');

    String fileContent = file.readAsStringSync().trim();

    if (fileContent.isEmpty) {
      return ['', ''];
    }

    var data = jsonDecode(fileContent);
    return [data['email'] ?? '', data['password'] ?? ''];
  } catch (e) {
    return ['', ''];
  }
}
