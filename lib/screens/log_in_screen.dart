import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trashindo/main.dart';
import 'package:trashindo/screens/sign_up_screen.dart';
import 'package:trashindo/wigedts/error_login_wigedts.dart';

class LoginScreens extends StatefulWidget {
  const LoginScreens({super.key});

  @override
  State<LoginScreens> createState() => _LoginScreensState();
}

class _LoginScreensState extends State<LoginScreens> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _isObscure = true;

  Future<void> _validateEmail() async {
    String email = _emailController.text;
    String password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email and password';
      });
      return;
    }
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email)) {
      setState(() {
        _errorMessage = 'Please enter a valid email address';
      });
      return;
    }
    setState(() {
      _errorMessage = '';
    });
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password entered.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  Future<void> _sendLoginRequest() async {
    await _validateEmail();
    if (_errorMessage.isNotEmpty) {
      return; // Exit if there are validation errors
    }

    try {
      // Attempt to sign in with Firebase
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // If successful, navigate to Home screen
      if (mounted) {
        await Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Home()),
            (route) => false);
      }
    } catch (e) {
      // Handle Firebase errors
      setState(() {
        if (e is FirebaseAuthException) {
          _errorMessage = _getAuthErrorMessage(e.code);
        } else {
          _errorMessage = 'An unknown error occurred. Please try again.';
        }
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sizeheight = MediaQuery.of(context).size.height;
    final sizeWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration:
                const BoxDecoration(color: Color.fromARGB(255, 160, 171, 87)),
            child: Stack(
              children: [
                Positioned(
                    top: sizeheight * 0.35,
                    left: sizeWidth * 0.1,
                    child: Container(
                      transform: Matrix4.rotationZ(10),
                      child: SvgPicture.asset('assets/svg/element.svg'),
                    )),
                Positioned(
                  top: sizeheight * 0.38,
                  left: sizeWidth * 0.1,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hallo...",
                          style: GoogleFonts.robotoSlab(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2D3600),
                            letterSpacing: 0.2,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        Text("Wellcome back to Trashindo...",
                            style: GoogleFonts.robotoSlab(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF2D3600),
                              letterSpacing: 0.2,
                            ),
                            textAlign: TextAlign.left)
                      ]),
                ),
                Positioned(
                    top: sizeheight * 0.03,
                    right: -sizeWidth * 0.82,
                    child: Container(
                      transform: Matrix4.rotationZ(0.5),
                      child: SvgPicture.asset('assets/svg/element.svg'),
                    )),
                Positioned(
                  bottom: mounted ? 0 : -sizeheight * 0.5,
                  child: SingleChildScrollView(
                    child: SizedBox(
                      width: sizeWidth,
                      height: sizeheight * 2,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                                width: sizeWidth,
                                height: sizeheight * 0.5,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    const BoxShadow(
                                      color: Color(0xFF2D3600),
                                      blurRadius: 50,
                                      offset: Offset(25, -5),
                                      spreadRadius: 5,
                                    ),
                                  ],
                                  color: Color(0xFFFFFFFF),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    topRight: Radius.circular(30),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                        padding: const EdgeInsets.only(
                                            left: 20,
                                            right: 20,
                                            top: 45,
                                            bottom: 25),
                                        child: Text("Log in",
                                            style: GoogleFonts.poppins(
                                              fontSize: 30,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF2D3600),
                                              letterSpacing: 0.2,
                                            ),
                                            textAlign: TextAlign.left)),
                                    Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: sizeWidth,
                                              height: sizeheight * 0.05,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFDEE5AB),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: TextField(
                                                  controller: _emailController,
                                                  decoration: InputDecoration(
                                                    fillColor:
                                                        Color(0xFFFFFFFF),
                                                    label: Text(
                                                      "Email",
                                                      style:
                                                          GoogleFonts.poppins(),
                                                    ),
                                                    border: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Color(
                                                                0xFFFFFFFF)),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                          Radius.circular(20),
                                                        )),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                                color: Color(
                                                                    0xFFFFFFFF))),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Color(
                                                              0xFFFFFFFF)),
                                                    ),
                                                    errorBorder:
                                                        OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .red),
                                                            gapPadding: 4),
                                                  )),
                                            ),
                                            if (_errorMessage.isNotEmpty) ...[
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10),
                                                child: ErrorWidgets(
                                                    errorMessage:
                                                        _errorMessage),
                                              )
                                            ],
                                          ]),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: sizeWidth,
                                              height: sizeheight * 0.05,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFDEE5AB),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: TextField(
                                                  controller:
                                                      _passwordController,
                                                  obscureText: _isObscure,
                                                  obscuringCharacter: '●',
                                                  decoration: InputDecoration(
                                                    hintStyle:
                                                        TextStyle(fontSize: 32),
                                                    labelStyle:
                                                        TextStyle(fontSize: 15),
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 10,
                                                            horizontal: 15),
                                                    fillColor:
                                                        Color(0xFFFFFFFF),
                                                    label: Text(
                                                      "Password",
                                                      style:
                                                          GoogleFonts.poppins(),
                                                    ),
                                                    border: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Color(
                                                                0xFFFFFFFF)),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                          Radius.circular(20),
                                                        )),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                                color: Color(
                                                                    0xFFFFFFFF))),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Color(
                                                              0xFFFFFFFF)),
                                                    ),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.red),
                                                      gapPadding: 4,
                                                    ),
                                                    suffixIcon: IconButton(
                                                      icon: Icon(
                                                        _isObscure
                                                            ? Icons
                                                                .visibility_off
                                                            : Icons.visibility,
                                                        color: Colors.black,
                                                        size: 20,
                                                      ),
                                                      onPressed: () {
                                                        setState(() {
                                                          _isObscure =
                                                              !_isObscure;
                                                        });
                                                      },
                                                    ),
                                                  )),
                                            ),
                                            if (_errorMessage.isNotEmpty) ...[
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10),
                                                child: ErrorWidgets(
                                                    errorMessage:
                                                        _errorMessage),
                                              )
                                            ],
                                            Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5,
                                                    right: 5,
                                                    top: 20,
                                                    bottom: 10),
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    _sendLoginRequest();
                                                    // fungsi untuk tombol log in
                                                  },
                                                  style: ButtonStyle(
                                                      minimumSize:
                                                          MaterialStateProperty
                                                              .all<Size>(Size(
                                                                  double
                                                                      .infinity,
                                                                  40)),
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all<Color>(Color
                                                                  .fromARGB(
                                                                      255,
                                                                      184,
                                                                      209,
                                                                      21))),
                                                  child: Text("Log in",
                                                      style: GoogleFonts
                                                          .poppins()),
                                                )),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 5,
                                                  right: 5,
                                                  top: 20,
                                                  bottom: 10),
                                              child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                        "Don't have an account? ",
                                                        style: GoogleFonts
                                                            .poppins()),
                                                    GestureDetector(
                                                      onTap: () async {
                                                        await Navigator.pushReplacement(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        const Singupscreens()));
                                                      },
                                                      child: Text(
                                                        "Sign up",
                                                        style:
                                                            GoogleFonts.poppins(
                                                          color:
                                                              Color(0xFF2E98CE),
                                                        ),
                                                      ),
                                                    )
                                                  ]),
                                            ),
                                          ]),
                                    )
                                  ],
                                )),
                          ]),
                    ),
                  ),
                )
              ],
            )));
  }
}
