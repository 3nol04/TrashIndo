import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:trashindo/main.dart';
import 'package:trashindo/model/Daerah.dart';
import 'package:trashindo/screens/home_screen.dart';

class UploadScreens extends StatefulWidget {
  const UploadScreens({super.key});

  @override
  State<UploadScreens> createState() => _UploadScreensState();
}

class _UploadScreensState extends State<UploadScreens> {
  final TextEditingController _deskripsiController = TextEditingController();
  Sumsel? sumsel;
  String? selectedKota;
  String? selectedStatus;
  String? alamat;
  String? selectedDaerah;
  final List<String> kotaList = [];
  final List<String> daerahList = [];
  File? _imageFile;
  String? compressedImagePath;

  Future<void> loadData() async {
    final String data = await rootBundle.loadString('assets/data/sumsel.json');
    final jsonData = jsonDecode(data);
    sumsel = Sumsel.fromJson(jsonData); //panggil class sumsel dari model
    setState(() {
      sumsel = sumsel;
    });
  }

  void getKota() {
    final kota = sumsel?.kota;
    if (kota == null) return;

    setState(() {
      kotaList.clear();
      kotaList.addAll(kota
          .map((data) => data.nama)
          .toSet()
          .toList()); // pastikan tidak duplikat

      // Reset selectedKota kalau tidak valid
      if (selectedKota == null || !kotaList.contains(selectedKota)) {
        selectedKota = null;
      }

      // reset juga daerah saat kota ganti
      daerahList.clear();
      selectedDaerah = null;

      if (selectedKota != null) {
        getDaerah(selectedKota!);
      }
    });
  }

  void getDaerah(String kota) {
    final dataKota = sumsel?.kota;
    if (dataKota == null) return;

    final daerah = dataKota.firstWhere((data) => data.nama == kota).daerah;

    setState(() {
      daerahList.clear();
      daerahList.addAll(daerah);
    });
  }

  Future<void> _pickImageCamera() async {
    final ImagePicker _ambil_Gambar = ImagePicker();
    final XFile? _takeImage =
        await _ambil_Gambar.pickImage(source: ImageSource.camera);

    if (_takeImage != null) {
      setState(() => _imageFile = File(_takeImage.path));
      _compressImage(_imageFile!);
    }
  }

  Future<void> _pickImageFromGallery() async {
    final ImagePicker _ambil_Gambar = ImagePicker();
    final XFile? _takeImage =
        await _ambil_Gambar.pickImage(source: ImageSource.gallery);

    if (_takeImage != null) {
      setState(() => _imageFile = File(_takeImage.path));
      _compressImage(_imageFile!);
    }
  }

  Future<void> _compressImage(File image) async {
    if (image == null) {
      return;
    }
    var compressedImage = await FlutterImageCompress.compressWithFile(
      image.path,
      minWidth: 800,
      minHeight: 600,
      quality: 80,
    );
    setState(() {
      compressedImagePath = base64Encode(compressedImage!);
    });
  }

  void _showImagePickerOptions(BuildContext context) {
    // Reset image file when showing options
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Galeri'),
                onTap: () async {
                  final pickedFile = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  if (pickedFile != null) {
                    await _pickImageFromGallery();
                  }
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Kamera'),
                onTap: () async {
                  final pickedFile = await ImagePicker().pickImage(
                    source: ImageSource.camera,
                  );
                  if (pickedFile != null) {
                    await _pickImageCamera();
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _sendDataSampah() async {
    try {
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.best),
      );
      await FirebaseFirestore.instance.collection('sampah').add({
        'kota': selectedKota,
        'status': selectedStatus,
        'daerah': selectedDaerah,
        'lokasi_detail': alamat,
        'deskripsi': _deskripsiController.text,
        'image': compressedImagePath, // Simpan gambar terkompresi
        'latitude': position.latitude,
        'longitude': position.longitude,
        'is_bookmarked': false,
        'cereated_at': FieldValue.serverTimestamp(),
      }).then((value) async => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Home(),
            ),
          ));
    } catch (e) {
      print('Error getting location: $e');
      return Future.error('Error getting location: $e');
    }
  }

  Future<String> getAddressFromCoordinates() async {
    try {
      final accessToken = dotenv.env['MAPBOX_ACCESS_TOKEN'];

      if (accessToken == null || accessToken.isEmpty) {
        return 'Token Mapbox tidak ditemukan';
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final url = Uri.parse(
        'https://api.mapbox.com/geocoding/v5/mapbox.places/${position.longitude},${position.latitude}.json?access_token=$accessToken',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final features = data['features'];

        if (features != null && features.isNotEmpty) {
          final placeName = features[0]['place_name'];
          setState(() {
            alamat = placeName;
          });
          return placeName;
        } else {
          return 'Alamat tidak ditemukan';
        }
      } else {
        return 'Gagal memuat data alamat. Kode: ${response.statusCode}';
      }
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }

  final List<String> status = [
    'Kosong',
    'Penuh',
    'Rusak',
  ];

  @override
  void initState() {
    super.initState();
    loadData().then((_) {
      getKota();
    });
    getAddressFromCoordinates();
  }
@override
  void dispose() {
    // TODO: implement dispose
    _deskripsiController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    // Debugging print statement
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) {
                          return const HomeScreens();
                        }));
                      },
                      child: Icon(
                        Icons.arrow_back_outlined,
                        size: 30,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      height: 50,
                      width: 200,
                      child: Text(
                        'Upload Sampah',
                        style: GoogleFonts.roboto(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 30,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        _showImagePickerOptions(context);
                      },
                      child: _imageFile != null
                          ? Container(
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height * 0.3,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                    offset: const Offset(4, 8),
                                  )
                                ],
                                image : DecorationImage(
                                  image: FileImage(_imageFile!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : Container(
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height * 0.3,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.grey.withOpacity(0.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                    offset: const Offset(4, 8),
                                  )
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo,
                                    size: 50,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Ambil Foto',
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              )),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      width: MediaQuery.of(context).size.width * 0.6,
                      height: MediaQuery.of(context).size.height * 0.08,
                      child: Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.55,
                            height: MediaQuery.of(context).size.height * 0.02,
                            alignment: Alignment.centerLeft,
                            child: Text("Kota",
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                   color: Theme.of(context).textTheme.bodyLarge?.color,
                                )),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            alignment: Alignment.centerLeft,
                            width: MediaQuery.of(context).size.width * 0.6,
                            height: MediaQuery.of(context).size.height * 0.05,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                  offset: const Offset(4, 8),
                                )
                              ],
                            ),
                            child: DropdownButtonFormField<String>(
                              hint: const Text('Pilih Kota'),
                              value: selectedKota,
                              items: kotaList.map((String item) {
                                return DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(item),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedKota = newValue;
                                  daerahList.clear();
                                  selectedDaerah =
                                      null; // Reset daerah when kota changes
                                  // Clear daerah when kota changes
                                  if (selectedKota != null) {
                                    getDaerah(newValue!);
                                  }
                                  print(newValue);
                                });
                              },
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.only(left: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 5),
                    // TODO field Status
                    Container(
                      alignment: Alignment.centerLeft,
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: MediaQuery.of(context).size.height * 0.08,
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.02,
                            alignment: Alignment.centerLeft,
                            child: Text("Status",
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                   color: Theme.of(context).textTheme.bodyLarge?.color,
                                )),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            alignment: Alignment.centerLeft,
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.05,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                  offset: const Offset(4, 8),
                                )
                              ],
                            ),
                            child: DropdownButtonFormField<String>(
                              hint: const Text('Pilih Status'),
                              value: selectedStatus,
                              items: status.map((String item) {
                                return DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(item),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedStatus = newValue;
                                });
                              },
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.only(left: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // TODO field Daerah
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.02,
                  alignment: Alignment.centerLeft,
                  child: Text("Daerah",
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                      )),
                ),
                const SizedBox(height: 5),
                Container(
                  alignment: Alignment.centerLeft,
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.05,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(4, 8),
                      )
                    ],
                  ),
                  child: DropdownButtonFormField<String>(
                    hint: const Text('Pilih Daerah'),
                    value: selectedDaerah,
                    items: daerahList.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedDaerah = newValue;
                        print(selectedDaerah);
                      });
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.only(left: 10),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // TODO field Lokasi Detail
                const SizedBox(height: 5),
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.02,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Lokasi Detail",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10), // Tambah padding
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(4, 8),
                      )
                    ],
                  ),
                  child: Text(
                    alamat ?? 'Alamat tidak ditemukan',
                    softWrap: true,
                    textAlign: TextAlign
                        .left, // Bisa juga TextAlign.justify jika mau rata
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                ),

                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.02,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Deskripsi",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  alignment: Alignment.topLeft,
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.2,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(4, 8),
                      )
                    ],
                  ),
                  child: TextField(
                    controller: _deskripsiController,
                    maxLines: null,
                    // agar tinggi bisa menyesuaikan teks
                    textAlign: TextAlign.start,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.black.withOpacity(0.7),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Detail Informasi',
                      border: InputBorder.none,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(15),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.white,
                        ),
                      ),
                    ), // beri jarak teks dari tepi
                  ),
                ),
                const SizedBox(height: 15),
                GestureDetector(
                    onTap: () async {
                      await _sendDataSampah();
                    },
                    child: Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.05,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4E7CFE),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: const Offset(4, 8),
                          )
                        ],
                      ),
                      child: Center(
                          child: Text('Upload',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ))),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}