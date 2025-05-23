import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;
import 'package:trashindo/screens/home_screen.dart';
import 'package:trashindo/wigedts/fonts_wigedts.dart';

class DetailScreens extends StatefulWidget {
  const DetailScreens({super.key});

  @override
  State<DetailScreens> createState() => _DetailScreenstState();
}

class _DetailScreenstState extends State<DetailScreens> {
  String kota = 'Palembang';
  String dearah = 'Plaju';
  bool _panelVisible = false;
  bool _marksBooks = false;
  final TextEditingController _commentController = TextEditingController();
  double _height = 0.19;
final  FocusNode _focusNode = FocusNode();

  mp.MapboxMap? _map;
  mp.PointAnnotationManager? _markUser; // Marker lokasi user
  mp.PointAnnotationManager? _markTujuan; // Marker tujuan
  mp.PointAnnotation? _markPositon; // Marker instance lokasi user
  mp.PointAnnotation? _markTujuanPositon; // Marker instance tujuan

Future  _changeHeight() async {
    setState(() {
      _height = _height == 0.19 ? 0.55 : 0.19;
      _panelVisible = !_panelVisible;
      _focusNode.addListener(() {
        if (_focusNode.hasFocus) {
          setState(() {
            _height = 0.9;
          });
        } else {
          setState(() {
            _height = 0.19;
          });
        }
      });
    });
  }

  @override
  void initState() {
    _requestLocation();
    super.initState();
  }

//Premesensi lokasi ke hp user
  Future<void> _requestLocation() async {
    // Memeriksa apakah lokasi diaktifkan
    bool servicesEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!servicesEnabled) return Future.error('Lokasi tidak diaktifkan.');

    geo.LocationPermission permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
      if (permission == geo.LocationPermission.denied) {
        return Future.error('Izin lokasi ditolak.');
      }
    }
    if (permission == geo.LocationPermission.deniedForever) {
      return Future.error('Izin lokasi permanen ditolak.');
    }

    _getPosition();
  }

  Future<void> _getPosition() async {
    geo.Geolocator.getPositionStream(
      locationSettings: const geo.LocationSettings(
        accuracy: geo.LocationAccuracy.best,
      ),
    ).listen((geo.Position position) {
      _getCurreatLocatin(position);
    });
  }

  Future<void> _getCurreatLocatin(geo.Position position) async {
    if (_map == null) return; // Map belum siap

    try {
      final poin = mp.Point(
        coordinates: mp.Position(position.longitude, position.latitude),
      );

      final ByteData bytes =
          await rootBundle.load('assets/images/location.png');
      final Uint8List imageData = bytes.buffer.asUint8List();

      _markUser ??= await _map!.annotations.createPointAnnotationManager();

      if (_markPositon != null && _markUser != null) {
        await _markUser!.delete(_markPositon!);
      }

      _markPositon = await _markUser!.create(
        mp.PointAnnotationOptions(
          geometry: poin,
          image: imageData,
          iconSize: 2.0,
        ),
      );

      _map?.easeTo(
        mp.CameraOptions(
          center: poin,
          zoom: 10,
        ),
        mp.MapAnimationOptions(duration: 1),
      );
    } catch (e) {
      print('Error saat menambahkan marker lokasi: $e');
    }
  }

  Future<void> tampilkanTujuan(double latitude, double longitude) async {
    final tujuan = mp.Point(
      coordinates: mp.Position(longitude, latitude),
    );
    final ByteData bytes =
        await rootBundle.load('assets/images/locationUser.png');
    final Uint8List imageData = bytes.buffer.asUint8List();

    // Inisialisasi manager tujuan jika null
    _markTujuan ??= await _map!.annotations.createPointAnnotationManager();

    // Hapus marker tujuan sebelumnya jika ada
    if (_markTujuanPositon != null) {
      await _markTujuan!.delete(_markTujuanPositon!);
    }

    // Tambahkan marker tujuan baru
    _markTujuanPositon = await _markTujuan!.create(
      mp.PointAnnotationOptions(
        geometry: tujuan,
        image: imageData,
        iconSize: 2.0,
      ),
    );

    // Arahkan kamera ke tujuan
    _map?.easeTo(
      mp.CameraOptions(
        center: tujuan,
        zoom: 12,
      ),
      mp.MapAnimationOptions(duration: 1),
    );
  }

  // Memuar peta saat peta  buka
  void _onMapCreated(mp.MapboxMap mapboxMap) async {
    _map = mapboxMap;

    // Bisa langsung buat manager di sini juga jika mau
    _markUser ??= await _map!.annotations.createPointAnnotationManager();
    _markTujuan ??= await _map!.annotations.createPointAnnotationManager();
    tampilkanTujuan(-2.9915, 104.7569);
  }

  @override
  void dispose() {
    // Clear all annotations
    _markUser?.deleteAll();
    _markTujuan?.deleteAll();

    // Dispose the map
    _map = null;

    // Dispose controllers
    _commentController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sizeHeight = MediaQuery.of(context).size.height;
    final sizeWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              mp.MapWidget(onMapCreated: _onMapCreated),
              //Bagaian atas navabar detail
              Stack(
                children: [
                  Positioned(
                    top: sizeHeight * 0.02,
                    left: sizeWidth * 0.05,
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: sizeHeight * 0.06,
                          width: sizeWidth * 0.9,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return const HomeScreens();
                                    }));
                                  },
                                  icon: Icon(Icons.arrow_back)),
                              SizedBox(
                                width: sizeWidth * 0.5,
                                height: sizeHeight * 0.06,
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
                  if (_panelVisible == false)
                    Positioned(
                      left: sizeWidth * 0.84,
                      bottom: sizeHeight * 0.2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SingleChildScrollView(
                            child: AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                width: sizeWidth * 0.11,
                                height: sizeHeight * 0.05,
                                decoration: BoxDecoration(
                                  color: _marksBooks
                                      ? Colors.yellow
                                      : Colors.white,
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
                                child: Center(
                                  child: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _marksBooks = !_marksBooks;
                                        });
                                      },
                                      icon: Icon(
                                        Icons.bookmark_add_outlined,
                                        size: 29,
                                      )),
                                )),
                          ),
                        ],
                      ),
                    ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: GestureDetector(
                      onTap: () {
                        _changeHeight();
                      },
                      onVerticalDragStart: (details) {
                        _changeHeight();
                      },
                      child: SingleChildScrollView(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          curve: Curves.linear,
                          height: sizeHeight * _height,
                          width: sizeWidth,
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: sizeWidth * 0.3,
                                            height: sizeHeight * 0.15,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                image: DecorationImage(
                                                  image: AssetImage(
                                                      'assets/images/trashimg/kotasampah.png'),
                                                )),
                                          ),
                                          SizedBox(
                                            width: sizeWidth * 0.03,
                                          ),
                                          SizedBox(
                                              width: sizeWidth * 0.61,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
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
                                                              color:
                                                                  Colors.green,
                                                              size: 15,
                                                            ),
                                                            SizedBox(width: 5),
                                                            Flexible(
                                                              child: CustomFont(
                                                                title:
                                                                    "Tersedia",
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
                                                    textAlign:
                                                        TextAlign.justify,
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
                                                    textAlign:
                                                        TextAlign.justify,
                                                  ),
                                                ],
                                              )),
                                        ]),
                                    CustomFont(
                                      title: "Komentar",
                                      size: 15,
                                      width: 0.2,
                                    ),
                                    Flexible(
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: ListView.builder(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5),
                                              itemCount: 10,
                                              itemBuilder: (context, index) {
                                                String profile = "";
                                                return Container(
                                                  margin: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 5,
                                                      horizontal: 10),
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFFDCE4A7),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      profile == ""
                                                          ? Icon(
                                                              Icons
                                                                  .account_circle,
                                                              size: 40)
                                                          : Container(
                                                              width: 30,
                                                              height: 30,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15),
                                                                color:
                                                                    Colors.grey,
                                                                image:
                                                                    DecorationImage(
                                                                  image: AssetImage(
                                                                      profile),
                                                                  fit: BoxFit
                                                                      .cover,
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
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5,
                                                      horizontal: 15),
                                              child: SingleChildScrollView(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: TextField(
                                                    controller:
                                                        _commentController,
                                                    maxLines: null,
                                                    decoration: InputDecoration(
                                                      contentPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                              horizontal: 12,
                                                              vertical: 8),
                                                      hintText:
                                                          "Tulis komentar",
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                        borderSide:
                                                            BorderSide.none,
                                                      ),
                                                    ),
                                                    textInputAction:
                                                        TextInputAction.send,
                                                    onSubmitted: (_) {
                                                      setState(() {
                                                        _commentController
                                                            .clear();
                                                      });
                                                      print(
                                                          'Test submit: ${_commentController.text}');
                                                    },
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
                    ),
                  )
                ],
              ),
            ],
          ),
        ));
  }
}
