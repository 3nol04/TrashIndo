import 'package:flutter/material.dart';

class CustomFont extends StatelessWidget {
  const CustomFont({
    super.key,
    required this.title,
    required this.size,
    required this.width,
    this.maxLines = 3,
    this.textAlign = TextAlign.start,
    this.fontWeight = FontWeight.w600,
  });

  final String title;
  final double size;
  final double width;
  final int maxLines;
  final TextAlign textAlign;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
  return SizedBox(
      width: MediaQuery.of(context).size.width * width,
      child: Text(
        title,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        softWrap: true,
        textAlign: textAlign,
        style: TextStyle(
          fontSize: size,
          fontWeight: fontWeight,
        ),
      ),
    );
  }
}
