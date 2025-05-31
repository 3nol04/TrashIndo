import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trashindo/main.dart';
import 'package:trashindo/screens/log_in_screen.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  double _logoOpacity = 0.0;
  double _daunOpacity = 0.0;
  double _circleOpacity = 0.0;
  double _titleOpacity = 0.0;
  double _logoContaner = 1.2;
  final _currentUser = FirebaseAuth.instance.currentUser?.email;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 900), () {
      setState(() {
        _circleOpacity = 1.0;
      });
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        Future.delayed(const Duration(milliseconds: 100), () {
          setState(() {
            _logoOpacity = 1;
          });
        });
        _logoContaner = 0.9;
        Future.delayed(const Duration(milliseconds: 600), () {
          setState(() {
            _circleOpacity = 0.0;
            _titleOpacity = 1.0;
          });
        });
        Future.delayed(const Duration(milliseconds: 300), () {
          setState(() {
            _daunOpacity = 1.0;
          });
        });
        Future.delayed(const Duration(milliseconds: 4000), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    _currentUser == null ? LoginScreens() : Home()),
          );
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          alignment: Alignment.bottomCenter,
          height: double.maxFinite,
          width: double.maxFinite,
          decoration: const BoxDecoration(
            color: Color(0xFFDCE4A7),
          ),
          child: Stack(
            children: [
              //logo daun
              AnimatedPositioned(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                top: MediaQuery.of(context).size.height * 0.34,
                right: MediaQuery.of(context).size.width * 0.13,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  opacity: _daunOpacity,
                  child: SizedBox(
                    height: 300,
                    width: 300,
                    child: Image.asset(
                      'assets/images/daun.png',
                    ),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.02,
                right: MediaQuery.of(context).size.width * 0.01,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOut,
                  opacity: _logoOpacity,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.bounceOut,
                    height: MediaQuery.of(context).size.height * _logoContaner,
                    width: MediaQuery.of(context).size.width * 1,
                    child: Image.asset(
                      'assets/images/Logo 1.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.55,
                left: MediaQuery.of(context).size.width * 0.32,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  opacity: _circleOpacity,
                  child: Container(
                    height: 150,
                    width: 150,
                    transform: Matrix4.rotationX(1.4),
                    decoration: const BoxDecoration(
                        color: Color(0xFF848679), shape: BoxShape.circle),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.33,
                left: MediaQuery.of(context).size.width * 0.11,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  opacity: _titleOpacity,
                  child: SizedBox(
                      height: 300,
                      width: 300,
                      child: Image.asset('assets/images/teks.png',
                          fit: BoxFit.contain) //logo teks
                      ),
                ),
              ),
            ],
          )),
    );
  }
}
