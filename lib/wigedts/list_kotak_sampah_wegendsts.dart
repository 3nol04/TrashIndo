import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trashindo/screens/detail_screen.dart';

class ListKotakSampahWegendsts extends StatefulWidget {
  const ListKotakSampahWegendsts({super.key, required this.status});
  final String status;

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
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const DetailScreens()));
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
                      image: const DecorationImage(
                          image: NetworkImage(
                              'https://as1.ftcdn.net/v2/jpg/05/39/68/24/1000_F_539682434_tP6yFmNpXIdXM9tq8izpxloyvQXeEb3R.jpg'),
                          fit: BoxFit.cover),
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
                                    'Kotak Sampah Wegendsts',
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
                                  'Kotak Sampah Wegendsts sudah penusdsd hvgkhxfxxfhtbdrdbrfyttgvybugv',
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
