import 'package:shopwise/utils/imports.dart';
import 'package:quickalert/quickalert.dart';
import 'package:email_otp/email_otp.dart';
import '../../services/auth_service.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  bool isOtpVerified = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();

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

  void showAlert2() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Sorry....',
      text: 'There is no valid user of this Email',
    );
  }

  void showAlert1() {
    QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: 'Yahoooo...',
        text: 'Password changed successfully!!',
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

  void showOtpSentSuccess() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      text: 'OTP Successfully sent!',
    );
  }

  void showOtpSuccess() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: 'Yahoooo...',
      text: 'OTP verified',
    );
  }

  void showOtpFailure() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Opps!!',
      text: 'OTP was not verified',
    );
  }

  final EmailOTP _emailOtp = EmailOTP();

  void _sendOTP() async {
    _emailOtp.setConfig(
        appEmail: "ShopWise@gmail.com",
        appName: "ShopWise",
        userEmail: _emailController.text,
        otpLength: 4,
        otpType: OTPType.digitsOnly);
    var result = await _emailOtp.sendOTP();
    if (result) {
      debugPrint("OTP sent successfully");
    } else {
      debugPrint("Failed to send OTP");
    }
  }

  void _verifyOtp() {
    var result = _emailOtp.verifyOTP(otp: _otpController.text);
    if (result) {
      setState(() {
        isOtpVerified = true;
      });
      debugPrint("OTP verified successfully");
    } else {
      debugPrint("OTP verification failed");
    }
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
            child: Form(
              key: formkey,
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
                  // Text Field Email
                  Container(
                    margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.10,
                    ),
                    width: MediaQuery.of(context).size.width * 0.37,
                    child: TextFormField(
                      controller: _emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required.';
                        } else {
                          RegExp regExp = RegExp(
                            r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                            caseSensitive: false,
                            multiLine: false,
                          );
                          if (!regExp.hasMatch(value)) {
                            return 'Enter a valid email address.';
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

                  // Password (with eye icon)
                  Container(
                    margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.035,
                    ),
                    width: MediaQuery.of(context).size.width * 0.37,
                    child: TextFormField(
                      obscureText: _isObscure,
                      maxLength: 18,
                      controller: _passwordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required.';
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

                  // OTP Field
                  Container(
                    margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.03,
                    ),
                    width: MediaQuery.of(context).size.width * 0.37,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _otpController,
                            decoration: InputDecoration(
                              hintText: "Enter OTP",
                              hintStyle: GoogleFonts.montserrat(
                                fontSize: 12,
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
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_emailController.text.isEmpty ||
                                  !RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                      .hasMatch(_emailController.text)) {
                                QuickAlert.show(
                                  context: context,
                                  type: QuickAlertType.error,
                                  title: 'Error',
                                  text: 'Please enter a valid email address first.',
                                );
                                return;
                              }
                              
                              if (formkey.currentState!.validate()) {
                                _sendOTP();
                                showOtpSentSuccess();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text("Send OTP",
                                style: TextStyle(
                                    fontSize: 10, color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            onPressed: () {
                              _verifyOtp();
                              if (isOtpVerified) {
                                showOtpSuccess();
                              } else {
                                showOtpFailure();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text("Verify",
                                style: TextStyle(
                                    fontSize: 10, color: Colors.white)),
                          ),
                        ),
                      ],
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
                        debugPrint("Change Password Button Pressed");
                        if (formkey.currentState!.validate()) {
                          if (isOtpVerified) {
                            try {
                              final success = await AuthService.resetPassword(_emailController.text);
                              if (success) {
                                setState(() {
                                  isOtpVerified = false;
                                });
                                showAlert1();
                              } else {
                                showAlert();
                              }
                            } catch (e) {
                              debugPrint('Password reset error: $e');
                              showAlert();
                            }
                          } else {
                            showOtpFailure();
                          }
                        } else {
                          debugPrint("Form validation failed");
                          showAlert();
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
                          color: Colors.white,
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
                        backgroundColor: const Color.fromRGBO(53, 108, 254, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Login?",
                        style: GoogleFonts.montserrat(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right Side
          Container(
            width: MediaQuery.of(context).size.width * 0.5,
            color: const Color.fromRGBO(53, 108, 254, 1),
            child: Column(
              children: [
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
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  color: const Color.fromRGBO(53, 108, 254, 1),
                  child: Image.asset(
                    'images/password_recover.jpg',
                    fit: BoxFit.contain,
                    height: MediaQuery.of(context).size.height * 0.5,
                  ),
                ),
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
        ],
      ),
    );
  }

}
