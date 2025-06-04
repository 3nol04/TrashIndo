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
import 'package:provider/provider.dart';
import 'package:trashindo/providers/theme_provider.dart';


class HomeScreens extends StatefulWidget {
  const HomeScreens({super.key});

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
    getTokenFCM();
  }

  Future<void> _getUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userData = await user?.getUser(currentUser.uid);
      if (mounted && userData != null) {
        setState(() {
          _name = userData.name;
          _imageProfile = userData.image;
        });
      }
    }
  }

  Future<void> _requestLocation() async {
    bool servicesEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!servicesEnabled) return;
    geo.LocationPermission permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
      if (permission == geo.LocationPermission.denied || permission == geo.LocationPermission.deniedForever) {
        return;
      }
    }
  }

  Future<void> getTokenFCM() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('tokenFCM');
      FirebaseMessaging newToken = FirebaseMessaging.instance;
      NotificationSettings permission = await newToken.requestPermission();
      if (token == null) {
        token = await newToken.getToken();
        prefs.setString('tokenFCM', token!);
      }
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({'tokenFCM': token});
      }
    } catch (e) {
      print("FCM error: $e");
    }
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
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).cardColor,
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
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
                        : Icon(Icons.person, color: Theme.of(context).iconTheme.color),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            )),
                        Text(_name.isEmpty ? 'Guest' : _name,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w300,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            )),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.06,
                      width: MediaQuery.of(context).size.width * 0.16,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).shadowColor.withOpacity(0.2),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(Icons.message_outlined, color: Theme.of(context).iconTheme.color, size: 20),
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
                           child: IgnorePointer(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search',
                                hintStyle: TextStyle(color: Theme.of(context).hintColor),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(left: 15, right: 10),
                                  child: Icon(Icons.search, color: Theme.of(context).iconTheme.color),
                                ),
                                border: InputBorder.none,
                                isCollapsed: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
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
                        color: Theme.of(context).textTheme.bodyLarge?.color,
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
                              color: Theme.of(context).textTheme.bodyLarge?.color,
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
