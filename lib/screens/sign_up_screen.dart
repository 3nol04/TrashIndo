import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trashindo/screens/log_in_screen.dart';
import 'package:trashindo/wigedts/error_login_wigedts.dart';

class Singupscreens extends StatefulWidget {
  const Singupscreens({super.key});

  @override
  State<Singupscreens> createState() => _SingupscreensState();
}

class _SingupscreensState extends State<Singupscreens> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _validPassController = TextEditingController();

  String _errorMessageEmail = '';
  String _errorMessagePassword = '';
  bool _isObscurePw = true;
  bool _isObscureValidPw = true;

  Future<void> _validateEmail() async {
    String email = _emailController.text;
    String password = _passwordController.text;
    String validPassword = _validPassController.text;

    setState(() {
      _errorMessageEmail = '';
      _errorMessagePassword = '';
    });

    // Validasi jika ada yang kosong
    if (email.isEmpty || password.isEmpty || validPassword.isEmpty) {
      setState(() {
        _errorMessageEmail = email.isEmpty ? 'Email cannot be empty' : '';
        _errorMessagePassword = (password.isEmpty || validPassword.isEmpty)
            ? 'Password and Confirm Password cannot be empty'
            : '';
      });
      return;
    }

    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+$')
        .hasMatch(email)) {
      setState(() {
        _errorMessageEmail = 'Invalid email format';
      });
      return;
    }

    // Validasi panjang password
    if (password.length < 6 || validPassword.length < 6) {
      setState(() {
        _errorMessagePassword = 'Password must be at least 6 characters';
      });
      return;
    }

    // Validasi kecocokan password
    if (password != validPassword) {
      setState(() {
        _errorMessagePassword = 'Password does not match';
      });
      return;
    }
    if (RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+$')
            .hasMatch(email) &&
        password == validPassword) {
      setState(() {
        _errorMessageEmail = '';
        _errorMessagePassword = '';
      });
    }
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  Future<void> _signUpRequest() async {
    await _validateEmail();
    if (_errorMessageEmail.isNotEmpty || _errorMessagePassword.isNotEmpty) {
      return;
    }

    try {
      // Sign up with Firebase authentication
      final idUser = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Save user data to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(idUser.user!.uid)
          .set({
        'name': 'guest', // Default name for new user
        'image': '',
        'email': _emailController.text.trim(),
        'password': _passwordController.text.trim(),
        'createdAt': Timestamp.now(),
      }).then((value) async {
        // Navigate to login screen after successful sign-up
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreens()),
        );
      });
    } catch (e) {
      // Handle Firebase error
      String errorMessage = _getAuthErrorMessage(e.toString());
      setState(() {
        _errorMessageEmail = errorMessage;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _validPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration:
                const BoxDecoration(color: Color.fromARGB(255, 160, 171, 87)),
            child: Stack(children: [
              Positioned(
                  top: height * 0.35,
                  left: width * 0.1,
                  child: Container(
                    transform: Matrix4.rotationZ(10),
                    child: SvgPicture.asset('assets/svg/element.svg'),
                  )),
              Positioned(
                top: height * 0.3,
                left: width * 0.1,
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
                      Text("Wellcome to Trashindo...",
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
                  top: height * 0.03,
                  right: -width * 0.82,
                  child: Container(
                    transform: Matrix4.rotationZ(0.5),
                    child: SvgPicture.asset('assets/svg/element.svg'),
                  )),
              Positioned(
                bottom: mounted ? 0 : -height * 0.5,
                child: SingleChildScrollView(
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                            width: width,
                            height: height * 0.6,
                            decoration: BoxDecoration(
                              color: Color(0xFFFFFFFF),
                              boxShadow: [
                                const BoxShadow(
                                  color: Color(0xFF2D3600),
                                  blurRadius: 50,
                                  offset: Offset(25, -5),
                                  spreadRadius: 5,
                                ),
                              ],
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
                                    child: Text("Sign Up",
                                        style: GoogleFonts.poppins(
                                          fontSize: 30,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF2D3600),
                                          letterSpacing: 0.2,
                                        ),
                                        textAlign: TextAlign.left)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 15),
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: width,
                                          height: height * 0.05,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFDEE5AB),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: TextField(
                                              controller: _emailController,
                                              decoration: InputDecoration(
                                                fillColor: Color(0xFFFFFFFF),
                                                label: Text(
                                                  "Email",
                                                  style: GoogleFonts.poppins(),
                                                ),
                                                border: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color:
                                                            Color(0xFFFFFFFF)),
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
                                                      color: Color(0xFFFFFFFF)),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.red),
                                                    gapPadding: 4),
                                              )),
                                        ),
                                        if (_errorMessageEmail.isNotEmpty) ...[
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                            child: ErrorWidgets(
                                                errorMessage:
                                                    _errorMessageEmail),
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
                                            width: width,
                                            height: height * 0.05,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFDEE5AB),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: TextField(
                                                controller: _passwordController,
                                                obscureText: _isObscurePw,
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
                                                  fillColor: Color(0xFFFFFFFF),
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
                                                        color:
                                                            Color(0xFFFFFFFF)),
                                                  ),
                                                  focusedErrorBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.red),
                                                    gapPadding: 4,
                                                  ),
                                                  suffixIcon: IconButton(
                                                    icon: Icon(
                                                      _isObscurePw
                                                          ? Icons.visibility_off
                                                          : Icons.visibility,
                                                      color: Colors.black,
                                                      size: 20,
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        _isObscurePw =
                                                            !_isObscurePw;
                                                      });
                                                    },
                                                  ),
                                                )),
                                          ),
                                          if (_errorMessagePassword
                                              .isNotEmpty) ...[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
                                              child: ErrorWidgets(
                                                  errorMessage:
                                                      _errorMessagePassword),
                                            )
                                          ],
                                        ])),
                                Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: width,
                                          height: height * 0.05,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFDEE5AB),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: TextField(
                                              controller: _validPassController,
                                              obscureText: _isObscureValidPw,
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
                                                fillColor: Color(0xFFFFFFFF),
                                                label: Text(
                                                  "Comfirm Password",
                                                  style: GoogleFonts.poppins(),
                                                ),
                                                border: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color:
                                                            Color(0xFFFFFFFF)),
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
                                                      color: Color(0xFFFFFFFF)),
                                                ),
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.red),
                                                  gapPadding: 4,
                                                ),
                                                suffixIcon: IconButton(
                                                  icon: Icon(
                                                    _isObscureValidPw
                                                        ? Icons.visibility_off
                                                        : Icons.visibility,
                                                    color: Colors.black,
                                                    size: 20,
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      _isObscureValidPw =
                                                          !_isObscureValidPw;
                                                    });
                                                  },
                                                ),
                                              )),
                                        ),
                                        if (_errorMessagePassword
                                            .isNotEmpty) ...[
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                            child: ErrorWidgets(
                                                errorMessage:
                                                    _errorMessagePassword),
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
                                                _signUpRequest();
                                                // fungsi untuk tombol log in
                                              },
                                              style: ButtonStyle(
                                                  minimumSize:
                                                      MaterialStateProperty
                                                          .all<Size>(Size(
                                                              double.infinity,
                                                              40)),
                                                  backgroundColor:
                                                      MaterialStateProperty.all<
                                                              Color>(
                                                          Color.fromARGB(255,
                                                              184, 209, 21))),
                                              child: Text("Sign up",
                                                  style: GoogleFonts.poppins()),
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
                                                Text("Do you have a account? ",
                                                    style:
                                                        GoogleFonts.poppins()),
                                                GestureDetector(
                                                  onTap: () async {
                                                    await Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                LoginScreens()));
                                                  },
                                                  child: Text(
                                                    "Log in",
                                                    style: GoogleFonts.poppins(
                                                      color: Color(0xFF2E98CE),
                                                    ),
                                                  ),
                                                )
                                              ]),
                                        ),
                                      ]),
                                )
                              ],
                            )),
                      ],
                    ),
                  ),
                ),
              )
            ])));
  }
}
