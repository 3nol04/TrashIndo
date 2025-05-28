import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;
import 'package:trashindo/model/Sampah.dart';
import 'package:trashindo/screens/home_screen.dart';
import 'package:trashindo/services/sampahServices.dart';
import 'package:trashindo/services/userServices.dart';
import 'package:trashindo/wigedts/fonts_wigedts.dart';

class DetailScreens extends StatefulWidget {
  DetailScreens({super.key, required this.idSampah});
  String idSampah;
  @override
  State<DetailScreens> createState() => _DetailScreenstState();
}

class _DetailScreenstState extends State<DetailScreens> {
  SampahServices sampahServices = SampahServices();
  UserServices userServices = UserServices();
  Sampah? _sampah;
  bool _panelVisible = false;
  bool _marksBooks = false;
  double? _latitude, _longitude;
  String? _idSampah, _idUser, _name, _imageProfile;
  final TextEditingController _commentController = TextEditingController();
  double _height = 0.19;
  final FocusNode _focusNode = FocusNode();

  mp.MapboxMap? _map;
  mp.PointAnnotationManager? _markUser; // Marker lokasi user
  mp.PointAnnotationManager? _markTujuan; // Marker tujuan
  mp.PointAnnotation? _markPositon; // Marker instance lokasi user
  mp.PointAnnotation? _markTujuanPositon; // Marker instance tujuan

  @override
  void initState() {
    super.initState();
    _getPosition();
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
  }

Future<void> _setScreen() async {
  try {
    final currentUser = FirebaseAuth.instance.currentUser;
    final dataSampah = await sampahServices.getSampah(widget.idSampah);

    if (currentUser != null) {
      final userData = await userServices.getUser(currentUser.uid);

      if (userData != null) {
        setState(() {
          _idUser = currentUser.uid;
          _name = userData.name ?? 'Tanpa Nama';
          _imageProfile = userData.image ?? '';
        });
      }
    }

    setState(() {
      _sampah = dataSampah;
      _idSampah = dataSampah.id;
    });
  } catch (e) {
    print('Gagal mengambil data sampah: $e');
  }
}


  Future<void> _changeHeight() async {
    setState(() {
      _height = _height == 0.19 ? 0.55 : 0.19;
      _panelVisible = !_panelVisible;
    });
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
          zoom: 14,
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
        zoom: 10,
      ),
      mp.MapAnimationOptions(duration: 1),
    );
  }

  void _onMapCreated(mp.MapboxMap mapboxMap) async {
    _map = mapboxMap;
    await _setScreen();
    _markUser ??= await _map!.annotations.createPointAnnotationManager();
    _markTujuan ??= await _map!.annotations.createPointAnnotationManager();

    if (_sampah?.latitude! != null && _sampah?.longitude! != null) {
      setState(() {
        _latitude = _sampah?.latitude!;
        _longitude = _sampah?.longitude!;
        _idSampah = _sampah?.id!;
      });
      tampilkanTujuan(_latitude!, _longitude!);
    }
  }

  Future<void> _sendComment() async {
    final comment = _commentController.text.trim();
    print('Komentar: $comment');
    print("Tampil id sampah: $_idSampah");
    if (comment.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('sampah')
            .doc(_idSampah)
            .collection('comments')
            .add({
          'user_name': _name,
          'user_id': _idUser, // pastikan _name adalah nama user, bukan UID
          'comment': comment,
          'user_image': _imageProfile,
          'created_at': FieldValue.serverTimestamp(),
        });

        _commentController.clear();
      } catch (e) {
        print('Gagal mengirim komentar: $e');
        // Tambahkan error handling UI jika perlu
      }
    }
  }

  @override
  void dispose() {
    // Clear all annotations
    _markUser?.deleteAll();
    _markTujuan?.deleteAll();
    _latitude = null;
    _longitude = null;
    // Dispose the map
    _map = null;
    _focusNode.dispose();
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
          child: Stack(children: [
            RepaintBoundary(child: mp.MapWidget(onMapCreated: _onMapCreated)),
            Stack(
              children: [
                Positioned(
                  top: sizeHeight * 0.04,
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
                              width: sizeWidth * 0.6,
                              height: sizeHeight * 0.06,
                              child: Center(
                                child: _sampah != null &&
                                        _sampah!.daerah != null &&
                                        _sampah!.kota != null
                                    ? Text(
                                        '${_sampah!.daerah} - ${_sampah!.kota}',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      )
                                    : Text(
                                        'Memuat lokasi...',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
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
                                color:
                                    _marksBooks ? Colors.yellow : Colors.white,
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
                        height: _height * sizeHeight,
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
                                                image: _sampah?.image! != null
                                                    ? MemoryImage(
                                                        base64Decode(
                                                            _sampah!.image!),
                                                      )
                                                    : AssetImage(
                                                        "assets/images/broken-image.png"),
                                                fit: BoxFit.cover,
                                                alignment: Alignment.center,
                                                scale: 1.0,
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
                                                              title: _sampah
                                                                      ?.status! ??
                                                                  "Tidak diketahui",
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
                                                  title: _sampah?.deskripsi! ??
                                                      "Tidak diketahui",
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
                                                      _sampah?.lokasiDetail! ??
                                                          "Tidak diketahui",
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
                                  Flexible(
                                    child: Column(
                                      children: [
                                        // FutureBuilder untuk menampilkan komentar dari Firestore
                                        Expanded(
                                          child: FutureBuilder<List<Comments>>(
                                            future:
                                                sampahServices.getAllComments(
                                                    widget.idSampah),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return Center(
                                                    child:
                                                        CircularProgressIndicator());
                                              } else if (snapshot.hasError) {
                                                return Center(
                                                    child: Text(
                                                        'Terjadi kesalahan: ${snapshot.error}'));
                                              } else if (!snapshot.hasData ||
                                                  snapshot.data!.isEmpty) {
                                                return Center(
                                                    child: Text(
                                                        'Belum ada komentar'));
                                              }

                                              final comments = snapshot.data!;

                                              return ListView.builder(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5),
                                                itemCount: comments.length,
                                                itemBuilder: (context, index) {
                                                  final comment =
                                                      comments[index];
                                                  final profile =
                                                      comment.userImage ?? "";

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
                                                        profile.isEmpty
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
                                                                  color: Colors
                                                                      .grey,
                                                                  image:
                                                                      DecorationImage(
                                                                    image: NetworkImage(
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
                                                                title: comment
                                                                    .userName ?? "",
                                                                size: 15, 
                                                                width: 0.5,
                                                              ),
                                                              CustomFont(
                                                                title: comment
                                                                    .comment ?? "",
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
                                              );
                                            },
                                          ),
                                        ),

                                        // Panel input komentar
                                        if (_panelVisible)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 5, horizontal: 15),
                                            child: SingleChildScrollView(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
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
                                                    hintText: "Tulis komentar",
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      borderSide:
                                                          BorderSide.none,
                                                    ),
                                                  ),
                                                  textInputAction:
                                                      TextInputAction.send,
                                                  onSubmitted: (_) {
                                                    _sendComment();
                                                    setState(() {
                                                      _commentController
                                                          .clear();
                                                    });
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
          ]),
          //Bagaian atas navabar detail
        ));
  }
}
