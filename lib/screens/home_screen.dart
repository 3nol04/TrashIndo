import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:google_fonts/google_fonts.dart';
import 'package:trashindo/model/Sampah.dart';
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
  }

  Future<void> _getUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userData = await user?.getUser(currentUser.uid);

      if (mounted) {
        if (userData != null) {
          setState(() {
            _name = userData.name;
            _imageProfile = userData.image; // uncomment jika ada
          });
        }
      }
    }
  }

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
              // Bagian profile (tetap di atas)
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
                        ? Image.asset(
                            _imageProfile,
                            width: 30,
                            height: 30,
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
                ],
              ),
              const SizedBox(height: 10),

              // Bagian scrollable
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Search bar
                      Container(
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
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search',
                            hintStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                            prefixIcon: Padding(
                              padding:
                                  const EdgeInsets.only(left: 15, right: 10),
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

                      // Carousel
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
                      // Status
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
                      // History
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
                        height: 300, // atur tinggi sesuai kebutuhan
                        child: FutureBuilder<List<Sampah>>(
                          future: sampah.getAllTempatSampah(),
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
