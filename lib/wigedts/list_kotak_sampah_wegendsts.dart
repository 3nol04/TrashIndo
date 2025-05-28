import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trashindo/screens/detail_screen.dart';

class ListKotakSampahWegendsts extends StatefulWidget {
  const ListKotakSampahWegendsts(
      {super.key,
      required this.id,
      required this.status,
      required this.image,
      required this.daerah,
      required this.deskripsi});
  final String status;
  final String id;
  final String image;
  final String daerah;
  final String deskripsi;

  @override
  State<ListKotakSampahWegendsts> createState() =>
      _ListKotakSampahWegendstsState();
}

class _ListKotakSampahWegendstsState extends State<ListKotakSampahWegendsts> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 10),
      child: GestureDetector(
        onTap: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (context) =>  DetailScreens( id : widget.id)));
        },
        child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.095,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: const Offset(5, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.2,
                    height: MediaQuery.of(context).size.height * 0.1,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        base64Decode(widget.image),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.error, color: Colors.red),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                    ),
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: MediaQuery.of(context).size.height * 0.1,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.location_on,
                                    size: 15,
                                    color: Colors.black.withOpacity(0.5)),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  height:
                                      MediaQuery.of(context).size.height * 0.03,
                                  child: Text(
                                    widget.daerah,
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: SizedBox(
                                width: 200,
                                height: 20,
                                child: Text(
                                  widget.deskripsi,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.visible,
                                  maxLines: 2,
                                  textAlign: TextAlign.start,
                                  softWrap: true,
                                ),
                              ),
                            )
                          ],
                        )),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.15,
                    height: MediaQuery.of(context).size.height * 0.03,
                    decoration: BoxDecoration(
                      color: widget.status.toLowerCase() == "rusak"
                          ? Colors.red.withOpacity(0.3)
                          : widget.status.toLowerCase() == "penuh"
                              ? Colors.yellow.withOpacity(0.3)
                              : Colors.green.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        widget.status,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
