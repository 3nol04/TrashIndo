import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trashindo/wigedts/fonts_wigedts.dart';

class DetailScreens extends StatefulWidget {
  const DetailScreens({super.key});

  @override
  State<DetailScreens> createState() => _DetailScreentState();
}

class _DetailScreentState extends State<DetailScreens> {
  String kota = 'Palemabang';
  String dearah = 'Plaju';
  bool _panelVisible = false;
  final TextEditingController _commertsController = TextEditingController();
  double _height = 0.19;
  bool _isMark = true;
  double _lat = 0;
  double _long = 0;
  String _imageProfile = 'assets/images/profile.jpg';

  void _changeHeight() {
    setState(() {
      _height = _height == 0.19 ? 0.55 : 0.19;
      Future.delayed(const Duration(milliseconds: 250), () {
        setState(() {
          _panelVisible = !_panelVisible;
        });
      });
    });
  }

  @override
  void dispose() {
    _commertsController.dispose();
    super.dispose();
  }

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
      child: Stack(
        children: [
          Stack(
            children: [
              Positioned(
                top: MediaQuery.of(context).size.height * 0.05,
                left: MediaQuery.of(context).size.width * 0.05,
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.06,
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                              onPressed: () {}, icon: Icon(Icons.arrow_back)),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.5,
                            height: MediaQuery.of(context).size.height * 0.06,
                            child: Center(
                              child: Text(
                                '$dearah, $kota',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ),
              Positioned(
                bottom: MediaQuery.of(context).size.height * 0,
                left: MediaQuery.of(context).size.width * 0,
                child: GestureDetector(
                  onTap: () {
                    _changeHeight();
                  },
                  onVerticalDragStart: (details) {
                    _changeHeight();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.fastOutSlowIn,
                    height: MediaQuery.of(context).size.height * _height,
                    width: MediaQuery.of(context).size.width * 1,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 10,
                              spreadRadius: 1,
                              offset: const Offset(3, -4))
                        ]),
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.15,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          image: DecorationImage(
                                            image: AssetImage(
                                                'assets/images/trashimg/kotasampah.png'),
                                          )),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.03,
                                    ),
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.61,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                CustomFont(
                                                  title: "Kondisi",
                                                  size: 16,
                                                  width: 0.2,
                                                ),
                                                SizedBox(width: 85),
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.circle,
                                                        color: Colors.green,
                                                        size: 15,
                                                      ),
                                                      SizedBox(width: 5),
                                                      Flexible(
                                                        child: CustomFont(
                                                          title: "Tersedia",
                                                          size: 12,
                                                          width: 1.0,
                                                          maxLines: 1,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 1),
                                            CustomFont(
                                              title:
                                                  "Keadaan sampah penuh & harus di angkut.",
                                              size: 12,
                                              width: 0.9,
                                              maxLines: 2,
                                              textAlign: TextAlign.justify,
                                            ),
                                            SizedBox(height: 5),
                                            // Label “Lokasi”
                                            CustomFont(
                                              title: "Lokasi",
                                              size: 16,
                                              width: 0.2,
                                            ),
                                            SizedBox(height: 1),
                                            // Alamat lengkap
                                            CustomFont(
                                              title:
                                                  "Jl. Raya Pelabuhan No.1, Kel. Pelabuhan, Kec. Pelabuhan, Kota Palembang, Sumatera Selatan 30118, Indonesia",
                                              size: 12,
                                              width: 0.9,
                                              maxLines: 3,
                                              textAlign: TextAlign.justify,
                                            ),
                                          ],
                                        )),
                                  ]),
                              CustomFont(
                                title: "Komentar",
                                size: 15,
                                width: 0.2,
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: ListView.builder(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5),
                                        itemCount: 10,
                                        itemBuilder: (context, index) {
                                          String profile = "";
                                          return Container(
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 5, horizontal: 10),
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                profile == ""
                                                    ? Icon(Icons.account_circle,
                                                        size: 40)
                                                    : Container(
                                                        width: 30,
                                                        height: 30,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                          color: Colors.grey,
                                                          image:
                                                              DecorationImage(
                                                            image: AssetImage(
                                                                profile),
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                SizedBox(width: 10),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      CustomFont(
                                                        title: "Junaidi",
                                                        size: 15,
                                                        width: 0.5,
                                                      ),
                                                      CustomFont(
                                                        title:
                                                            "Komentar kedua yang sangat panjang untuk menguji scroll vertikal di Flutter.",
                                                        size: 12,
                                                        width: 0.8,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    if (_panelVisible)
                                      AnimatedOpacity(
                                        duration:
                                            const Duration(milliseconds: 1000),
                                        opacity: _panelVisible ? 1 : 0,
                                        curve: Curves.easeInOut,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 15),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: TextField(
                                              controller: _commertsController,
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 8),
                                                hintText: "Tulis komentar",
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  borderSide: BorderSide.none,
                                                ),
                                              ),
                                              textInputAction:
                                                  TextInputAction.send,
                                              onSubmitted: (_) {},
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ])),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    ));
  }
}
