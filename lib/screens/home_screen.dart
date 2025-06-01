import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trashindo/model/Sampah.dart';
import 'package:trashindo/screens/carilawanchatscreen.dart';
import 'package:trashindo/screens/search_screens.dart';
import 'package:trashindo/services/sampahServices.dart';
import 'package:trashindo/services/userServices.dart';
import 'package:trashindo/wigedts/card_category_wegidts.dart';
import 'package:trashindo/wigedts/corosel_homepage_wigents.dart';
import 'package:trashindo/wigedts/list_kotak_sampah_wegendsts.dart';

class HomeScreens extends StatefulWidget {
  const HomeScreens({
    super.key,
  });

  @override
  State<HomeScreens> createState() => _HomeScreensState();
}

class _HomeScreensState extends State<HomeScreens> {
  String _imageProfile = '';
  String _name = '';
  UserServices? user = UserServices();
  SampahServices sampah = SampahServices();

  @override
  void initState() {
    super.initState();
    _requestLocation();
    _getUser();
    getTokenFCM(); // Mendapatkan token FCM
  }

  Future<void> _getUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userData = await user?.getUser(currentUser.uid);

      if (mounted) {
        if (userData != null) {
          setState(() {
            _name = userData.name;
            _imageProfile = userData.image; // uncomment if image exists
          });
        }
      }
    }
  }

  Future<void> _requestLocation() async {
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
  }

  Future<void> getTokenFCM() async {
    try {
      // Mendapatkan instance SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('tokenFCM'); // Cek token yang sudah ada

      // Mendapatkan instance FirebaseMessaging untuk mengelola notifikasi
      FirebaseMessaging newToken = FirebaseMessaging.instance;

      // Meminta izin notifikasi dari pengguna
      NotificationSettings permission = await newToken.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Menangani izin notifikasi
      if (permission.authorizationStatus == AuthorizationStatus.authorized) {
        print('User diberikan izin untuk menerima notifikasi');
      } else if (permission.authorizationStatus ==
          AuthorizationStatus.provisional) {
        print('Pengguna diberikan izin sementara untuk menerima notifikasi');
      } else {
        print(
            'Pengguna menolak atau belum menerima izin untuk menerima notifikasi');
      }
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        final userData = await user?.getUser(currentUser.uid);

        if (userData != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .update({'tokenFCM': token});
        } else {
          print("Tidak ada data pengguna yang ditemukan.");
        }

        if (token == null) {
          token = await newToken.getToken();
          prefs.setString('tokenFCM', token!);
          // Cetak token dan email
          print("Token FCM : $token ");
        } else {
          print("Tidak ada pengguna yang terautentikasi.");
        }
      } else {
        print("Tidak ada pengguna yang terautentikasi.");
      }
    } catch (e) {
      // Tangani error jika terjadi masalah
      print("Terjadi kesalahan: $e");
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.center,
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                    child: _imageProfile.isNotEmpty
                        ? ClipOval(
                            child: Image.memory(
                              base64Decode(_imageProfile),
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            size: 30,
                            color: Colors.black,
                          ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          _name.isEmpty ? 'Guest' : _name,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w300,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchScreen(),
                        ),
                      );
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.06,
                      width: MediaQuery.of(context).size.width * 0.16,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.message_outlined,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SearchScreens()),
                            );
                          },
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.06,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: IgnorePointer(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Search',
                                  hintStyle: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                                  prefixIcon: const Padding(
                                    padding:
                                        EdgeInsets.only(left: 15, right: 10),
                                    child: Icon(
                                      Icons.search,
                                      color: Colors.black,
                                      size: 20,
                                    ),
                                  ),
                                  prefixIconConstraints: const BoxConstraints(
                                    minHeight: 20,
                                    minWidth: 20,
                                  ),
                                  border: InputBorder.none,
                                  isCollapsed: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.2,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(3, 5),
                              ),
                            ],
                          ),
                          child: Corousel(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text('Status',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1,
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CardCategory(
                                images:
                                    'assets/images/trashimg/alreadytrash.png',
                                title: 'Kosong',
                              ),
                              CardCategory(
                                images: 'assets/images/trashimg/carktrash.png',
                                title: 'Rusak',
                              ),
                              CardCategory(
                                images: 'assets/images/trashimg/fulltrash.png',
                                title: 'Penuh',
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Text(
                            'History',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.3,
                        child: FutureBuilder<List<Sampah>>(
                          future: sampah
                              .getAllTempatSampah(), // Future method from SampahServices
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return const Center(
                                  child: Text('No data available'));
                            } else {
                              return ListView.builder(
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  final item = snapshot.data![index];
                                  return ListKotakSampahWegendsts(
                                    id: item.id ?? '',
                                    status: item.status ?? 'Tidak ada status',
                                    image: item.image ?? '',
                                    daerah: item.daerah ?? 'Tidak ada daerah',
                                    deskripsi:
                                        item.deskripsi ?? 'Tidak ada deskripsi',
                                  );
                                },
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
