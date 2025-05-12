import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Onborading_wigwedts extends StatefulWidget {
  const Onborading_wigwedts(
      {super.key,
      required this.image,
      required this.title,
      required this.subtitle});

  final String image;
  final String title;
  final String subtitle;

  @override
  State<Onborading_wigwedts> createState() => _Onborading_wigwedtsState();
}

class _Onborading_wigwedtsState extends State<Onborading_wigwedts> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFDEE5AB),
              Color(0xFFFFFEFE),
            ],
          ),
        ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SafeArea(
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Image.asset(
                      widget.image,
                      width: 200,
                      height: 200,
                    ),
                  ),
                  Text(
                    widget.title,
                    style: GoogleFonts.robotoSlab(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15, left: 30, right: 30),
                    child: Text(
                      widget.subtitle,
                      style: GoogleFonts.robotoSlab(
                        fontSize: 17,
                        fontWeight: FontWeight.w300,
                        color: const Color(0xFF2D3600),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ]),
              ),
              
            ]),
        ),
    );
  }
}