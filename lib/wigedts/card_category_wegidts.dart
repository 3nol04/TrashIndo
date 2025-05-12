import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trashindo/screens/on_boarding_screen.dart';

class CardCategory extends StatefulWidget {
  const CardCategory({super.key, required this.title, required this.images});

  final String title;
  final String images;

  @override
  State<CardCategory> createState() => _CardCategoryState();
}

class _CardCategoryState extends State<CardCategory> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const OnboardingScreen(),
            ));
        // Handle button press here
        // For example, navigate to another screen or show a dialog
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.25,
        height: MediaQuery.of(context).size.height * 0.25,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 5,
              spreadRadius: 2,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              widget.images,
              width: MediaQuery.of(context).size.width * 0.09,
              height: MediaQuery.of(context).size.height * 0.07,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 5),
            Text(
              widget.title,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
