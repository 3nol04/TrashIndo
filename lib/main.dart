import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:trashindo/firebase_options.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:trashindo/screens/books_marks_screens.dart';
import 'package:trashindo/screens/home_screen.dart';
import 'package:trashindo/screens/on_boarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trashindo/screens/profile_screens.dart';
import 'package:trashindo/screens/search_screens.dart';
import 'package:trashindo/screens/splash_screen.dart';
import 'package:trashindo/screens/upload_screens.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  MapboxOptions.setAccessToken(dotenv.env['MAPBOX_ACCESS_TOKEN']!);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Splashscreen();
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  int _currentIndex = 0;
  bool? isFirstTimeLogin;

  final List<Widget> _pages = [
    const HomeScreens(),
    SearchScreens(),
    const UploadScreens(),
    const BooksMarksScreens(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _checkFirstTimeLogin();
  }

  // Fungsi untuk memeriksa apakah ini adalah login pertama kali
  _checkFirstTimeLogin() async {
    final prefs = await SharedPreferences.getInstance();
    bool? firstTime = prefs.getBool('isFirstTimeLogin');

    // Jika tidak ada status isFirstTimeLogin, maka ini adalah login pertama kali
    if (firstTime == null || firstTime == true) {
      // Tandai bahwa user sudah lewat onboarding
      await prefs.setBool('isFirstTimeLogin', false);
      setState(() {
        isFirstTimeLogin = true;
      });
    } else {
      setState(() {
        isFirstTimeLogin = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Periksa apakah pengguna sudah login
    if (FirebaseAuth.instance.currentUser == null) {
      return const OnboardingScreen(); // Jika belum login, tampilkan Onboarding
    }

    // Jika ini adalah login pertama kali, tampilkan Onboarding
    if (isFirstTimeLogin == true) {
      return const OnboardingScreen();
    }

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        backgroundColor: const Color(0x002C7C7D), // Transparan
        buttonBackgroundColor: const Color(0xFF2C7C7D),
        color: const Color(0xFF2C7C7D),
        animationCurve: Curves.fastEaseInToSlowEaseOut,
        height: MediaQuery.of(context).size.height * 0.05,
        animationDuration: const Duration(milliseconds: 800),
        items: const <Widget>[
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.search, size: 30, color: Colors.white),
          Icon(Icons.add_a_photo, size: 30, color: Colors.white),
          Icon(Icons.bookmark_add, size: 30, color: Colors.white),
          Icon(Icons.person, size: 30, color: Colors.white),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
